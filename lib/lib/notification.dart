import 'package:awesome_notifications/awesome_notifications.dart';

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
      hour: schedule.hour, minute: schedule.minute, second: schedule.second
    )
  );

  static Future<void> cancelNotification(String id) async =>
      await _instance.cancelSchedule(id.hashCode);

}