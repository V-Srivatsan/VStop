import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:vstop/lib/store.dart';
import 'package:vstop/lib/fcm.dart';

import 'package:vstop/screens/login/index.dart' as auth;
import 'package:vstop/screens/app/index.dart' as app;

const FORCE_SYNC = false;

class Screen extends StatelessWidget {
  const Screen({super.key});

  @override
  Widget build(BuildContext context) {
    NotificationService().initializeNotificationSystem();
    PackageInfo.fromPlatform().then((info) async {
      final logged = (await SecureStorage.get("username")) != null;
      final syncVer = await SecureStorage.get("syncVersion");
      if (context.mounted)
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) =>
          logged && (FORCE_SYNC ? syncVer != null && info.version == syncVer : true) ? app.Screen() : auth.Screen()
        ));
    });

    return Scaffold(
      body: Center(child: Column(
        mainAxisSize: MainAxisSize.min, spacing: 10,
        children: [
          CircularProgressIndicator()
        ],
      )),
    );
  }
}
