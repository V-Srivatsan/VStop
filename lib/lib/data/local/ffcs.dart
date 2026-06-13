import 'package:objectbox/objectbox.dart';
import 'package:vstop/lib/db.dart';
import 'package:vstop/lib/consts.dart';

@Entity()
class FFCSCourse {
  int id;
  String code, name, faculty;
  List<String> slots;
  FFCSCourse({this.id = 0, required this.code, required this.name, required this.faculty, required this.slots});
}

@Entity()
class FFCSDraft {
  int id;
  String name;
  List<Map<String, dynamic>> courses;
  FFCSDraft({this.id = 0, required this.name, required this.courses});
}

class TimetableDraft {
  static final _box = Database.getBox<FFCSDraft>();

  static List<TimetableDraft> getAll() => _box.getAll().map((d) => TimetableDraft()..parse(d)).toList();
  void delete() => draft == null ? null : _box.remove(draft!.id);
  static void clear() { _box.removeAll(); Database.getBox<FFCSCourse>().removeAll(); }

  FFCSDraft? draft;
  late final List<FFCSCourse> courses;
  late final List<List<FFCSCourse?>> selected;

  TimetableDraft() {
    courses = [];
    selected = List.generate(5, (_) => List.filled(12, null, growable: false), growable: false);
  }

  TimetableDraft.copy(TimetableDraft draft) {
    courses = draft.courses.toList();
    selected = draft.selected.map((e) => e.toList()).toList();
  }

  void parse(FFCSDraft draft) {
    this.draft = draft;
    for (var course in draft.courses)
      add(FFCSCourse(
        code: course['code'], name: course['name'], faculty: course['faculty'],
        slots: List<String>.from(course['slots'])
      ));
  }

  void save(String name) {
    draft = FFCSDraft(name: name, courses: courses.map((c) => {
      'code': c.code, 'name': c.name, 'faculty': c.faculty, 'slots': c.slots
    }).toList());
    _box.put(draft!);
  }

  bool add(FFCSCourse course) {
    for (var slot in course.slots)
      for (var loc in slot_loc[slot]!)
        if (selected[loc.$1][loc.$2] != null) return false;

    for (var slot in course.slots)
      for (var loc in slot_loc[slot]!)
        selected[loc.$1][loc.$2] = course;

    courses.add(course); return true;
  }

  void remove(FFCSCourse course) {
    for (var slot in course.slots)
      for (var loc in slot_loc[slot]!)
        selected[loc.$1][loc.$2] = null;

    courses.remove(course);
  }
}