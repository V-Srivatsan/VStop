import 'package:flutter/material.dart';
import 'package:vstop/lib/store.dart';
import 'package:vstop/lib/fcm.dart';

import 'package:vstop/screens/login/index.dart' as auth;
import 'package:vstop/screens/app/index.dart' as app;

class Screen extends StatelessWidget {
  const Screen({super.key});

  @override
  Widget build(BuildContext context) {
    NotificationService().initializeNotificationSystem();

    () async {
      final logged = (await SecureStorage.get("username")) != null;
      if (context.mounted)
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) =>
          logged ? app.Screen() : auth.Screen()
        ));
    }();

    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
