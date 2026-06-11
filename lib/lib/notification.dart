import 'package:intl/intl.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'db.dart';
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
      allowWhileIdle: true, preciseAlarm: true,
      year: schedule.year, month: schedule.month, day: schedule.day,
      hour: schedule.hour, minute: schedule.minute
    )
  );

  static Future<void> cancelNotification(String id) async =>
      await _instance.cancelSchedule(id.hashCode);

  static Future<void> cancelNotifications(List<String> channels) async =>
    await Future.wait(channels.map((channel) => _instance.cancelSchedulesByChannelKey(channel)));
}

Future<void> scheduleNotifications() async {
  final sem = await PrefStore.getSem();
  await NotificationController.cancelNotifications([
    NotificationController.CLASS_REMINDER_CHANNEL,
    NotificationController.EXAM_REMINDER_CHANNEL
  ]);

  String formatTime(Duration d) =>
      "${d.inHours.toString().padLeft(2, '0')}:${d.inMinutes.remainder(60).toString().padLeft(2, '0')}";

  final now = DateTime.now();
  final start = DateFormat('yyyyMMdd').format(now), end = DateFormat('yyyyMMdd').format(now.add(Duration(days: 7)));

  List<CalendarEntry> entries = [];
  List<ExamEntry> exams = [];
  for (var e in AcademicCalendar.getEntries(sem))
    if (e.date.compareTo(start) >= 0 && e.date.compareTo(end) <= 0)
      entries.add(e);

  for (var e in AcademicCalendar.getSchedule())
    if (e.date.compareTo(start) >= 0 && e.date.compareTo(end) <= 0)
      exams.add(e);

  final courses = Timetable(sem).getCourses();
  for (var entry in entries)
    for (var slot in entry.weekday != null ? getSchedule(courses, entry.weekday!) : [])
      NotificationController.showNotification(
        id: 'class_${entry.date}_${slot.start}',
        channel: NotificationController.CLASS_REMINDER_CHANNEL,
        title: 'Next Class: ${slot.entry.course.target!.name}',
        body: '${formatTime(slot.start)} - ${formatTime(slot.end)}',
        schedule: .parse(entry.date).add(slot.start - Duration(minutes: 15))
      );

  for (var exam in exams) {
    final parts = exam.from.split(":").map(int.parse).toList();
    NotificationController.showNotification(
      id: 'exam_${exam.id}',
      channel: NotificationController.EXAM_REMINDER_CHANNEL,
      schedule: .parse(exam.date).add(Duration(hours: parts[0], minutes: parts[1]) - Duration(minutes: 60)),
      title: 'Upcoming Exam: ${exam.course}',
      body: '${exam.venue}, ${exam.seatNo} (${exam.seatLoc})'
    );
  }
}