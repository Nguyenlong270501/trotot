import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';

import '../../firebase_options.dart';
import '../route/app_routes.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  log('📬 [Background] Nhận tin nhắn: ${message.messageId}');
}

class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  GoRouter? _router;

  static const String _channelId = 'quan_ly_tro_notification_channel';
  static const String _channelName = 'Thông báo Trọ Tốt';

  static const AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
        _channelId,
        _channelName,
        description:
            'Kênh nhận thông báo về lịch hẹn và hệ thống Trọ Tốt',
        importance: Importance.max,
        playSound: true,
      );

  Future<void> initialize({GoRouter? router}) async {
    _router = router;

    const androidInit = AndroidInitializationSettings('@drawable/ic_notification');
    const initSettings = InitializationSettings(android: androidInit);

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        log('👉 User CLICK (Foreground): ${details.payload}');
        _openNotificationsInbox();
      },
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_androidChannel);

    await _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    await _syncCurrentToken();

    _firebaseAuth.authStateChanges().listen((user) async {
      if (user == null) {
        return;
      }
      await _syncCurrentToken();
    });

    _fcm.onTokenRefresh.listen((newToken) async {
      await _saveTokenForCurrentUser(newToken);
      log('FCM token refreshed and synced.');
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('📬 [Foreground] Incoming...');
      _showLocalNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log('👉 User CLICK (Background): ${message.data}');
      _handleNotificationOpen(message);
    });

    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      log('👉 User CLICK (Terminated): ${initialMessage.data}');
      _handleNotificationOpen(initialMessage);
    }
  }

  void _handleNotificationOpen(RemoteMessage message) {
    log('notificationId: ${message.data['notificationId']}');
    _openNotificationsInbox();
  }

  void _openNotificationsInbox() {
    final router = _router;
    if (router == null) {
      return;
    }
    router.go(
      RouteNames.homepage,
      extra: <String, int>{
        'initialBottomNavIndex': 2,
        'initialMessagesTabIndex': 1,
      },
    );
  }

  Future<void> removeTokenForCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      return;
    }

    final token = await _fcm.getToken();
    if (token == null || token.isEmpty) {
      return;
    }

    try {
      await _firestore.collection('users').doc(user.uid).set(
        {'fcmTokens': FieldValue.arrayRemove([token])},
        SetOptions(merge: true),
      );
      log('FCM token removed for user ${user.uid}.');
    } on FirebaseException catch (e) {
      log('FCM removeToken failed: ${e.code} — ${e.message}');
    } catch (e, st) {
      log('FCM removeToken failed: $e', stackTrace: st);
    }
  }

  Future<void> _syncCurrentToken() async {
    final token = await _fcm.getToken();
    await _saveTokenForCurrentUser(token);
  }

  Future<void> _saveTokenForCurrentUser(String? token) async {
    final user = _firebaseAuth.currentUser;
    if (user == null || token == null || token.isEmpty) {
      return;
    }

    try {
      await _firestore.collection('users').doc(user.uid).set(
        {'fcmTokens': FieldValue.arrayUnion([token])},
        SetOptions(merge: true),
      );
      log('FCM token synced for user ${user.uid}.');
    } on FirebaseException catch (e) {
      log('FCM saveToken failed: ${e.code} — ${e.message}');
    } catch (e, st) {
      log('FCM saveToken failed: $e', stackTrace: st);
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) {
      return;
    }

    final androidDetails = AndroidNotificationDetails(
      _androidChannel.id,
      _androidChannel.name,
      channelDescription: _androidChannel.description,
      importance: _androidChannel.importance,
      priority: Priority.high,
      icon: '@drawable/ic_notification',
    );

    final int notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    final String? payloadData = message.data.isNotEmpty
        ? message.data.toString()
        : null;

    await _localNotifications.show(
      notificationId,
      notification.title,
      notification.body,
      NotificationDetails(android: androidDetails),
      payload: payloadData,
    );
  }

  Future<bool> requestNotificationPermission() async {
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    final granted =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
    if (granted) {
      await _syncCurrentToken();
    }
    return granted;
  }

  Future<void> syncCurrentToken() => _syncCurrentToken();
}
