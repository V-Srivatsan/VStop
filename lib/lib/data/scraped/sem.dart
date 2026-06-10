import 'package:universal_html/parsing.dart' show parseHtmlDocument;
import 'package:vstop/lib/webview.dart';

import 'package:objectbox/objectbox.dart';
import 'package:vstop/objectbox.g.dart';
import 'package:vstop/lib/db.dart';

@Entity()
class Semester {
  int id;
  @Unique() String code;
  String name;

  Semester({ this.id = 0, required this.code, required this.name });
}

class SemStore {
  static final Box<Semester> _box = Database.getBox<Semester>();

  static Future<void> fetch() async {
    final sem = await WebView.request(
      "https://vtopcc.vit.ac.in/vtop/academics/common/StudentTimeTableChn",
      { "verifyMenu": "true" }
    );

    var doc = parseHtmlDocument(sem);
    final options = doc.querySelectorAll('#semesterSubId option:not([value=""])');

    final sems = Map.fromEntries(options.map((opt) =>
        MapEntry(opt.attributes["value"]!,  opt.text!.trim())
    ));

    _box.putMany(sems.entries.map((e) =>
      Semester(code: e.key, name: e.value)
    ).toList());
  }

  static List<Semester> getSems() => _box.getAll();
  static Semester? getSem(String code) => _box.query(Semester_.code.equals(code)).build().findFirst();

  static void clear() => _box.removeAll();
}