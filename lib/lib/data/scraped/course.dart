import 'package:objectbox/objectbox.dart';
import 'package:universal_html/parsing.dart';
import 'package:vstop/lib/webview.dart';
import 'package:vstop/objectbox.g.dart';
import 'package:vstop/lib/db.dart';

@Entity()
class CourseCategory {
  int id; String code;
  String name; double credits;
  CourseCategory({this.id = 0, required this.code, required this.name, this.credits = 0 });
}

enum GradingType { relative, absolute, ungraded }

@Entity()
class Course {
  int id;
  @Unique(onConflict: .replace) String code;
  String name; double credits;
  String type; String? grade;
  var category = ToOne<CourseCategory>();

  @Backlink('course')
  final entries = ToMany<TimetableEntry>();

  Course({this.id = 0, required this.code, required this.name, required this.type, required this.credits });

  GradingType getGrading(bool ace) => (
    type == "TH" ? .relative :
    type == "LO" || type == "PJT" ? .absolute :
    type == "OC" ? (ace ? .absolute : .ungraded) :
    (ace ? .relative : .absolute)
  );

  (double, double) getScore(List<TimetableEntry> entries, bool ace) {
    double total = 0, maxTotal = 0;
    double theoryFactor = 1;

    for (var entry in entries)
      if (!entry.isLab && entry.slots.isNotEmpty) {
        theoryFactor = (entry.slots.length + (entry.slots.first.length == 2 ? 1 : 0)) / credits;
        break;
      }

    for (var entry in entries) {
      final marks = entry.marks;
      if (marks.isEmpty) continue;

      double entryTotal = 0, entryMaxTotal = 0;
      for (var mark in entry.marks) { entryTotal += mark.score; entryMaxTotal += mark.maxScore; }

      double factor = 1;
      if (ace && getGrading(ace) == .relative)
        factor = (entry.isLab ? (1 - theoryFactor) : theoryFactor);

      total += entryTotal * factor;
      maxTotal += entryMaxTotal * factor;
    }

    return (total, maxTotal);
  }

  bool get completed => (
    grade != null && !grade!.startsWith('*') &&
    grade != 'F' && !grade!.contains('N')
  );

  @override bool operator ==(Object other) => (other is Course && code == other.code);
  @override int get hashCode => code.hashCode;
}

class CourseStore {
  static final Box<Course> _box = Database.getBox<Course>();
  static final Box<CourseCategory> _catBox = Database.getBox<CourseCategory>();

  static Course? getCourse(String code) => _box.query(Course_.code.equals(code)).build().findFirst();

  static Future<void> fetch() async {

    final listDoc = parseHtmlDocument(await WebView.request(
      "https://vtopcc.vit.ac.in/vtop/academics/common/Curriculum",
      { "verifyMenu": "true" }
    ));

    final List<CourseCategory> cats = [];
    final items = listDoc.querySelectorAll('.categoty-card .row');
    for (var item in items) {
      final data = item.innerText.split("\n").where((s) => s.trim().isNotEmpty).map((s) => s.trim()).toList();
      cats.add(CourseCategory(code: data[0], name: data[5], credits: .parse(data[4])));
    }
    _catBox.putMany(cats);

    final Map<String, CourseCategory> categories = .fromEntries(
        _catBox.getAll().map((c) => MapEntry(c.code, c))
    );
    final List<Future<void>> requests = [];

    for (String cat in categories.keys)
      requests.add(() async {
        final doc = parseHtmlDocument(await WebView.request(
          "https://vtopcc.vit.ac.in/vtop/academics/common/curriculumCategoryView",
          { "categoryId": cat }
        ));

        final rows = doc.querySelectorAll('table tbody tr');
        final List<Course> courses = [];
        for (var row in rows) {
          final course = Course(
            code: row.children[1].text!.trim(),
            name: row.children[2].text!.trim(),
            type: row.children[3].text!.trim(),
            credits: .parse(row.children[4].text!.trim())
          );
          course.category.target = categories[cat];
          courses.add(course);
        }

        _box.putMany(courses);
        print("Saved ${courses.length} courses in ${categories[cat]!.name}");
      }());

    await Future.wait(requests);
  }
  static Future<void> fetchGradeHistory() async {
    Map<String, Course> courseMap = .fromEntries(_box.getAll().map(
      (c) { c.grade = null; return MapEntry(c.code, c); }
    ));
    final gradeHistoryDoc = parseHtmlDocument(await WebView.request(
        "https://vtopcc.vit.ac.in/vtop/examinations/examGradeView/StudentGradeHistory",
        { "verifyMenu": "true" }
    ));

    final rows = (gradeHistoryDoc.querySelectorAll('table.customTable')[1])
      .querySelectorAll('tr.tableContent');

    for (var row in rows) {
      if (row.id.isNotEmpty) continue;
      final code = row.children[1].text!.trim();
      final grade = row.children[5].text!.trim();
      courseMap[code]!.grade = grade;
    }
    _box.putMany(courseMap.values.toList());
  }

  static List<CourseCategory> getCategories() => _catBox.getAll();
  static List<Course> getCoursesByCategory(int cat) => _box.query(Course_.category.equals(cat)).build().find();

  static void clear() { _box.removeAll(); _catBox.removeAll(); }

  static double getCGPA() {
    final courses = _box.getAll();
    double totalPoints = 0, totalCredits = 0;
    for (var course in courses) {
      final gp = getGradePoint(course.grade);
      if (gp != null) {
        totalPoints += gp * course.credits;
        totalCredits += course.credits;
      }
    }
    return totalCredits == 0 ? 0 : totalPoints / totalCredits;
  }
}

double? getGradePoint(String? grade) {
  if (grade == null || grade == "P" || grade == "N") return null;
  switch (grade) {
    case 'S': return 10.0;
    case 'A': return 9.0;
    case 'B': return 8.0;
    case 'C': return 7.0;
    case 'D': return 6.0;
    case 'E': return 5.0;
    default: return 0.0;
  }
}