import 'package:awesome_notifications/awesome_notifications.dart';

class NotificationController {

  static final _instance = AwesomeNotifications();

  static const GENERAL_CHANNEL = 'general';
  static const CLASS_REMINDER_CHANNEL = 'class_reminder';
  static const EXAM_REMINDER_CHANNEL = 'exam_reminder';
  static const ASSIGNMENT_REMINDER_CHANNEL = 'assignment_reminder';

  static Future<void> initialize() async => await _instance.initialize(
    'resource://drawable/logo',
    [
      NotificationChannel(
        channelKey: GENERAL_CHANNEL, channelName: 'General',
        channelDescription: 'Miscellaneous notifications',
        playSound: true, locked: true
      ),
      NotificationChannel(
        channelKey: CLASS_REMINDER_CHANNEL, channelName: 'Class Reminders',
        channelDescription: 'Reminders for your classes', channelGroupKey: 'reminders',
        playSound: true, channelShowBadge: true
      ),
      NotificationChannel(
        channelKey: EXAM_REMINDER_CHANNEL, channelName: 'Exam Reminders',
        channelDescription: 'Reminders for your upcoming exams', channelGroupKey: 'reminders',
        playSound: true, channelShowBadge: true
      ),
      NotificationChannel(
        channelKey: ASSIGNMENT_REMINDER_CHANNEL, channelName: 'Assignment Reminders',
        channelDescription: 'Reminders for pending assignments', channelGroupKey: 'reminders',
        playSound: true, channelShowBadge: true
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

  static Future<void> clearNotification(String id) => _instance.dismiss(id.hashCode);
  static Future<void> cancelNotification(String id) => _instance.cancelSchedule(id.hashCode);

  static Future<void> cancelNotifications(List<String> channels) =>
      Future.wait(channels.map((channel) => _instance.cancelSchedulesByChannelKey(channel)));
}