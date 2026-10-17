import 'dart:io';
import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'lib/net.dart';
import 'lib/store.dart';
import 'lib/db.dart';
import 'lib/fcm.dart';
import 'lib/notification.dart';
import 'lib/worker.dart';

import 'theme.dart' as theme;
import 'screens/splash/index.dart' as splash;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    FirebaseMessaging.onBackgroundMessage(FCMBackground);
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }
  try {
    await Database.init();
    await PrefStore.getTheme();
  } catch (e) {
    debugPrint('Database init error: $e');
  }

  try {
    await NotificationController.initialize();
    executeTask(SCHEDULE_NOTIFICATIONS_TASK);
    Workmanager().initialize(callbackDispatcher);
  } catch (e) {
    debugPrint('Worker/Notification init error: $e');
  }

  runApp(ValueListenableBuilder<AppTheme>(
    valueListenable: PrefStore.theme,
    builder: (_, prefTheme, _) =>
      MaterialApp(
        title: 'V-STOP',
        themeMode: (prefTheme == .system ? .system : (prefTheme == .light ? .light : .dark)),
        theme: theme.lightTheme,
        darkTheme: prefTheme == .amoled ? theme.amoledTheme : theme.darkTheme,
        home: splash.Screen(),
      )
  ));
}
