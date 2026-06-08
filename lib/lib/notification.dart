import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:workmanager/workmanager.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:vstop/lib/data/index.dart';
import 'package:vstop/lib/data/calendar.dart';
import 'package:vstop/lib/data/timetable.dart';
import 'package:vstop/lib/store.dart';
import 'package:vstop/screens/app/home/timetable/logic.dart' show getSchedule;

class NotificationController {

  static final _instance = AwesomeNotifications();

  static const CLASS_REMINDER_CHANNEL = 'class_reminder';
  static const EXAM_REMINDER_CHANNEL = 'exam_reminder';
  static const ASSIGNMENT_REMINDER_CHANNEL = 'assignment_reminder';

  static Future<void> initialize() async => await _instance.initialize(
    'resource://drawable/logo',
    [
      NotificationChannel(
        channelKey: CLASS_REMINDER_CHANNEL, channelName: 'Class Reminders',
        channelDescription: 'Reminders for your classes', channelGroupKey: 'reminders'
      ),
      NotificationChannel(
        channelKey: EXAM_REMINDER_CHANNEL, channelName: 'Exam Reminders',
        channelDescription: 'Reminders for your upcoming exams', channelGroupKey: 'reminders'
      ),
      NotificationChannel(
        channelKey: ASSIGNMENT_REMINDER_CHANNEL, channelName: 'Assignment Reminders',
        channelDescription: 'Reminders for pending assignments', channelGroupKey: 'reminders'
      ),
    ],
    channelGroups: [
      NotificationChannelGroup(channelGroupKey: 'reminders', channelGroupName: 'Reminders')
    ]
  );


  static void showNotification({
    required String id,
    required String channel, required String title, required String body,
    DateTime? schedule
  }) => _instance.createNotification(
    content: NotificationContent(
      id: id.hashCode, channelKey: channel,
      title: title, body: body
    ),
    schedule: schedule == null ? null : NotificationCalendar(
      allowWhileIdle: true, preciseAlarm: false,
      year: schedule.year, month: schedule.month, day: schedule.day,
      hour: schedule.hour, minute: schedule.minute
    )
  );

  static Future<void> cancelNotification(String id) async =>
      await _instance.cancelSchedule(id.hashCode);

  static Future<void> cancelNotifications(List<String> channels) async =>
    await Future.wait(channels.map((channel) => _instance.cancelSchedulesByChannelKey(channel)));
}

Future<void> scheduleDailyNotifications([bool exec = false]) async {
  final now = DateTime.now();
  Workmanager().registerOneOffTask(
    existingWorkPolicy: .replace,
    'notification_scheduling', 'notification_scheduling',
    initialDelay: exec ? null : Duration(microseconds: (
        Duration(hours: 24, seconds: 10).inMicroseconds -
        Duration(hours: now.hour, minutes: now.minute, seconds: now.second).inMicroseconds
    ))
  );
}

@pragma('vm:entry-point')
void scheduleWork() async {
  Workmanager().executeTask((task, data) async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      await NotificationController.initialize();
      await Database.init();

      final sem = await PrefStore.getSem();
      await NotificationController.cancelNotifications([
        NotificationController.CLASS_REMINDER_CHANNEL,
        NotificationController.EXAM_REMINDER_CHANNEL
      ]);

      String formatTime(Duration d) =>
          "${d.inHours.toString().padLeft(2, '0')}:${d.inMinutes.remainder(60).toString().padLeft(2, '0')}";

      final today = DateFormat("yyyyMMdd").format(.now());
      CalendarEntry? entry;
      List<ExamEntry> exams = [];
      for (var e in AcademicCalendar.getEntries(sem))
        if (e.date.compareTo(today) == 0) { entry = e; break; }

      for (var e in AcademicCalendar.getSchedule())
        if (e.date.compareTo(today) == 0) exams.add(e);

      final courses = Timetable(sem).getCourses();
      if (entry != null && entry.weekday != null)
        for (var slot in getSchedule(courses, entry.weekday!))
          NotificationController.showNotification(
            id: 'class_${slot.start}',
            channel: NotificationController.CLASS_REMINDER_CHANNEL,
            title: 'Next Class: ${slot.entry.course.target!.name}',
            body: '${formatTime(slot.start)} - ${formatTime(slot.end)}',
            schedule: DateFormat('yyyyMMdd HH:mm').parse('$today ${formatTime(slot.start - Duration(minutes: 15))}')
          );

      for (var exam in exams)
        NotificationController.showNotification(
            id: 'exam_${exam.id}',
            channel: NotificationController.EXAM_REMINDER_CHANNEL,
            schedule: DateFormat("yyyyMMdd HH:mm").parse(
                "${exam.date} ${exam.from}").subtract(Duration(minutes: 30)),
            title: 'Upcoming Exam: ${exam.course}',
            body: '${exam.venue}, ${exam.seatNo} (${exam.seatLoc})'
        );

      await scheduleDailyNotifications(); Database.close();
      return true;
    } catch (e) {
      print("Error scheduling notifications: $e");
      return false;
    }
  });
}