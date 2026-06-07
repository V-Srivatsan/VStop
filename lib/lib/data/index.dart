import 'package:vstop/objectbox.g.dart';
import 'package:path_provider/path_provider.dart';

import 'sem.dart' show SemStore;
import 'assignments.dart' show AssignmentStore;
import 'calendar.dart' show AcademicCalendar;
import 'course.dart' show CourseStore;
import 'timetable.dart' show Timetable;
import 'marks.dart' show MarkStore;

class Database {
  static late Store _store;

  static Future<void> init() async {
    try { _store = await openStore(); }
    catch (e) {
      final dir = await getApplicationDocumentsDirectory();
      _store = Store.attach(getObjectBoxModel(), '${dir.path}/objectbox');
    }
  }
  static void close() => _store.close();

  static void clear([bool full = true]) {
    if (full) { CourseStore.clear(); AssignmentStore.clear(); }
    SemStore.clear(); AcademicCalendar.clear();
    Timetable.clear(); MarkStore.clear();
  }
  static Box<T> getBox<T>() => _store.box<T>();
}
