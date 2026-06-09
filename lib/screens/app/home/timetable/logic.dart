import 'package:intl/intl.dart';
import 'package:vstop/lib/data/timetable.dart';
import 'package:vstop/lib/data/calendar.dart';
import 'package:vstop/lib/consts.dart' as consts;

class ScheduleClass {
  final TimetableEntry entry;
  final Duration start, end;
  const ScheduleClass(this.entry, this.start, this.end);

  String getTime() {

    String format(Duration d) => (
      '${d.inHours.toString().padLeft(2, '0')}:${d.inMinutes.remainder(60).toString().padLeft(2, '0')}'
    );

    return '${format(start)} - ${format(end)}';
  }
}

int? getTodayWeekday() {
  final today = DateFormat("yyyyMMdd").format(DateTime.now());
  for (var e in AcademicCalendar.getEntries())
    if (e.date == today) return e.weekday;
  return null;
}

List<ScheduleClass> getSchedule(List<TimetableEntry> entries, int weekday) {
  if (weekday == DateTime.saturday || weekday == DateTime.sunday) return [];
  weekday -= DateTime.monday; List<ScheduleClass> schedule = [];

  final slots = consts.slots[weekday];

  for (int i=0; i < 12; i++) {
    for (var entry in entries) {
      if (entry.slots.contains(slots.$1[i]))
        schedule.add(ScheduleClass(entry, consts.theory[i].$1, consts.theory[i].$2));

      else if (entry.slots.contains(slots.$2[i]))
        schedule.add(ScheduleClass(entry, consts.lab[i].$1, consts.lab[i].$2));
    }
  }

  for (int i=1; i < schedule.length; i++) {
    if (schedule[i].start == schedule[i-1].end) {
      schedule[i-1] = ScheduleClass(schedule[i].entry, schedule[i-1].start, schedule[i].end);
      schedule.removeAt(i); i--;
    }
  }

  return schedule;
}