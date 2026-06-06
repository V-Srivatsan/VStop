import 'package:intl/intl.dart';
import 'package:vstop/lib/data/calendar.dart';
import 'package:vstop/lib/data/timetable.dart';

import 'package:vstop/screens/app/home/timetable/consts.dart';

Map<String, int> getSlotCounts(String sem) {
  final today = DateFormat("yyyyMMdd").format(DateTime.now());
  final counts = List.filled(5, 0);

  for (
    var entry in
    AcademicCalendar.getEntries(sem)
      .where((e) => e.entryType == .instructional && today.compareTo(e.date) <= 0)
  ) {
    int idx;

    final weekday = DateTime.parse(entry.date).weekday;
    if (weekday != DateTime.saturday && weekday != DateTime.sunday) idx = weekday - DateTime.monday;
    else {
      if (entry.comment.contains("Mon")) idx = 0;
      if (entry.comment.contains("Tue")) idx = 1;
      if (entry.comment.contains("Wed")) idx = 2;
      if (entry.comment.contains("Thu")) idx = 3;
      idx = 4;
    }

    counts[idx]++;
  }

  final slotCounts = <String, int>{};
  for (int i = 0; i < 5; i++) {
    if (counts[i] > 0)
      for (var slot in (slots[i].$1 + slots[i].$2))
        slotCounts[slot] = (slotCounts[slot] ?? 0) + counts[i];
  }
  return slotCounts;
}

int getSkippable(TimetableEntry entry, double thres, Map<String, int> slotCounts) {
  int present = entry.present.length;
  int total = entry.present.length + entry.absent.length;
  int extra = 0;

  for (var slot in entry.slots)
    extra += slotCounts[slot] ?? 0;

  int expected = (thres * (total + extra)).ceil();
  int res = (present + extra) - expected;

  return res >> (entry.isLab ? 1 : 0);
}
