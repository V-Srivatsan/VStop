import 'package:vstop/lib/data/index.dart';
import 'package:vstop/lib/data/profile.dart';
import 'package:vstop/lib/data/sem.dart';
import 'package:vstop/lib/data/timetable.dart';
import 'package:vstop/lib/data/attendance.dart';
import 'package:vstop/lib/data/marks.dart';

import 'package:vstop/lib/store.dart';

Future<bool> syncData(int Function(int, String) update) async {
  int p = 0, sem_update = 0;
  Database.clear();

  p = update(15, "Figuring out who you are...");
  await fetchProfile();

  p = update(30, "Checking what you went through...");
  await SemStore.fetch();
  final sems = SemStore.getSems();
  await PrefStore.setSem(sems.first.code);

  p = update(50, "");
  sem_update = 5 ~/ sems.length;
  for (var sem in sems) {
    p = update(p+sem_update, "Listing your studies in ${sem.name}...");
    await Timetable(sem.code).fetch();
  }

  p = update(55, "");
  sem_update = 20 ~/ sems.length;
  for (var sem in sems) {
    p = update(p+sem_update, "Evaluating survivability rate...");
    await fetchAttendance(sem.code);
  }

  p = update(75, "");
  for (var sem in sems) {
    p = update(p+sem_update, "Gathering undisclosed marks...");
    await MarkStore(sem.code).fetch();
  }

  update(95, "Syncing academic trauma...");
  await MarkStore.syncToFirestore();

  update(100, "");
  return true;
}