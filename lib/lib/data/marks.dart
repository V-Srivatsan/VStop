import 'dart:math';
import 'package:universal_html/parsing.dart' show parseHtmlDocument;
import 'package:universal_html/universal_html.dart';
import 'package:vstop/lib/webview.dart';
import 'package:vstop/lib/store.dart' show SecureStorage;

import 'package:objectbox/objectbox.dart';
import 'package:vstop/objectbox.g.dart';
import 'index.dart';
import 'sem.dart';
import 'timetable.dart';
import 'firestore.dart';

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

  Future<void> fetch() async {
    final entryBox = Database.getBox<TimetableEntry>();
    final existing = getMarks().values;
    if (existing.isNotEmpty)
      _box.removeMany(existing.reduce((p, e) => p+e).map((m) => m.id).toList());

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

        final query = entryBox.query()..link(TimetableEntry_.course, Course_.code.equals(courseCode));
        final e = query.build().find();
        entries.addAll(e.map((e) { e.grade = grade; return e; }));
      }

      entryBox.putMany(entries);
    }();

    await Future.wait([marks_req, grades_req]);
  }

  Map<String, List<Mark>> getMarks() {
    final query = _box.query(); query.link(Mark_.entry, TimetableEntry_.semester.equals(sem.id));
    final marks = query.order(Mark_.title).build().find();

    Map<String, List<Mark>> res = {};
    for (var mark in marks) {
      final classId = mark.entry.target!.classId;
      if (res[classId] == null) res[classId] = [mark];
      else res[classId]!.add(mark);
    }

    return res;
  }

  static Future<void> syncToFirestore([List<Mark>? data]) async {
    final firestore = Firestore("marks");
    final auth = (await SecureStorage.get("auth"))!;

    data ??= _box.getAll();

    final Map<String, (double, double)> marks = {};
    final Map<String, TimetableEntry> tt_entries = {};

    for (Mark mark in data) {
      final classId = mark.entry.target!.classId;
      final curr = marks.putIfAbsent(classId, () => (0.0, 0.0));
      marks[classId] = (curr.$1 + mark.score, curr.$2 + mark.maxScore);

      tt_entries[classId] = mark.entry.target!;
    }

    List<TimetableEntry> modified = [];
    for (String classId in marks.keys) {

      final entry = tt_entries[classId]!; final course = entry.course.target!;
      if (entry.grade != null) continue;
      Map<String, dynamic>? markData;

      if (course.isRelativeGraded()) {
        final snapshot = await firestore.getDoc(classId);

        markData = {};
        if (snapshot.exists) { markData = snapshot.data() as Map<String, dynamic>; }
        markData[auth] = marks[classId]!.$1;

        await firestore.setDoc(snapshot, { auth: marks[classId]!.$1 });
      }

      entry.grade = getGrade(
        courseCode: course.code, entries: markData,
        score: marks[classId]!.$1, maxScore: marks[classId]!.$2
      ); modified.add(entry);
    }

    (Database.getBox<TimetableEntry>()).putMany(modified);
  }

  static void clear() => _box.removeAll();
}



String getGrade({
  required String courseCode, required double score, required double maxScore,
  Map<String, dynamic>? entries
}) {
  final percent = score / maxScore;

  if (courseCode.endsWith("L")) {
    final data = entries!.values.toList();

    double avg = 0;
    for (double i in data) avg += i;
    avg /= data.length;

    double d2 = 0;
    for (double i in data) d2 += (i-avg)*(i-avg);
    double std = sqrt(d2/data.length);

    if (score >= (avg + 1.5*std) && percent >= 0.8) return "S";
    if (score >= (avg + 0.5*std)) return "A";
    if (score >= (avg - 0.5*std)) return "B";
    if (score >= (avg - 1.0*std)) return "C";
    if (score >= (avg - 1.5*std)) return "D";
    if (score >= (avg - 2.0*std)) return "E";
    return "F";
  }

  if (courseCode.endsWith("P") || courseCode.endsWith("E")) {
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