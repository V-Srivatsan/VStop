import 'dart:math';
import 'package:universal_html/parsing.dart' show parseHtmlDocument;
import 'package:universal_html/universal_html.dart';
import 'package:vstop/lib/webview.dart';
import 'package:vstop/lib/store.dart';

import 'package:objectbox/objectbox.dart';
import 'package:vstop/objectbox.g.dart';
import 'package:vstop/lib/db.dart';

@Entity()
class Mark {
  int id;
  var entry = ToOne<TimetableEntry>();
  String title; double score, maxScore;

  Mark({ this.id = 0, required this.title, required this.score, required this.maxScore });
}

class MarkStore {
  static final Box<Mark> _box = Database.getBox<Mark>();

  final Semester sem;
  MarkStore(String code) : sem = SemStore.getSem(code)!;

  Map<Course, List<TimetableEntry>> getCourseMap() {
    final map = Timetable(sem.code).getCourseMap(), res = <Course, List<TimetableEntry>>{};
    for (var entry in map.entries) {
      final lst = entry.value.where((e) => e.marks.isNotEmpty || e.grade != null).toList();
      if (lst.isNotEmpty) res[entry.key] = lst;
    }

    return res;
  }

  Future<void> fetch() async {
    final entryBox = Database.getBox<TimetableEntry>();

    final existing = (_box.query()..link(Mark_.entry, TimetableEntry_.semester.equals(sem.id))).build().find();
    if (existing.isNotEmpty) _box.removeMany(existing.map((e) => e.id).toList());

    final marks_req = () async {
      final res = await WebView.request(
          "https://vtopcc.vit.ac.in/vtop/examinations/doStudentMarkView",
          { "semesterSubId": sem.code }
      );
      final doc = parseHtmlDocument(res);

      final rows = doc.querySelectorAll("table.customTable tr.tableContent");
      final List<Element> subj = [];
      for (int i=0; i < rows.length; i+=2) { subj.add(rows[i]); }

      final tables = doc.querySelectorAll("table.customTable-level1");
      List<Mark> all_marks = [];

      for (int i=0; i < subj.length; i++) {
        final classId = subj[i].children[1].text!.trim();
        TimetableEntry entry = entryBox.query(TimetableEntry_.classId.equals(classId)).build().findFirst()!;

        final marks = tables[i].querySelectorAll("tr.tableContent-level1");
        for (var mark in marks) {
          final title = mark.children[1].text!.trim();
          final maxScore = double.parse(mark.children[3].text!.trim());
          final score = double.parse(mark.children[6].text!.trim());

          Mark r = Mark(title: title, maxScore: maxScore, score: score);
          r.entry.target = entry;
          all_marks.add(r);
        }
      }

      _box.putMany(all_marks);
    }();
    final grades_req = () async {

      final currEntries = (entryBox.query()..link(TimetableEntry_.semester, Semester_.id.equals(sem.id))).build().find();
      for (int i=0; i < currEntries.length; i++) currEntries[i].grade = null;
      entryBox.putMany(currEntries);

      final res = await WebView.request(
        "https://vtopcc.vit.ac.in/vtop/examinations/examGradeView/doStudentGradeView",
        { "semesterSubId": sem.code }
      );

      final doc = parseHtmlDocument(res);
      final rows = doc.querySelectorAll("table tr:not([align='center'])");
      final List<TimetableEntry> entries = [];
      for (var row in rows.skip(2)) {
        final courseCode = row.children[1].text!.trim();
        final grade = row.children[10].text!.trim();

        final query = entryBox.query()
          ..link(TimetableEntry_.semester, Semester_.id.equals(sem.id))
          ..link(TimetableEntry_.course, Course_.code.equals(courseCode));
        final e = query.build().find();
        entries.addAll(e.map((e) { e.grade = grade; return e; }));
      }

      entryBox.putMany(entries);
    }();

    await Future.wait([marks_req, grades_req, CourseStore.fetchGradeHistory()]);
  }

  static Future<void> syncToFirestore([Map<Course, List<TimetableEntry>>? data]) async {
    final auth = (await SecureStorage.get("auth"))!;
    final aceGrading = await PrefStore.getACEGrading();

    List<Future<void>> tasks = [];

    if (data == null)
      for (var sem in SemStore.getSems())
        tasks.add(syncToFirestore(MarkStore(sem.code).getCourseMap()));
    else
      for (var course in data.keys)
        if (course.grade == null)
          tasks.add(() async {
            final grade = await getGrade(course: course, entries: data[course]!, user: auth, aceGrading: aceGrading);
            data[course] = data[course]!.map((e) { e.grade = '*$grade'; return e; }).toList();
          }());

    await Future.wait(tasks);
    if (data != null) (Database.getBox<TimetableEntry>()).putMany(data.values.fold([], (p, e) => p + e));
  }

  static void clear() => _box.removeAll();
}



Future<String> getGrade({
  required Course course, required List<TimetableEntry> entries,
  required String user, required bool aceGrading
}) async {
  final grading = course.getGrading(aceGrading);
  final score = course.getScore(entries, aceGrading);

  final double percent = score.$2 == 0 ? .nan : score.$1 / score.$2;
  if (percent == .nan) return "";

  if (grading == .relative) {
    final entry = entries.firstWhere((e) => !e.isLab);

    final snapshot = await entry.getCloudData();
    final marks = (snapshot.exists ? snapshot.data() as Map<String, dynamic> : <String, double>{});
    marks[user] = score.$1; entry.setCloudData(snapshot, { user: score.$1 });

    double avg = marks.values.fold(0.0, (p, m) => p+m) / marks.length;
    double std = sqrt(marks.values.fold(0.0, (p, m) => p + pow(m-avg, 2)) / marks.length);

    if (score.$1 >= (avg + 1.5*std) && percent >= 0.8) return "S";
    if (score.$1 >= (avg + 0.5*std)) return "A";
    if (score.$1 >= (avg - 0.5*std)) return "B";
    if (score.$1 >= (avg - 1.0*std)) return "C";
    if (score.$1 >= (avg - 1.5*std)) return "D";
    if (score.$1 >= (avg - 2.0*std)) return "E";
    return "F";
  }

  if (grading == .absolute) {
    if (percent >= 0.9) return "S";
    if (percent >= 0.8) return "A";
    if (percent >= 0.7) return "B";
    if (percent >= 0.6) return "C";
    if (percent >= 0.55) return "D";
    if (percent >= 0.5) return "E";
    return "F";
  }

  return percent >= 0.5 ? "P" : "N";
}