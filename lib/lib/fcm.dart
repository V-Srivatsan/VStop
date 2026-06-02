import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

@pragma('vm:entry-point')
Future<void> FCMBackground(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> initializeNotificationSystem() async {
    // 1. Request User Permission (Crucial for iOS & Android 13+)
    NotificationSettings settings = await _fcm.requestPermission(alert: true, badge: true, sound: true);

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      await _fcm.subscribeToTopic("all_users");
    }

    // 2. Fetch the unique FCM Registration Token
    // Send this string to your backend database to target this individual device
    await _fcm.getToken();

    // 3. Configure Foreground Notification Display Options
    await _fcm.setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true);

    // 5. Handle Foregound Messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {

    });
  }
}
