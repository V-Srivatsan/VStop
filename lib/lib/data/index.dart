import 'package:vstop/objectbox.g.dart';

import 'sem.dart' show SemStore;
import 'course.dart' show CourseStore;
import 'timetable.dart' show Timetable;
import 'marks.dart' show MarkStore;

class Database {
  static late Store _store;

  static Future<void> init() async => _store = await openStore();
  static void clear() {
    SemStore.clear(); CourseStore.clear();
    Timetable.clear(); MarkStore.clear();
  }
  static Box<T> getBox<T>() => _store.box<T>();
}
