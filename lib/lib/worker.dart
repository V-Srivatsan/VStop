import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:vstop/lib/net.dart';
import 'package:vstop/lib/notification.dart';
import 'package:workmanager/workmanager.dart';
import 'db.dart';
import 'tasks/notifications.dart';
import 'tasks/sync.dart';

const String SCHEDULE_NOTIFICATIONS_TASK = 'schedule_notifications';
const String SYNC_DATA_TASK = 'sync_data';

Future<void> cancelTask(String task) => Workmanager().cancelByUniqueName(task);

void executeTask(String task, { Duration? delay, Constraints? constraints }) =>
    Workmanager().registerOneOffTask(
      existingWorkPolicy: .replace,
      task, task, initialDelay: delay,
      constraints: constraints
    );

@pragma('vm:entry-point')
void callbackDispatcher() =>
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    await Database.init(); await NotificationController.initialize();
    HttpOverrides.global = MyHttpOverrides();

    switch (task) {
      case SCHEDULE_NOTIFICATIONS_TASK:
        await scheduleNotifications();
        break;
      case SYNC_DATA_TASK:
        await syncData();
        break;
    }

    Database.close();
    return true;
  });

