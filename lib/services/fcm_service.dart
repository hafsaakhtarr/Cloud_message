import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// Background message handler (must be top-level)
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling background message: ${message.messageId}');
  print('Message data: ${message.data}');
}

class FCMService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Initialize FCM service
  Future<void> initialize({
    required Function(RemoteMessage) onData,
  }) async {
    // Request notification permissions
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Listen to messages while app is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Message received while app is open: ${message.messageId}');
      onData(message);
    });

    // Listen to messages when app is opened from a notification tap
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('App opened from notification tap: ${message.messageId}');
      onData(message);
    });

    // Get initial message if app was launched from a notification
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      print('App launched from notification: ${initialMessage.messageId}');
      onData(initialMessage);
    }

    // Set background message handler
    FirebaseMessaging.onBackgroundMessage(
        firebaseMessagingBackgroundHandler);
  }

  // Get FCM token for this device
  Future<String?> getToken() {
    return _messaging.getToken();
  }
}