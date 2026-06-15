import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:awesome_notifications/awesome_notifications.dart' show AwesomeNotifications;
import 'package:battery_optimization_helper/battery_optimization_helper.dart';
import 'package:workmanager/workmanager.dart';
import 'package:vstop/lib/db.dart';
import 'package:vstop/lib/notification.dart';
import 'package:vstop/lib/store.dart';
import 'package:vstop/lib/worker.dart';

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

  await cancelTask(SYNC_DATA_TASK); await cancelTask(SCHEDULE_NOTIFICATIONS_TASK);

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
    content: GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2, crossAxisSpacing: 10,
      children: [
        for (final theme in [
          ("Light", AppTheme.light, Icons.light_mode),
          ("Dark", AppTheme.dark, Icons.dark_mode),
          ("AMOLED", AppTheme.amoled, Icons.dark_mode_outlined),
          ("System", AppTheme.system, Icons.brightness_medium)
        ])
          InkWell(
            onTap: () => change(ctx, theme.$2),
            child: Card(child: Container(
              alignment: .center,
              child: Column(
                mainAxisSize: .min, spacing: 10,
                children: [
                  Icon(theme.$3),
                  Text(theme.$1, style: Theme.of(context).textTheme.bodyLarge)
                ],
              ),
            )),
          )
      ],
    )
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

Future<bool> getAutoSync() => PrefStore.getBackgroundSync();
Future<bool> setAutoSync(bool val, BuildContext context) async {
  if (!val) {
    await cancelTask(SYNC_DATA_TASK);
    await PrefStore.setBackgroundSync(false);
    return false;
  }

  final bool proceed = await showDialog(context: context, builder: (ctx) => AlertDialog(
    title: Text("Auto Sync"),
    content: Text("Enabling auto sync will allow the app to sync your data for the current semester in the background every 24 hours.\n\nThis may consume more battery and data. Do you want to proceed?"),
    actions: [
      OutlinedButton(onPressed: () => Navigator.pop(ctx, false), child: Text("Cancel")),
      FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text("Proceed"))
    ],
  ));

  if (!proceed) return false;
  if (await BatteryOptimizationHelper.isBatteryOptimizationEnabled())
    BatteryOptimizationHelper.requestDisableBatteryOptimization();
  await PrefStore.setBackgroundSync(true);
  executeTask(SYNC_DATA_TASK, constraints: Constraints(networkType: .connected));
  return true;
}

void openSettings() => BatteryOptimizationHelper.openAutoStartSettings();