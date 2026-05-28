import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/chat_message.dart';

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

final firestoreService = FirestoreService();
