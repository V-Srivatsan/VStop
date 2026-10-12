import 'package:http/http.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';


class WebView {
  static const String landingUrl = "https://vtopcc.vit.ac.in/vtop/open/page";
  static const String loginUrl = "https://vtopcc.vit.ac.in/vtop/login";
  static const String loginErrorUrl = "https://vtopcc.vit.ac.in/vtop/login/error";
  static const String homeUrl = "https://vtopcc.vit.ac.in/vtop/content";

  static final Client _client = Client();
  static HeadlessInAppWebView? _webview;
  static InAppWebViewController? controller;

  static final Map<String, dynamic> _auth = {};
  static Future<void> setAuth([String? username]) async {
    try {
      final dynamic data = await controller?.evaluateJavascript(source: """
        (() => {
          let csrf = '';
          let reg = '';
          try { if (typeof csrfValue !== 'undefined' && csrfValue) csrf = csrfValue; } catch (e) {}
          try { if (typeof id !== 'undefined' && id) reg = id; } catch (e) {}
          if (!csrf) {
            const el = document.querySelector('input[name="_csrf"]') || document.querySelector('meta[name="_csrf"]');
            if (el) csrf = el.value || el.getAttribute('content') || '';
          }
          if (!reg) {
            const el = document.getElementById('authorizedIDX') || document.querySelector('input[name="authorizedID"]');
            if (el) reg = el.value || '';
          }
          return { csrf: csrf, reg: reg };
        })()
      """);

      if (data is Map) {
        if (data["csrf"] != null && data["csrf"].toString().isNotEmpty) {
          _auth["csrf"] = data["csrf"].toString();
        }
        if (data["reg"] != null && data["reg"].toString().isNotEmpty) {
          _auth["reg"] = data["reg"].toString();
        }
      }
    } catch (e) {
      print("Warning: evaluateJavascript auth extraction error: $e");
    }

    if (_auth["reg"] == null || _auth["reg"].toString().isEmpty) {
      if (username != null && username.isNotEmpty) {
        _auth["reg"] = username.trim().toUpperCase();
      }
    }

    // On iOS WKHTTPCookieStore syncs asynchronously from WebKit networking process.
    // Poll up to 5 times (total ~1.5s) until JSESSIONID is available.
    final cookieManager = CookieManager.instance();
    String cookies = "";
    for (int attempt = 0; attempt < 5; attempt++) {
      final List<Cookie> cookieList = [];
      try {
        final homeCookies = await cookieManager.getCookies(url: WebUri(homeUrl));
        cookieList.addAll(homeCookies);
      } catch (_) {}
      try {
        final vtopCookies = await cookieManager.getCookies(url: WebUri("https://vtopcc.vit.ac.in/vtop"));
        cookieList.addAll(vtopCookies);
      } catch (_) {}
      try {
        final allCookies = await cookieManager.getAllCookies();
        cookieList.addAll(allCookies);
      } catch (_) {}

      final uniqueCookies = <String, String>{};
      for (final c in cookieList) {
        if (c.name.isNotEmpty && c.value != null) {
          uniqueCookies[c.name] = c.value.toString();
        }
      }

      if (uniqueCookies.containsKey("JSESSIONID")) {
        cookies = uniqueCookies.entries.map((e) => "${e.key}=${e.value}").join("; ");
        break;
      }
      await Future.delayed(const Duration(milliseconds: 300));
    }

    if (cookies.isEmpty) {
      try {
        final all = await cookieManager.getAllCookies();
        cookies = all.map((c) => "${c.name}=${c.value}").join("; ");
      } catch (_) {}
    }
    _auth["cookies"] = cookies;
  }

  static void initialize({required void Function(String url) onPageLoad}) {
    controller?.dispose(); _webview?.dispose();

    _webview = HeadlessInAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(landingUrl)),
      initialSettings: InAppWebViewSettings(
        mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
        isFraudulentWebsiteWarningEnabled: false,
      ),
      onWebViewCreated: (ctrl) => controller = ctrl,
      onReceivedServerTrustAuthRequest: (ctrl, challenge) async => ServerTrustAuthResponse(action: ServerTrustAuthResponseAction.PROCEED),
      onLoadStop: (webview, url) async {
        final currentUrl = url?.rawValue ?? "";
        if (currentUrl.contains('/open/page')) {
          await webview.evaluateJavascript(source: """
            (() => {
              const f = document.getElementById('stdForm') || document.querySelector('form[action*="prelogin/setup"]');
              if (f) {
                if (typeof submitForm === 'function') submitForm('stdForm');
                else f.submit();
              }
            })()
          """);
        } else {
          onPageLoad(currentUrl);
        }
      },
      onReceivedError: (ctrl, req, err) {
        print("WebView error on ${req.url}: ${err.description}");
      },
      onReceivedHttpError: (ctrl, req, res) {
        print("WebView HTTP error on ${req.url}: ${res.statusCode}");
      }
    )..run();
  }

  static Future<void> clearSession() async {
    _auth.clear();
    try {
      await CookieManager.instance().deleteAllCookies();
    } catch (_) {}
    controller?.dispose(); _webview?.dispose();
    controller = null; _webview = null;
  }

  static void dispose() {
    controller?.dispose(); _webview?.dispose();
    controller = null; _webview = null;
  }

  static Future<String> request(String url, [Map<String, String>? data, bool debug = false]) async {
    Map<String, String> body = data ?? {};

    if (_auth["csrf"] != null) body["_csrf"] = _auth["csrf"]!;
    if (_auth["reg"] != null) body["authorizedID"] = _auth["reg"]!;
    body["nocache"] = "@(new Date().getTime())";

    final Map<String, String> headers = {
      "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8",
      "Sec-GPC": "1",
      "X-Requested-With": "XMLHttpRequest",
      "User-Agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148",
      "Referer": "https://vtopcc.vit.ac.in/vtop/content",
      "Origin": "https://vtopcc.vit.ac.in",
      "Accept": "*/*",
      if (_auth["cookies"] != null && _auth["cookies"].toString().isNotEmpty)
        "Cookie": _auth["cookies"],
    };
    if (debug) {
      print("HEADERS: $headers");
      print("BODY: $body");
    }

    final res = await _client.post(Uri.parse(url), body: body, headers: headers);

    if (res.statusCode >= 300) {
      print("Request failed with status ${res.statusCode} for $url");
      throw Exception("Request failed (${res.statusCode}): $url");
    }
    return res.body;
  }
}
