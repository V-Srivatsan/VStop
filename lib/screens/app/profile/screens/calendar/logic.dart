import 'package:vstop/lib/db.dart';
import 'package:vstop/lib/worker.dart';
import 'package:vstop/lib/store.dart';

Future<void> syncCalendar() async {
  final sem = await PrefStore.getSem();
  await Future.wait([AcademicCalendar.fetch(sem), AcademicCalendar.fetchExamSchedule(sem)]);
  executeTask(SCHEDULE_NOTIFICATIONS_TASK);
}

List<CalendarEntry> getEntries() => AcademicCalendar.getEntries();
List<ExamEntry> getExams() => AcademicCalendar.getSchedule();