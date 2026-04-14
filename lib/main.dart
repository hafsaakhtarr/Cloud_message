import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'services/fcm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cloud Messaging',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FCMService _fcmService = FCMService();
  String statusText = 'Waiting for a cloud message';
  String imagePath = 'assets/images/clouds.png';
  String? fcmToken;
  bool isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeFCM();
  }

  Future<void> _initializeFCM() async {
    try {
      await _fcmService.initialize(onData: _handleMessage);

      // Get the FCM token
      fcmToken = await _fcmService.getToken();
      print('FCM Token: $fcmToken');

      setState(() {
        isInitialized = true;
      });
    } catch (e) {
      print('FCM initialization error: $e');
      setState(() {
        statusText = 'Error initializing FCM: $e';
      });
    }
  }

  void _handleMessage(RemoteMessage message) {
    setState(() {
      // Extract title from notification
      statusText =
          message.notification?.title ?? 'Payload received';

      // Extract image path from payload data
      imagePath = 'assets/images/${message.data['asset'] ?? 'pinkcloud'}.png';

      print('Message data: ${message.data}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cloud Messaging'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      statusText,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    if (!isInitialized)
                      const LinearProgressIndicator()
                    else
                      const Text(
                        '✓ FCM Initialized',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Image display
            Center(
              child: Container(
                constraints: const BoxConstraints(
                  maxHeight: 300,
                  maxWidth: 300,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Text(
                        'Image not found:\n$imagePath',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Token display (for debugging)
            if (fcmToken != null)
              Card(
                color: Colors.grey[100],
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'FCM Token (for testing)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SelectableText(
                        fcmToken!,
                        style: const TextStyle(
                          fontSize: 10,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Copy this token and use it in Firebase Console to send a test message.',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}