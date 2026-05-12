import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// Must be top-level — FCM requires it for background isolation
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('FCM background: ${message.messageId}');
}

class NotificationService {
  Future<void> initialize() async {
    // Notificaciones locales deshabilitadas — FCM maneja la visualización en background/terminated.
  }

  Future<void> requestPermission() async {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('FCM permission: ${settings.authorizationStatus}');
  }

  /// Obtiene el FCM token y lo guarda en Firestore users/{uid}/fcm_token.
  /// También escucha refrescos de token para mantenerlo actualizado.
  Future<void> getToken() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .update({'fcm_token': token});
      }
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .update({'fcm_token': newToken});
      });
    } catch (_) {}
  }

  /// En foreground FCM no muestra la notificación automáticamente.
  /// Por ahora solo logueamos — se puede reactivar con flutter_local_notifications cuando se resuelva el conflicto de desugaring.
  void setupForegroundHandler() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint(
          'FCM foreground: ${message.notification?.title} — ${message.notification?.body}');
    });
  }
}
