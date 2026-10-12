import 'package:vstop/lib/db.dart';
import 'package:vstop/lib/store.dart';
import 'package:vstop/lib/worker.dart';

Future<bool> syncData(int Function(int, String) update, bool partial) async {
  try {
    Database.clear(!partial);
    int p = 0, sem_update = 0;

    if (!partial) {
      try {
        p = update(15, "Figuring out who you are...");
        await fetchProfile();
      } catch (e) {
        print("fetchProfile error: $e");
      }

      try {
        p = update(30, "Downloading your journey...");
        await CourseStore.fetch();
      } catch (e) {
        print("CourseStore fetch error: $e");
      }
    }

    p = update(40, "Checking what you went through...");
    try {
      await SemStore.fetch();
    } catch (e) {
      print("SemStore fetch error: $e");
    }
    final sems = SemStore.getSems();
    if (sems.isNotEmpty) {
      await PrefStore.setSem(sems.first.code);
    }

    final requests = <Future<void>>[];
    requests.add(() async {
      try {
        await CourseStore.fetchGradeHistory();
      } catch (e) {
        print("fetchGradeHistory error: $e");
      }
    }());

    if (sems.isNotEmpty) {
      requests.add(() async {
        p = update(50, "");
        sem_update = 20 ~/ sems.length;
        for (var sem in sems) {
          try {
            final timetable = Timetable(sem.code);
            p = update(p + sem_update, "Listing your studies in ${sem.name}...");
            await timetable.fetch();
            update(p, "Evaluating survival rate in ${sem.name}...");
            await timetable.fetchAttendance();
          } catch (e) {
            print("Timetable fetch error for ${sem.name}: $e");
          }
        }

        p = update(70, "");
        for (var sem in sems) {
          try {
            p = update(p + sem_update, "Gathering undisclosed marks...");
            await MarkStore(sem.code).fetch();
          } catch (e) {
            print("MarkStore fetch error for ${sem.name}: $e");
          }
        }

        try {
          update(95, "Syncing academic trauma...");
          await MarkStore.syncToFirestore();
        } catch (e) {
          print("Firestore sync error: $e");
        }
      }());

      requests.add(() async {
        try {
          await AcademicCalendar.fetch(sems.first.code);
        } catch (e) {
          print("AcademicCalendar fetch error: $e");
        }
      }());

      requests.add(() async {
        try {
          await AcademicCalendar.fetchExamSchedule(sems.first.code);
        } catch (e) {
          print("AcademicCalendar exam schedule fetch error: $e");
        }
      }());
    }

    await Future.wait(requests);
    try {
      executeTask(SCHEDULE_NOTIFICATIONS_TASK);
    } catch (e) {
      print("Notification task scheduling error: $e");
    }
    return true;
  } catch (e, stack) {
    print("General syncData error: $e\n$stack");
    return false;
  } finally {
    update(100, "");
  }
}