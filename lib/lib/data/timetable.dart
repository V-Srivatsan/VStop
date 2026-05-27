import 'package:universal_html/parsing.dart' show parseHtmlDocument;
import 'package:vstop/lib/webview.dart';

import 'package:objectbox/objectbox.dart';
import 'package:vstop/objectbox.g.dart';
import 'index.dart';
import 'course.dart';
import 'sem.dart';

@Entity()
class TimetableEntry {
  int id;
  var course = ToOne<Course>();
  var semester = ToOne<Semester>();
  @Unique() String classId;
  List<String> slots; String? venue;

  List<String> present, absent;
  String? grade;

  TimetableEntry({
    this.id = 0, required this.classId, required this.venue, this.grade,
    this.slots = const [], this.present = const [], this.absent = const []
  });

  double get percentage {
    final total = present.length + absent.length;
    if (total == 0) return .nan;
    return present.length / total;
  }
}


class Timetable {
  static final _box = Database.getBox<TimetableEntry>();
  final Semester sem;
  Timetable(String code) : sem = SemStore.getSem(code)!;

  static void clear() => _box.removeAll();

  Future<void> fetch() async {
    final res = await WebView.request(
        "https://vtopcc.vit.ac.in/vtop/processViewTimeTable",
        {"semesterSubId": sem.code}
    );

    final doc = parseHtmlDocument(res);
    final rows = doc.querySelectorAll("table:not(#timeTableStyle) tr:not(:first-child):not(:last-child)");

    List<TimetableEntry> entries = [];
    Map<String, double> seen_creds = {};

    for (var row in rows) {
      final children = row.children;
      if (children.length != 12) continue;

      final uid = (children[2].text!.trim()).split(" - ");
      final credits = double.parse(children[3].text!.trim().split(" ").last);
      final cat = children[4].text!.split('(').first.trim();

      final course = Course(
          code: uid[0].trim(),
          name: uid[1].split('(').first.trim(), credits: credits
      );
      course.category.target = CourseCategory(name: cat);
      if (seen_creds[course.code] != null) {
        course.credits += seen_creds[course.code]!;

        final dbCourse = CourseStore.getCourse(course.code);
        if (dbCourse != null) course.id = dbCourse.id;

        seen_creds[course.code] = course.credits;
      } else seen_creds[course.code] = course.credits;
      CourseStore.addCourse(course);

      final loc = children[7].text!.trim().split("-");
      final slots = loc.length == 3 ? loc.first.trim().split("+") : null;
      final venue = loc.length == 3 ? '${loc[1].trim()}-${loc[2].trim()}' : null;

      final entry = TimetableEntry(
        classId: children[6].text!.trim(),
        slots: slots ?? [], venue: venue
      );
      entry.semester.target = sem; entry.course.target = course;
      entries.add(entry);
    }

    _box.putMany(entries);
  }

  List<TimetableEntry> getCourses() {
    final query = _box.query(TimetableEntry_.semester.equals(sem.id)).build();
    final res = query.find();
    query.close();
    return res;
  }
}