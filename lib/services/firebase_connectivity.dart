import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart' show debugPrint;

/// Lightweight reachability check (no extra packages).
class FirebaseConnectivity {
  static const _hosts = [
    'identitytoolkit.googleapis.com',
    'www.googleapis.com',
  ];

  /// Returns null if hosts resolve; otherwise a short reason string.
  static Future<String?> checkFirebaseReachability() async {
    for (final host in _hosts) {
      try {
        final results = await InternetAddress.lookup(host)
            .timeout(const Duration(seconds: 8));
        if (results.isEmpty) {
          return 'DNS lookup for $host returned no addresses.';
        }
        debugPrint('FirebaseConnectivity: $host -> ${results.first.address}');
      } on SocketException catch (e) {
        debugPrint('FirebaseConnectivity: $host SocketException: $e');
        return 'No network route to $host ($e). '
            'On the emulator: open Chrome, visit google.com, or cold-boot the AVD.';
      } on TimeoutException catch (e) {
        debugPrint('FirebaseConnectivity: $host timeout: $e');
        return 'Timed out resolving $host. Check emulator internet/Wi‑Fi.';
      } catch (e) {
        debugPrint('FirebaseConnectivity: $host error: $e');
        return 'Network check failed for $host: $e';
      }
    }
    return null;
  }
}
