import 'package:objectbox/objectbox.dart';
import 'package:vstop/objectbox.g.dart';
import 'index.dart';

@Entity()
class CourseCategory {
  int id;
  String name; double credits;
  CourseCategory({this.id = 0, required this.name, this.credits = 0 });
}

@Entity()
class Course {
  int id;
  @Unique() String code;
  String name; double credits;
  var category = ToOne<CourseCategory>();

  Course({this.id = 0, required this.code, required this.name, required this.credits });
  bool isRelativeGraded() => code.endsWith("L");
}

class CourseStore {
  static final Box<Course> _box = Database.getBox<Course>();
  static final Box<CourseCategory> _catBox = Database.getBox<CourseCategory>();

  static Course? getCourse(String code) => _box.query(Course_.code.equals(code)).build().findFirst();

  static void addCourse(Course course) async {
    final cat = _catBox.query(CourseCategory_.name.equals(course.category.target!.name)).build().findFirst();
    if (cat != null) course.category.target = cat;
    _box.put(course);
  }

  static Map<String, List<Course>> getCoursesByCategory() {
    final courses = _box.getAll();
    final Map<String, List<Course>> categorized = {};
    for (var course in courses) {
      categorized.putIfAbsent(course.category.target!.name, () => []).add(course);
    }
    return categorized;
  }

  static void clear() { _box.removeAll(); _catBox.removeAll(); }
}