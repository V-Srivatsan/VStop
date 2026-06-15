import 'package:intl/intl.dart';
import 'package:vstop/lib/db.dart';
import 'package:vstop/lib/store.dart';
import 'package:vstop/lib/worker.dart';
import 'package:vstop/lib/notification.dart';
import 'package:vstop/screens/app/home/timetable/logic.dart' show getSchedule;

Future<void> scheduleNotifications() async {
  final String sem;
  try { sem = await PrefStore.getSem(); }
  catch (e) { return; }
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
        schedule: .parse(exam.date).add(Duration(hours: parts[0], minutes: parts[1]) - Duration(minutes: 30)),
        title: 'Upcoming Exam: ${exam.course}',
        body: '${exam.venue}, ${exam.seatNo} (${exam.seatLoc})'
    );
  }

  executeTask(
    SCHEDULE_NOTIFICATIONS_TASK,
    delay: Duration(days: 1) - Duration(hours: now.hour, minutes: now.minute, seconds: now.second)
  );
}