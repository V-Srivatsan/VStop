import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vstop/lib/db.dart';
import 'package:awesome_notifications/awesome_notifications.dart' show AwesomeNotifications;
import 'package:vstop/lib/notification.dart';
import 'package:vstop/lib/store.dart';

import 'package:vstop/screens/login/index.dart' as auth;
import 'package:vstop/screens/sync/index.dart' as sync;
import 'package:vstop/screens/login/form.dart';

Future<bool> getEstimateGrades() async => await PrefStore.getPredictiveGrades();
Future<void> setEstimateGrades(bool val) async => await PrefStore.setPredictiveGrades(val);

Future<bool> getACEGrading() async => await PrefStore.getACEGrading();
Future<void> setACEGrading(bool val) async => await PrefStore.setACEGrading(val);

Future<void> logout(BuildContext context) async {
  Database.clear(); await PrefStore.setTheme(.system);
  await PrefStore.clear();
  await SecureStorage.clear();
  await NotificationController.cancelNotifications([
    NotificationController.CLASS_REMINDER_CHANNEL,
    NotificationController.EXAM_REMINDER_CHANNEL,
    NotificationController.ASSIGNMENT_REMINDER_CHANNEL
  ]);

  if (context.mounted)
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (ctx) => auth.Screen()),
      (_) => false
    );
}

Future<void> updateTheme(BuildContext context) async {

  void change(BuildContext ctx, AppTheme theme) async {
    await PrefStore.setTheme(theme);
    if (ctx.mounted) Navigator.pop(ctx);
  }

  showDialog(context: context, builder: (ctx) => AlertDialog(
    title: Text("Change Theme"),
    content: Column(
      mainAxisSize: .min, crossAxisAlignment: .stretch,
      children: [

        Card(child: ListTile(
          title: Text("Light Theme"), leading: Icon(Icons.light_mode),
          onTap: () => change(ctx, .light),
        )),

        Card(child: ListTile(
          title: Text("Dark Theme"), leading: Icon(Icons.dark_mode),
          onTap: () => change(ctx, .dark),
        )),

        Card(child: ListTile(
          title: Text("AMOLED Theme"), leading: Icon(Icons.dark_mode_outlined),
          onTap: () => change(ctx, .amoled),
        )),

        Card(child: ListTile(
          title: Text("System Theme"), leading: Icon(Icons.brightness_medium),
          onTap: () => change(ctx, .system),
        ))

      ],
    ),
  ));
}

void syncData(BuildContext ctx) =>
  showDialog(context: ctx, builder: (context) => AlertDialog(
    title: Text("Sync Data"),
    content: LoginForm(onAuth: (ctx) {
      Database.clear(false);
      NotificationController.cancelNotifications([
        NotificationController.CLASS_REMINDER_CHANNEL,
        NotificationController.EXAM_REMINDER_CHANNEL
      ]);
      Navigator.pushReplacement(ctx, MaterialPageRoute(builder: (_) => sync.Screen(partial: true)));
    }),
  ));

void shareApp() => SharePlus.instance.share(ShareParams(
    text: "Check out this one-stop solution for V-TOP: V-STOP!\n\nDownload here: https://github.com/V-Srivatsan/VStop/releases/latest"
));

void notificationSettings() => AwesomeNotifications().showNotificationConfigPage();