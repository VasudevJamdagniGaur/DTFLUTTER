import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/chat_message.dart';
import '../models/crew_message.dart';
import '../models/mood_day_data.dart';

/// Core Firestore operations ported from `firestoreService.js`.
class FirestoreService {
  FirestoreService({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _db;
  final FirebaseStorage _storage;

  Future<ServiceResult> ensureUser(
    String uid, {
    String? email,
    String? displayName,
    String? profilePicture,
    String? createdAt,
    String? city,
    String? country,
    List<String>? interests,
  }) async {
    try {
      final payload = <String, dynamic>{
        if (createdAt != null) 'createdAt': createdAt,
        if (email != null) 'email': email,
        if (displayName != null) 'displayName': displayName,
        if (profilePicture != null) 'profilePicture': profilePicture,
        if (city != null) 'city': city,
        if (country != null) 'country': country,
        if (interests != null) 'interests': interests,
      };
      await _db.doc('users/$uid').set(
        {'createdAt': FieldValue.serverTimestamp(), ...payload},
        SetOptions(merge: true),
      );
      if (profilePicture != null || displayName != null) {
        final meta = <String, dynamic>{};
        if (profilePicture != null) meta['profilePicture'] = profilePicture;
        if (displayName != null) meta['displayName'] = displayName;
        await _db.doc('usersMetadata/$uid').set(meta, SetOptions(merge: true));
      }
      return const ServiceResult(success: true);
    } catch (e) {
      return ServiceResult(success: false, error: e.toString());
    }
  }

  Future<UserDataResult> getUser(String uid) async {
    try {
      final userSnap = await _db.doc('users/$uid').get();
      var userData = <String, dynamic>{};
      if (userSnap.exists) {
        userData = Map<String, dynamic>.from(userSnap.data()!);
      }
      final metaSnap = await _db.doc('usersMetadata/$uid').get();
      if (metaSnap.exists) {
        final meta = metaSnap.data()!;
        userData = {
          ...userData,
          ...meta,
          'profilePicture':
              meta['profilePicture'] ?? userData['profilePicture'],
          'displayName': meta['displayName'] ?? userData['displayName'],
        };
      }
      if (userData.isEmpty) {
        return const UserDataResult(success: false, error: 'User not found');
      }
      return UserDataResult(success: true, data: userData);
    } catch (e) {
      return UserDataResult(success: false, error: e.toString());
    }
  }

  Future<List<String>> getFollowing(String uid) async {
    try {
      final snap = await _db.doc('users/$uid/following/following').get();
      if (snap.exists) {
        final ids = snap.data()?['followingIds'];
        if (ids is List) return ids.cast<String>();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<bool> followUser(String uid, String targetUid) async {
    if (uid == targetUid) return false;
    try {
      final ref = _db.doc('users/$uid/following/following');
      final snap = await ref.get();
      final existing = snap.exists && snap.data()?['followingIds'] is List
          ? List<String>.from(snap.data!['followingIds'] as List)
          : <String>[];
      if (existing.contains(targetUid)) return true;
      await ref.set({
        'followingIds': [...existing, targetUid],
      }, SetOptions(merge: true));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> unfollowUser(String uid, String targetUid) async {
    try {
      final ref = _db.doc('users/$uid/following/following');
      final snap = await ref.get();
      final existing = snap.exists && snap.data()?['followingIds'] is List
          ? List<String>.from(snap.data!['followingIds'] as List)
          : <String>[];
      await ref.set({
        'followingIds': existing.where((id) => id != targetUid).toList(),
      }, SetOptions(merge: true));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> ensureChatDay(String uid, String dateId) async {
    await _db.doc('users/$uid/chats/$dateId').set({
      'date': dateId,
      'messageCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<String?> addMessage(
    String uid,
    String dateId,
    Map<String, dynamic> messageData,
  ) async {
    await ensureChatDay(uid, dateId);
    final ref = await _db
        .collection('users/$uid/chats/$dateId/messages')
        .add({...messageData, 'ts': FieldValue.serverTimestamp()});
    final chatRef = _db.doc('users/$uid/chats/$dateId');
    final snap = await chatRef.get();
    final count =
        snap.exists ? (snap.data()?['messageCount'] as int? ?? 0) : 0;
    await chatRef.set({
      'messageCount': count + 1,
      'lastMessageAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    return ref.id;
  }

  Future<List<ChatMessage>> getMessages(String uid, String dateId) async {
    try {
      final snap = await _db
          .collection('users/$uid/chats/$dateId/messages')
          .orderBy('ts')
          .get();
      return snap.docs.map((d) {
        final data = d.data();
        DateTime? ts;
        final raw = data['ts'];
        if (raw is Timestamp) ts = raw.toDate();
        return ChatMessage.fromMap({...data, 'timestamp': ts}, id: d.id);
      }).toList();
    } catch (_) {
      return [];
    }
  }

  Stream<List<ChatMessage>> watchMessages(String uid, String dateId) {
    return _db
        .collection('users/$uid/chats/$dateId/messages')
        .orderBy('ts')
        .snapshots()
        .map((snap) => snap.docs.map((d) {
              final data = d.data();
              DateTime? ts;
              final raw = data['ts'];
              if (raw is Timestamp) ts = raw.toDate();
              return ChatMessage.fromMap({...data, 'timestamp': ts}, id: d.id);
            }).toList());
  }

  /// Primary chat path — mirrors `saveChatMessageNew` (users/.../days/.../messages).
  Future<String?> saveChatMessageNew(
    String uid,
    String dateId, {
    required String sender,
    required String text,
    bool isWhisperSession = false,
    String? imageDataUrl,
    String? imageUrl,
  }) async {
    try {
      final role = sender == 'user' ? 'user' : 'assistant';
      final doc = <String, dynamic>{
        'role': role,
        'text': text,
        'ts': FieldValue.serverTimestamp(),
        'isWhisperSession': isWhisperSession,
      };
      if (imageUrl != null && imageUrl.isNotEmpty) {
        doc['imageUrl'] = imageUrl;
      } else if (imageDataUrl != null && imageDataUrl.length < 750000) {
        doc['image'] = imageDataUrl;
      }
      final ref =
          await _db.collection('users/$uid/days/$dateId/messages').add(doc);
      await _db.doc('users/$uid/days/$dateId').set({
        'date': dateId,
        'lastMessageAt': FieldValue.serverTimestamp(),
        'messageCount': FieldValue.increment(1),
      }, SetOptions(merge: true));
      return ref.id;
    } catch (_) {
      return null;
    }
  }

  Future<List<ChatMessage>> getChatMessagesNew(String uid, String dateId) async {
    try {
      final snap = await _db
          .collection('users/$uid/days/$dateId/messages')
          .orderBy('ts')
          .get();
      return snap.docs.map((d) {
        final data = d.data();
        DateTime? ts;
        final raw = data['ts'];
        if (raw is Timestamp) ts = raw.toDate();
        final sender = data['role'] == 'user' ? 'user' : 'ai';
        return ChatMessage.fromMap({
          'sender': sender,
          'text': data['text'],
          'isWhisperSession': data['isWhisperSession'] == true,
          if (data['image'] != null) 'image': data['image'],
          if (data['imageUrl'] != null) 'imageUrl': data['imageUrl'],
          'timestamp': ts,
        }, id: d.id);
      }).toList();
    } catch (_) {
      return [];
    }
  }

  Stream<List<ChatMessage>> watchChatMessagesNew(String uid, String dateId) {
    return _db
        .collection('users/$uid/days/$dateId/messages')
        .orderBy('ts')
        .snapshots()
        .map((snap) => snap.docs.map((d) {
              final data = d.data();
              DateTime? ts;
              final raw = data['ts'];
              if (raw is Timestamp) ts = raw.toDate();
              final sender = data['role'] == 'user' ? 'user' : 'ai';
              return ChatMessage.fromMap({
                'sender': sender,
                'text': data['text'],
                'isWhisperSession': data['isWhisperSession'] == true,
                if (data['image'] != null) 'image': data['image'],
                if (data['imageUrl'] != null) 'imageUrl': data['imageUrl'],
                'timestamp': ts,
              }, id: d.id);
            }).toList());
  }

  Future<int> deleteWhisperSessionMessages(String uid, String dateId) async {
    try {
      final snap = await _db
          .collection('users/$uid/days/$dateId/messages')
          .where('isWhisperSession', isEqualTo: true)
          .get();
      final batch = _db.batch();
      for (final doc in snap.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      return snap.docs.length;
    } catch (_) {
      return 0;
    }
  }

  Future<void> saveMoodChartNew(
    String uid,
    String dateId, {
    required double happiness,
    required double anxiety,
    required double stress,
    required double energy,
  }) async {
    await _db.doc('users/$uid/days/$dateId/moodChart/daily').set({
      'happiness': happiness,
      'anxiety': anxiety,
      'stress': stress,
      'energy': energy,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<List<Map<String, dynamic>>> getRecentChatDays(
    String uid, {
    int limit = 14,
  }) async {
    try {
      final snap = await _db
          .collection('users/$uid/chats')
          .orderBy('date', descending: true)
          .limit(limit)
          .get();
      return snap.docs
          .map((d) => {'id': d.id, ...d.data()})
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAllChatDays(String uid) async {
    try {
      final snap = await _db.collection('users/$uid/days').get();
      return snap.docs
          .map((d) => {'id': d.id, 'date': d.id, ...d.data()})
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<ServiceResult> saveReflectionNew(
    String uid,
    String dateId, {
    required String summary,
    String mood = 'neutral',
    int score = 50,
    List<String> insights = const [],
  }) async {
    try {
      await _db.doc('users/$uid/days/$dateId/reflection/meta').set({
        'summary': summary,
        'mood': mood,
        'score': score,
        'insights': insights,
        'updatedAt': FieldValue.serverTimestamp(),
        'source': 'auto',
      });
      return const ServiceResult(success: true);
    } catch (e) {
      return ServiceResult(success: false, error: e.toString());
    }
  }

  Future<ReflectionResult> getReflectionNew(String uid, String dateId) async {
    try {
      final snap =
          await _db.doc('users/$uid/days/$dateId/reflection/meta').get();
      if (snap.exists) {
        final data = snap.data()!;
        return ReflectionResult(
          success: true,
          reflection: data['summary'] as String?,
          fullData: data,
        );
      }
      return const ReflectionResult(success: true);
    } catch (e) {
      return ReflectionResult(success: false, error: e.toString());
    }
  }

  Future<List<Map<String, dynamic>>> getCommunityPosts({
    int limit = 30,
  }) async {
    try {
      final snap = await _db
          .collection('communityPosts')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      return snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
    } catch (_) {
      return [];
    }
  }

  Future<ServiceResult> createCommunityPost({
    required String authorId,
    required String text,
    String? imageUrl,
    String? displayName,
  }) async {
    try {
      await _db.collection('communityPosts').add({
        'authorId': authorId,
        'text_content': text,
        'content': text,
        if (imageUrl != null) 'image_url': imageUrl,
        if (imageUrl != null) 'image': imageUrl,
        if (displayName != null) 'authorName': displayName,
        'createdAt': FieldValue.serverTimestamp(),
        'likes': 0,
        'comments': 0,
      });
      return const ServiceResult(success: true);
    } catch (e) {
      return ServiceResult(success: false, error: e.toString());
    }
  }

  Future<String?> uploadPostImageBytes(
    String uid,
    Uint8List bytes, {
    String ext = 'jpg',
  }) async {
    try {
      final path =
          'posts/$uid/${DateTime.now().millisecondsSinceEpoch}.$ext';
      final ref = _storage.ref().child(path);
      await ref.putData(
        bytes,
        SettableMetadata(contentType: 'image/$ext'),
      );
      return await ref.getDownloadURL();
    } catch (_) {
      return null;
    }
  }

  Future<ServiceResult> saveSocialShare(
    String uid, {
    required String platform,
    required String reflectionDate,
    String? reflectionSnippet,
  }) async {
    try {
      await _db.collection('socialShares').add({
        'userId': uid,
        'platform': platform,
        'reflectionDate': reflectionDate,
        'reflectionSnippet': reflectionSnippet?.substring(0, 200),
        'createdAt': FieldValue.serverTimestamp(),
      });
      return const ServiceResult(success: true);
    } catch (e) {
      return ServiceResult(success: false, error: e.toString());
    }
  }

  Future<List<Map<String, dynamic>>> getSportsTrendingByCountry(
    String country, {
    int limit = 10,
  }) async {
    try {
      final c = country.toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '');
      if (c.length != 2) return [];
      final snap = await _db
          .collection('podSportsTrending')
          .where('country', isEqualTo: c)
          .orderBy('trendingScore', descending: true)
          .limit(limit)
          .get();
      return snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
    } catch (_) {
      return [];
    }
  }

  // --- Crew sphere ---

  Future<CrewSphereResult> getUserCrewSphere(String uid) async {
    try {
      final podsSnap = await _db.collection('users/$uid/pods').get();
      for (final podDoc in podsSnap.docs) {
        final sphereId = podDoc.data()['sphereId'] as String?;
        if (sphereId == null) continue;
        final sphereSnap = await _db.doc('crewSpheres/$sphereId').get();
        if (!sphereSnap.exists) continue;
        final sphere = sphereSnap.data()!;
        final members = sphere['members'];
        if (members is List && members.contains(uid)) {
          return CrewSphereResult(
            success: true,
            sphereId: sphereId,
            sphere: sphere,
          );
        }
      }
      final spheresSnap = await _db
          .collection('crewSpheres')
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();
      for (final doc in spheresSnap.docs) {
        final sphere = doc.data();
        final members = sphere['members'];
        if (members is List && members.contains(uid)) {
          return CrewSphereResult(
            success: true,
            sphereId: doc.id,
            sphere: sphere,
          );
        }
      }
      return const CrewSphereResult(success: false);
    } catch (e) {
      return CrewSphereResult(success: false, error: e.toString());
    }
  }

  Future<void> syncUserPodDocuments(String uid) async {
    try {
      final spheresSnap = await _db
          .collection('crewSpheres')
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();
      for (final doc in spheresSnap.docs) {
        final sphere = doc.data();
        final members = sphere['members'];
        if (members is! List || !members.contains(uid)) continue;
        final podRef = _db.doc('users/$uid/pods/${doc.id}');
        final podSnap = await podRef.get();
        if (!podSnap.exists) {
          await podRef.set({
            'name': "Crew's Sphere",
            'sphereId': doc.id,
            'members': members,
            'createdAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }
      }
    } catch (_) {}
  }

  Future<String?> saveCrewSphereMessage(
    String sphereId,
    String senderUid, {
    required String senderName,
    required String message,
    String? image,
  }) async {
    try {
      final ref = _db.collection('crewSpheres/$sphereId/messages').doc();
      await ref.set({
        'id': ref.id,
        'senderUid': senderUid,
        'senderName': senderName,
        'message': message,
        if (image != null) 'image': image,
        'timestamp': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      return ref.id;
    } catch (_) {
      return null;
    }
  }

  Stream<List<CrewMessage>> watchCrewSphereMessages(String sphereId) {
    return _db
        .collection('crewSpheres/$sphereId/messages')
        .orderBy('timestamp')
        .snapshots()
        .map((snap) {
      return snap.docs.map((d) {
        final data = d.data();
        DateTime? ts;
        final raw = data['timestamp'] ?? data['createdAt'];
        if (raw is Timestamp) ts = raw.toDate();
        return CrewMessage.fromMap(d.id, {
          ...data,
          if (ts != null) 'timestamp': ts,
        });
      }).toList();
    });
  }

  // --- Mood & emotional balance ---

  Future<List<MoodDayData>> getMoodChartData(String uid, {int days = 7}) async {
    final result = <MoodDayData>[];
    final todayId = _dateIdForOffset(0);
    final parts = todayId.split('-').map(int.parse).toList();
    for (var i = days - 1; i >= 0; i--) {
      final d = DateTime(parts[0], parts[1], parts[2]).subtract(Duration(days: i));
      final dateId =
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      final snap =
          await _db.doc('users/$uid/days/$dateId/moodChart/daily').get();
      final label = _shortDay(d);
      if (snap.exists) {
        final data = snap.data()!;
        result.add(MoodDayData(
          date: dateId,
          dayLabel: label,
          happiness: _toDouble(data['happiness']),
          anxiety: _toDouble(data['anxiety']),
          stress: _toDouble(data['stress']),
          energy: _toDouble(data['energy']),
        ));
      } else if (days == 7) {
        result.add(MoodDayData(date: dateId, dayLabel: label));
      }
    }
    return result;
  }

  Future<List<EmotionalBalanceDay>> getEmotionalBalanceData(
    String uid, {
    int days = 7,
  }) async {
    final result = <EmotionalBalanceDay>[];
    final todayId = _dateIdForOffset(0);
    final parts = todayId.split('-').map(int.parse).toList();
    for (var i = days - 1; i >= 0; i--) {
      final d = DateTime(parts[0], parts[1], parts[2]).subtract(Duration(days: i));
      final dateId =
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      final snap = await _db
          .doc('users/$uid/days/$dateId/emotionalBalance/daily')
          .get();
      if (snap.exists) {
        final data = snap.data()!;
        result.add(EmotionalBalanceDay(
          date: dateId,
          dayLabel: _shortDay(d),
          positive: _toDouble(data['positive']),
          negative: _toDouble(data['negative']),
          neutral: _toDouble(data['neutral']),
        ));
      }
    }
    return result;
  }

  Future<List<Map<String, dynamic>>> getRecentReflections(
    String uid, {
    int limit = 14,
  }) async {
    try {
      final daysSnap = await _db.collection('users/$uid/days').get();
      final reflections = <Map<String, dynamic>>[];
      for (final dayDoc in daysSnap.docs) {
        final refSnap = await _db
            .doc('users/$uid/days/${dayDoc.id}/reflection/meta')
            .get();
        if (refSnap.exists) {
          final data = refSnap.data()!;
          reflections.add({
            'dateId': dayDoc.id,
            'summary': data['summary'],
            'mood': data['mood'],
          });
        }
      }
      reflections.sort((a, b) => (b['dateId'] as String).compareTo(a['dateId'] as String));
      return reflections.take(limit).toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> incrementCommunityPostLike(String postId) async {
    try {
      await _db.doc('communityPosts/$postId').update({
        'likes': FieldValue.increment(1),
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> updateUserMetadata(
    String uid, {
    String? displayName,
    String? profilePicture,
    bool? crewEnrolled,
  }) async {
    final payload = <String, dynamic>{};
    if (displayName != null) payload['displayName'] = displayName;
    if (profilePicture != null) payload['profilePicture'] = profilePicture;
    if (crewEnrolled != null) payload['crewEnrolled'] = crewEnrolled;
    if (payload.isEmpty) return;
    await _db.doc('usersMetadata/$uid').set(payload, SetOptions(merge: true));
  }

  String _dateIdForOffset(int daysAgo) {
    final ist = DateTime.now().toUtc().add(const Duration(hours: 5, minutes: 30));
    final d = ist.subtract(Duration(days: daysAgo));
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  String _shortDay(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[d.month - 1]} ${d.day}';
  }

  double _toDouble(dynamic v) {
    if (v is num) return v.toDouble();
    return 0;
  }

  Future<String?> uploadProfileImage(String uid, Uint8List bytes) async {
    try {
      final ref = _storage.ref().child('profilePictures/$uid.jpg');
      await ref.putData(
        bytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      return await ref.getDownloadURL();
    } catch (_) {
      return null;
    }
  }
}

class ServiceResult {
  const ServiceResult({required this.success, this.error});
  final bool success;
  final String? error;
}

class UserDataResult {
  const UserDataResult({
    required this.success,
    this.data,
    this.error,
  });
  final bool success;
  final Map<String, dynamic>? data;
  final String? error;
}

class ReflectionResult {
  const ReflectionResult({
    required this.success,
    this.reflection,
    this.fullData,
    this.error,
  });
  final bool success;
  final String? reflection;
  final Map<String, dynamic>? fullData;
  final String? error;
}

class CrewSphereResult {
  const CrewSphereResult({
    required this.success,
    this.sphereId,
    this.sphere,
    this.error,
  });
  final bool success;
  final String? sphereId;
  final Map<String, dynamic>? sphere;
  final String? error;
}

final firestoreService = FirestoreService();
