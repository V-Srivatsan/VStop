import 'package:intl/intl.dart';
import 'package:vstop/lib/db.dart';

import 'package:vstop/lib/consts.dart';

Map<String, int> getSlotCounts(String sem) {
  final today = DateFormat("yyyyMMdd").format(DateTime.now());
  int? today_weekday;
  final counts = List.filled(5, 0);

  List<CalendarEntry> entries = [];
  for (var entry in AcademicCalendar.getEntries(sem)) {
    if (today.compareTo(entry.date) > 0) continue;
    if (entry.entryType == .exam) break;
    if (entry.entryType == .instructional) entries.add(entry);
  }

  for (var entry in entries) {
    counts[entry.weekday! - DateTime.monday]++;
    if (today == entry.date) today_weekday = entry.weekday! - DateTime.monday;
  }

  final slotCounts = <String, int>{};
  for (int i = 0; i < 5; i++) {
    if (counts[i] > 0)
      for (var slot in (slots[i].$1 + slots[i].$2))
        slotCounts[slot] = (slotCounts[slot] ?? 0) + counts[i];
  }
  if (today_weekday != null) {
    final now = DateTime.now(); final now_duration = Duration(hours: now.hour, minutes: now.minute);
    for (var i=0; i < 12; i++) {
      final tslot = slots[today_weekday].$1[i], lslot = slots[today_weekday].$2[i];
      if (theory[i].$1 < now_duration) slotCounts[tslot] = (slotCounts[tslot] ?? 1) - 1;
      if (lab[i].$1 < now_duration) slotCounts[lslot] = (slotCounts[lslot] ?? 1) - 1;
    }
  }
  return slotCounts;
}

int getSkippable(double thres, Map<String, int> slotCounts, {
  TimetableEntry? entry, int total_present = 0, int total_absent = 0
}) {
  int present = entry?.present.length ?? total_present;
  int total = (entry?.present.length ?? total_present) + (entry?.absent.length ?? total_absent);
  int extra = 0;

  if (entry != null)
    for (var slot in entry.slots)
      extra += slotCounts[slot] ?? 0;
  else
    extra = slotCounts.values.fold(0, (a, b) => a + b);

  int expected = (thres * (total + extra)).ceil();
  int res = (present + extra) - expected;

  return res >> (entry != null && entry.isLab ? 1 : 0);
}
