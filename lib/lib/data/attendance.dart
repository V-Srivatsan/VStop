import 'package:intl/intl.dart';
import 'package:universal_html/parsing.dart' show parseHtmlDocument;
import 'package:vstop/lib/webview.dart';

import 'index.dart';
import 'timetable.dart';

Future<void> fetchAttendance(String sem) async {
  final entries = Map<String, TimetableEntry>.fromEntries(
    Timetable(sem).getCourses().map((entry) => MapEntry(entry.classId, entry))
  );

  // This request "fixes" the session issue
  // The session has to request a semester timetable before requested detailed view
  await WebView.request(
    "https://vtopcc.vit.ac.in/vtop/processViewStudentAttendance",
    { "semesterSubId": sem }
  );

  List<Future<void>> requests = [];

  for (String classId in entries.keys) {
    if (entries[classId]!.slots.isEmpty) continue;

    entries[classId]!.present = []; entries[classId]!.absent = [];

    requests.add(() async {
      final res = await WebView.request(
          "https://vtopcc.vit.ac.in/vtop/processViewAttendanceDetail",
          { "classId": classId, "slotName": entries[classId]!.slots.join("+") }
      );
      final doc = parseHtmlDocument(res);
      final rows = doc.querySelectorAll('table tbody tr');
      for (var row in rows) {
        final date = DateFormat("yyyyMMdd")
            .format(DateFormat("dd-MMM-yyyy").parse(row.children[1].text!.trim()));

        final od = row.children[4].text!.trim()[0] == "O";
        final present = row.children[4].text!.trim()[0] == "P";

        final slots = row.children[2].text!.trim().split("+").length;
        if (present || od)
          for (int i=0; i < slots; i++) entries[classId]!.present.add('$date${od ? '.' : ""}');
        else
          for (int i=0; i < slots; i++) entries[classId]!.absent.add(date);
      }
    }());
  }

  await Future.wait(requests);
  Database.getBox<TimetableEntry>().putMany(entries.values.toList());
}
