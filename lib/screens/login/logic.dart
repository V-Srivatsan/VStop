import 'dart:convert';
import 'dart:typed_data';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:vstop/lib/webview.dart';
import 'package:vstop/lib/store.dart' show SecureStorage;
import 'cnn.dart';

Future<Uint8List?> getCaptcha() async {
  final src = (await WebView.controller!.evaluateJavascript(
      source: "document.querySelector('#captchaBlock img')?.src"
  )).toString();
  if (src == "null") return null;

  final String base64String = src.contains(',') ? src.split(',').last : src;
  final normalized = base64String.replaceAll(RegExp(r'[\s"]'), '');
  final padded = normalized.padRight(normalized.length + (4 - normalized.length % 4) % 4, '=');
  return base64Decode(padded);
}

Future<String> getCaptchaStr(Uint8List bytes) async {
  await CaptchaDecoder.init();
  return await CaptchaDecoder.decode(bytes);
}

void free() => CaptchaDecoder.close();

Future<String?> getLoginError() async {
  final error = (await WebView.controller!.evaluateJavascript(
      source: "document.querySelector('span[role=\"alert\"]')?.innerText"
  )) as String;
  return error == "null" ? null : error.trim();
}


void login(String username, String password, [String? captcha]) async {
  await WebView.controller!.evaluateJavascript(source: """
    document.getElementById('username').value = '$username';
    document.getElementById('password').value = '$password';
  """);

  if (captcha != null)
    await WebView.controller!.evaluateJavascript(source: "document.getElementById('captchaStr').value = '$captcha';");

  await WebView.controller!.evaluateJavascript(source: "document.getElementById('submitBtn').click();");
}

Future<(String, String)?> getCred() async {
  final username = await SecureStorage.get("username");
  final password = await SecureStorage.get("password");
  if (username == null || password == null) return null;
  return (username, password);
}

Future<void> saveCred(String username, String password) async {
  await SecureStorage.set("username", username);
  await SecureStorage.set("password", password);
  await SecureStorage.set("syncVersion", (await PackageInfo.fromPlatform()).version);
}