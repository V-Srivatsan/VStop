import 'package:vstop/objectbox.g.dart';
import 'package:path_provider/path_provider.dart';
import 'data/local/assignments.dart' show AssignmentStore;
import 'data/local/ffcs.dart' show TimetableDraft;
import 'data/scraped/sem.dart' show SemStore;
import 'data/scraped/calendar.dart' show AcademicCalendar;
import 'data/scraped/course.dart' show CourseStore;
import 'data/scraped/timetable.dart' show Timetable;
import 'data/scraped/marks.dart' show MarkStore;

export 'data/local/assignments.dart';
export 'data/local/ffcs.dart';
export 'data/scraped/calendar.dart';
export 'data/scraped/course.dart';
export 'data/scraped/marks.dart';
export 'data/scraped/profile.dart';
export 'data/scraped/sem.dart';
export 'data/scraped/timetable.dart';

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
    if (full) { CourseStore.clear(); AssignmentStore.clear(); TimetableDraft.clear(); }
    SemStore.clear(); AcademicCalendar.clear();
    Timetable.clear(); MarkStore.clear();
  }
  static Box<T> getBox<T>() => _store.box<T>();
}

