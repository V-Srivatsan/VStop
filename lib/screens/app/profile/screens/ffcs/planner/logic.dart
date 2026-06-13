import 'package:vstop/lib/db.dart';

bool recurse(
  List<TimetableDraft> res, TimetableDraft draft,
  {required Map<String, List<FFCSCourse>> courses, int skip = 0, bool all = false}
) {
  if (skip == courses.keys.length) { res.add(.copy(draft)); return true; }
  final key = courses.keys.skip(skip).first;

  bool found = false;
  for (var course in courses[key]!)
    if (draft.add(course)) {
      found = recurse(res, draft, courses: courses, skip: skip + 1, all: all) || found;
      draft.remove(course);
    }

  return (found || !all);
}

List<TimetableDraft> makeDrafts(Map<String, List<FFCSCourse>> courseMap) {
  final res = <TimetableDraft>[];
  recurse(res, TimetableDraft(), courses: courseMap, all: true);
  return res;
}