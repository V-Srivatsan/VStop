import 'package:vstop/lib/db.dart';
import 'package:vstop/lib/store.dart';
import 'package:vstop/lib/worker.dart';

Future<bool> syncData(int Function(int, String) update, bool partial) async {
  Database.clear(!partial);
  int p = 0, sem_update = 0;

  if (!partial) {
    p = update(15, "Figuring out who you are...");
    await fetchProfile();

    p = update(30, "Downloading your journey...");
    await CourseStore.fetch();
  }

  p = update(40, "Checking what you went through...");
  await SemStore.fetch();
  final sems = SemStore.getSems();
  await PrefStore.setSem(sems.first.code);

  final requests = <Future<void>>[];
  requests.add(CourseStore.fetchGradeHistory());

  requests.add(() async {
    p = update(50, "");
    sem_update = 20 ~/ sems.length;
    for (var sem in sems) {
      final timetable = Timetable(sem.code);
      p = update(p+sem_update, "Listing your studies in ${sem.name}...");
      await timetable.fetch();
      update(p, "Evaluating survival rate in ${sem.name}...");
      await timetable.fetchAttendance();
    }

    p = update(70, "");
    for (var sem in sems) {
      p = update(p+sem_update, "Gathering undisclosed marks...");
      await MarkStore(sem.code).fetch();
    }

    update(95, "Syncing academic trauma...");
    await MarkStore.syncToFirestore();
  }());

  requests.add(AcademicCalendar.fetch(sems.first.code));
  requests.add(AcademicCalendar.fetchExamSchedule(sems.first.code));

  await Future.wait(requests);
  executeTask(SCHEDULE_NOTIFICATIONS_TASK);
  update(100, "");
  return true;
}