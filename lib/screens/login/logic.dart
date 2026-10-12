import 'dart:convert';
import 'dart:typed_data';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:vstop/lib/webview.dart';
import 'package:vstop/lib/store.dart' show SecureStorage;
import 'cnn.dart';

Future<Uint8List?> getCaptcha() async {
  try {
    final res = await WebView.controller?.evaluateJavascript(
        source: "document.querySelector('#captchaBlock img')?.src"
    );
    if (res == null || res == "null") return null;
    final String src = res.toString();
    if (src.isEmpty || !src.contains(',')) return null;

    final String base64String = src.split(',').last;
    final normalized = base64String.replaceAll(RegExp(r'[\s"]'), '');
    final padded = normalized.padRight(normalized.length + (4 - normalized.length % 4) % 4, '=');
    return base64Decode(padded);
  } catch (e) {
    print("getCaptcha error: $e");
    return null;
  }
}

Future<String> getCaptchaStr(Uint8List bytes) async {
  await CaptchaDecoder.init();
  return await CaptchaDecoder.decode(bytes);
}

void free() => CaptchaDecoder.close();

Future<String?> getLoginError() async {
  try {
    final res = await WebView.controller?.evaluateJavascript(
        source: "document.querySelector('span[role=\"alert\"]')?.innerText"
    );
    if (res == null || res == "null") return null;
    return res.toString().trim();
  } catch (_) {
    return null;
  }
}


void login(String username, String password, [String? captcha]) async {
  final safeUser = username.replaceAll("'", "\\'");
  final safePass = password.replaceAll("'", "\\'");
  final safeCap = (captcha ?? '').replaceAll("'", "\\'");

  await WebView.controller?.evaluateJavascript(source: """
    (() => {
      const u = document.getElementById('username');
      const p = document.getElementById('password');
      const c = document.getElementById('captchaStr') || document.querySelector('input[name="captchaStr"]') || document.querySelector('input[name="captcha"]');
      const btn = document.getElementById('submitBtn');
      if (u) { u.value = '$safeUser'; u.dispatchEvent(new Event('input', { bubbles: true })); }
      if (p) { p.value = '$safePass'; p.dispatchEvent(new Event('input', { bubbles: true })); }
      if (c && '$safeCap'.length > 0) { c.value = '$safeCap'; c.dispatchEvent(new Event('input', { bubbles: true })); }
      if (btn) btn.click();
      else {
        const f = document.querySelector('form');
        if (f) f.submit();
      }
    })()
  """);
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