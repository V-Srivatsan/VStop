import 'package:intl/intl.dart';
import 'package:vstop/lib/data/calendar.dart';
import 'package:vstop/lib/data/timetable.dart';
import 'package:vstop/lib/consts.dart';

Map<String, int> getSlotCounts(String sem) {
  final today = DateFormat("yyyyMMdd").format(DateTime.now());
  int? today_weekday;
  final counts = List.filled(5, 0);

  for (
    var entry in
    AcademicCalendar.getEntries(sem)
      .where((e) => e.entryType == .instructional && today.compareTo(e.date) <= 0)
  ) {
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
