import 'package:objectbox/objectbox.dart';
import 'package:universal_html/parsing.dart';
import 'package:vstop/lib/webview.dart';
import 'package:vstop/objectbox.g.dart';
import 'index.dart';
import 'timetable.dart' show TimetableEntry;

@Entity()
class CourseCategory {
  int id; String code;
  String name; double credits;
  CourseCategory({this.id = 0, required this.code, required this.name, this.credits = 0 });
}

@Entity()
class Course {
  int id;
  @Unique(onConflict: .replace) String code;
  String name; double credits;
  String type;
  var category = ToOne<CourseCategory>();

  @Backlink('course')
  final entries = ToMany<TimetableEntry>();

  Course({this.id = 0, required this.code, required this.name, required this.type, required this.credits });

  bool isRelativeGraded() => code.endsWith("L");

  bool get completed => entries.any((e) => (
    e.grade != null && !e.grade!.startsWith('*') &&
    e.grade != 'F' && e.grade != 'N'
  ));
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

  static List<CourseCategory> getCategories() => _catBox.getAll();
  static List<Course> getCoursesByCategory(int cat) => _box.query(Course_.category.equals(cat)).build().find();

  static void clear() { _box.removeAll(); _catBox.removeAll(); }
}