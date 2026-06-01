import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
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
      try {
        final latest = jsonDecode((await http.get(
            Uri.parse("https://api.github.com/repos/V-Srivatsan/VStop/releases/latest")
        )).body)['tag_name'];
        final info = await PackageInfo.fromPlatform();

        if (latest != 'v${info.version}' && context.mounted)
          await showDialog(
            context: context, barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              title: Text("Update Available"),
              content: Text("A new version of V-Stop is available for download!\n\nPlease update to the latest version for the best experience."),
              actions: [
                OutlinedButton(onPressed: () => Navigator.pop(ctx), child: Text("Continue")),
                FilledButton(
                  onPressed: () => launchUrl(Uri.parse("https://github.com/V-Srivatsan/VStop/releases/latest")),
                  child: Text("Download")
                )
              ]
            )
          );

      } catch (e) { print(e); }
      finally {
        final logged = (await SecureStorage.get("username")) != null;
        if (context.mounted)
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) =>
            logged ? app.Screen() : auth.Screen()
          ));
      }
    }();

    return Scaffold(
      body: Center(child: Column(
        mainAxisSize: MainAxisSize.min, spacing: 10,
        children: [
          CircularProgressIndicator(),
          Text("Checking for updates...")
        ],
      )),
    );
  }
}
