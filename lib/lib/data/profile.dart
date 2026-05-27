import 'dart:convert';
import 'package:universal_html/parsing.dart' show parseHtmlDocument;
import 'package:crypto/crypto.dart';
import 'package:vstop/lib/webview.dart';
import 'package:vstop/lib/store.dart';

const NICKNAMES = {};

Future<void> fetchProfile() async {
  final res = await WebView.request(
    "https://vtopcc.vit.ac.in/vtop/studentsRecord/StudentProfileAllView",
    { "verifyMenu": "true" }
  );
  final doc = parseHtmlDocument(res);
  
  final appNo = doc.querySelector('tbody td:nth-child(2)')!.text!.trim();
  final reg = doc.querySelector('label[for="no"]')!.text!.trim();

  final authBase = "$appNo:$reg";
  final authHash = sha256.convert(utf8.encode(authBase)).toString();
  await SecureStorage.set("auth", authHash);

  String name = doc.querySelector('.content .row div p')!.text!.trim();
  name = NICKNAMES[reg] ?? name;

  name = (name.length > 15 ? name.split(" ").first : name).toLowerCase();
  name = name.split(" ").map((s) => s[0].toUpperCase() + s.substring(1)).join(" ");

  await PrefStore.setName(name);
}