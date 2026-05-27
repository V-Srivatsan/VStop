import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'lib/net.dart';
import 'lib/store.dart';
import 'lib/data/index.dart';
import 'lib/fcm.dart';

import 'theme.dart' as theme;
import 'screens/splash/index.dart' as splash;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Database.init(); await PrefStore.getTheme();

  FirebaseMessaging.onBackgroundMessage(FCMBackground);

  runApp(ValueListenableBuilder<ThemeMode>(
    valueListenable: PrefStore.theme,
    builder: (_, prefTheme, _) =>
      MaterialApp(
        title: 'V-STOP',
        themeMode: prefTheme,
        theme: theme.lightTheme,
        darkTheme: theme.darkTheme,
        home: splash.Screen(),
      )
  ));
}
