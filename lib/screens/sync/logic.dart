import 'package:vstop/lib/data/index.dart';
import 'package:vstop/lib/data/profile.dart';
import 'package:vstop/lib/data/course.dart';
import 'package:vstop/lib/data/sem.dart';
import 'package:vstop/lib/data/timetable.dart';
import 'package:vstop/lib/data/attendance.dart';
import 'package:vstop/lib/data/marks.dart';
import 'package:vstop/lib/data/calendar.dart';

import 'package:vstop/lib/store.dart';
import 'package:vstop/lib/notification.dart';

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
    sem_update = 5 ~/ sems.length;
    for (var sem in sems) {
      p = update(p+sem_update, "Listing your studies in ${sem.name}...");
      await Timetable(sem.code).fetch();
    }

    p = update(55, "");
    sem_update = 15 ~/ sems.length;
    for (var sem in sems) {
      p = update(p+sem_update, "Evaluating survivability rate...");
      await fetchAttendance(sem.code);
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
  await scheduleDailyNotifications(true);
  update(100, "");
  return true;
}