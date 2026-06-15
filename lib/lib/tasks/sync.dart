import 'dart:async';
import 'package:workmanager/workmanager.dart';
import 'package:vstop/lib/db.dart';
import 'package:vstop/lib/store.dart';
import 'package:vstop/lib/webview.dart';
import 'package:vstop/lib/worker.dart';
import 'package:vstop/lib/notification.dart';

import 'package:vstop/screens/login/logic.dart' as logic;

bool isSyncing = false;

Future<bool> syncData() async {
  if (isSyncing) return true;
  final String sem;
  try { sem = await PrefStore.getSem(); }
  catch (e) { return true; }

  final status = Completer<bool>();
  int tries = 0; bool loaded = false;

  NotificationController.showNotification(
    id: 'sync_task', channel: NotificationController.GENERAL_CHANNEL,
    title: 'Syncing Data', body: 'Auto syncing data from V-Top'
  );

  WebView.initialize(onPageLoad: (url) async {
    if (url != WebView.homeUrl && url != WebView.loginUrl && url != WebView.loginErrorUrl)
      return status.complete(false);

    if (url == WebView.homeUrl) {
      loaded = true;
      if (isSyncing) return;
      isSyncing = true;

      await WebView.setAuth();
      await Future.wait([
        Timetable(sem).fetchAttendance(),
        AcademicCalendar.fetch(sem), AcademicCalendar.fetchExamSchedule(sem)
      ]);
      await MarkStore(sem).fetch();
      return status.complete(true);
    }

    if (url == WebView.loginErrorUrl)
      tries += (await logic.getLoginError())!.contains("Captcha") ? 1 : 5;

    if (tries >= 3) return status.complete(false);

    final cred = (await logic.getCred())!;
    final cap = await logic.getCaptcha();
    logic.login(cred.$1, cred.$2, cap != null ? await logic.getCaptchaStr(cap) : null);
  });

  Future.delayed(Duration(seconds: 30), () {
    if (!status.isCompleted && !loaded) status.complete(false);
  });

  final success = await status.future;
  WebView.dispose();
  if (!success)
    NotificationController.showNotification(
      id: 'sync_task', channel: NotificationController.GENERAL_CHANNEL,
      title: "Auto Sync failed", body: "Auto sync failed. This might be due to V-Top being down."
    );
  else {
    NotificationController.clearNotification('sync_task');
    executeTask(SCHEDULE_NOTIFICATIONS_TASK);
  }

  final now = DateTime.now();
  executeTask(
    SYNC_DATA_TASK, constraints: Constraints(networkType: .connected),
    delay: Duration(days: 1) - Duration(hours: now.hour, minutes: now.minute, seconds: now.second)
  );

  return success;
}