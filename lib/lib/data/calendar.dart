import 'package:intl/intl.dart';
import 'package:objectbox/objectbox.dart';
import 'package:universal_html/parsing.dart';
import 'package:vstop/objectbox.g.dart';

import 'package:vstop/lib/webview.dart';
import 'index.dart';
import 'sem.dart';

enum CalendarEntryType { holiday, exam, instructional }

@Entity()
class CalendarEntry {
  int id;
  final sem = ToOne<Semester>();
  @Unique() String date;
  String type, comment;
  CalendarEntry({ this.id = 0, required this.date, required this.type, required this.comment });

  CalendarEntryType get entryType => (
    type == "Instructional Day" ? .instructional :
    type == "Holiday" || type == "No Instructional Day" ? .holiday : .exam
  );

  int? get weekday {
    if (entryType != .instructional) return null;
    final dt = DateTime.parse(date);
    if (dt.weekday == DateTime.saturday || dt.weekday == DateTime.sunday) {
      if (comment.contains("Mon")) return DateTime.monday;
      if (comment.contains("Tue")) return DateTime.tuesday;
      if (comment.contains("Wed")) return DateTime.wednesday;
      if (comment.contains("Thu")) return DateTime.thursday;
      return DateTime.friday;
    }
    return dt.weekday;
  }
}

@Entity()
class ExamEntry {
  int id;
  final sem = ToOne<Semester>();
  String course, date;
  String from, to, venue, seatLoc, seatNo;
  ExamEntry({
    this.id = 0, required this.course, required this.date,
    required this.from, required this.to, required this.venue,
    required this.seatLoc, required this.seatNo
  });
}

class AcademicCalendar {

  static final _box = Database.getBox<CalendarEntry>();
  static final _examBox = Database.getBox<ExamEntry>();

  static Future<void> fetch(String semCode) async {
    final sem = SemStore.getSem(semCode)!;
    _box.removeMany(_box.query(CalendarEntry_.sem.equals(sem.id)).build().findIds());

    final previewDoc = parseHtmlDocument(await WebView.request(
      "https://vtopcc.vit.ac.in/vtop/getDateForSemesterPreview",
      { "semSubId": semCode, "paramReturnId": "getDateForSemesterPreview" }
    ));

    final months = previewDoc.querySelectorAll('div#getListForSemester a');
    List<Future<void>> requests = [
      for (var month in months)
        (String month) async {
          month = '${month.substring(0, 1)}${month.toLowerCase().substring(1)}';
          final res = parseHtmlDocument(await WebView.request(
            "https://vtopcc.vit.ac.in/vtop/processViewCalendar",
            { "semSubId": semCode, "classGroupId": "ALL", "calDate": "01-${month.toUpperCase()}"  }
          ));
          final rows = res.querySelectorAll('table.calendar-table tr:not(:first-child)');

          final dates = <CalendarEntry>[];
          for (var row in rows) {
            for (var date in row.children) {
              final info = date.querySelectorAll('span');
              if (info.length < 3) continue;

              final dateStr = DateFormat('yyyyMMdd').format(DateFormat('dd-MMM-yyyy').parse('${info[0].innerText}-$month'));
              final type = info[1].innerText.split("-").first.trim();
              String comment = info[2].innerText; comment = comment.substring(1, comment.length-1);

              final entry = CalendarEntry(date: dateStr, type: type, comment: comment); entry.sem.target = sem;
              dates.add(entry);
            }
          }

          _box.putMany(dates);
        }(month.innerText.trim())
    ];

    await Future.wait(requests);
  }

  static Future<void> fetchExamSchedule(String semCode) async {
    final sem = SemStore.getSem(semCode)!;
    _examBox.removeMany(_examBox.query(ExamEntry_.sem.equals(sem.id)).build().findIds());

    final res = parseHtmlDocument(await WebView.request(
      "https://vtopcc.vit.ac.in/vtop/examinations/doSearchExamScheduleForStudent",
      { "semesterSubId": semCode }
    ));

    final rows = res.querySelectorAll('table.customTable tr.tableContent');
    final entries = <ExamEntry>[];
    for (var row in rows) {
      if (row.children.length == 1) continue;

      final title = row.children[2].innerText.trim();
      final date = DateFormat("yyyyMMdd").format(DateFormat("dd-MMM-yyyy").parse(row.children[6].innerText.trim()));
      final time = row.children[9].innerText.trim().split("-");
      final venue = row.children[10].innerText.trim(); final seatLoc = row.children[11].innerText.trim();
      final seatNo = row.children[12].innerText.trim();

      final entry = ExamEntry(
        course: title, date: date,
        from: DateFormat("HH:mm").format(DateFormat("hh:mm a").parse(time.first.trim())),
        to: DateFormat("HH:mm").format(DateFormat("hh:mm a").parse(time.last.trim())),
        venue: venue, seatLoc: seatLoc, seatNo: seatNo
      ); entry.sem.target = sem;
      entries.add(entry);
    }
    _examBox.putMany(entries);
  }

  static List<CalendarEntry> getEntries([String? sem]) {
    final query = _box.query();
    if (sem != null) query.link(CalendarEntry_.sem, Semester_.code.equals(sem));
    query.order(CalendarEntry_.date);
    return query.build().find();
  }
  static List<ExamEntry> getSchedule() => _examBox.query().order(ExamEntry_.from).build().find();
  static void clear() { _box.removeAll(); _examBox.removeAll(); }
}