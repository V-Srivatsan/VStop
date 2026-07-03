import 'dart:math';
import 'package:vstop/lib/db.dart';
import 'package:vstop/lib/data/scraped/marks.dart' show getRelativeGrade;

final _box = Database.getBox<TimetableEntry>();

double normal(double avg, double sd, double x) {
  double z = (x-avg)/sd;
  return 1/(sd * sqrt(2 * pi)) * pow(e, -0.5 * pow(z, 2));
}

double estimateSD(double percent) => 3 + 9.5 / normal(0, pow(e,2).toDouble(), 0) * normal(67.5, pow(e,2).toDouble(), percent*100);
String getGrade(double avg, double sd, double score, double percent) => getRelativeGrade(avg, sd, score, percent);


(double, double, double) getStats(List<(TimetableEntry, List<double>)> data, bool ace) {
  final course = data.first.$1.course.target!;
  double score = 0, avg = 0, total = 0;
  final factor = course.getTheoryFactor(data.map((d) => d.$1).toList());

  for (var (entry, avgs) in data)
    for (var (idx, mark) in entry.marks.indexed) {
      if (avgs[idx] < 0) continue;
      final f = ace && entry.isLab ? (1 - factor) : factor;
      score += mark.score * f;
      avg += avgs[idx] * mark.maxScore * f / mark.maxMark;
      total += mark.maxScore * f;
    }

  return (score, avg, total);
}

String setGradeEstimate(List<TimetableEntry> entries, String grade) {
  if (!entries.any((e) => e.grade?.startsWith('*') ?? false))
    return "Cannot override V-Top Grades";
  _box.putMany(entries.map((e) { e.grade = '*$grade'; return e; }).toList());
  return "Grade estimate updated";
}