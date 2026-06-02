import 'package:intl/intl.dart';
import 'package:objectbox/objectbox.dart';
import 'package:universal_html/parsing.dart';
import 'package:vstop/objectbox.g.dart';

import 'package:vstop/lib/webview.dart';
import 'index.dart';
import 'sem.dart';

@Entity()
class CalendarEntry {
  int id;
  @Unique() String date;
  String type, comment;
  CalendarEntry({ this.id = 0, required this.date, required this.type, required this.comment });
}


class AcademicCalendar {

  static final _box = Database.getBox<CalendarEntry>();

  static Future<void> fetch() async {
    _box.removeAll();
    final semCode = SemStore.getSems().first.code;

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
              dates.add(CalendarEntry(date: dateStr, type: type, comment: comment));
            }
          }

          _box.putMany(dates);
        }(month.innerText.trim())
    ];

    await Future.wait(requests);
  }

  static List<CalendarEntry> get() => _box.getAll();
}