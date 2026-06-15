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
  static Future<void> setAuth() async {
    final data = await controller!.evaluateJavascript(source: "({csrf: csrfValue, reg: id})");
    _auth["csrf"] = data["csrf"];
    _auth["reg"] = data["reg"];

    _auth["cookies"] = (await CookieManager.instance().getCookies(url: WebUri(homeUrl)))
      .map((c) => "${c.name}=${c.value}").join("; ");
  }

  static void initialize({required void Function(String url) onPageLoad}) {
    controller?.dispose(); _webview?.dispose();

    _webview = HeadlessInAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(landingUrl)),
      onWebViewCreated: (ctrl) => controller = ctrl,
      onReceivedServerTrustAuthRequest: (ctrl, challenge) async => ServerTrustAuthResponse(action: .PROCEED),
      onLoadStop: (webview, url) {
        if (url!.rawValue != landingUrl) onPageLoad(url.rawValue);
        else webview.evaluateJavascript(source: "document.getElementById('stdForm')?.submit();");
      }
    )..run();
  }

  static void dispose() {
    controller?.dispose(); _webview?.dispose();
    controller = null; _webview = null;
  }

  static Future<String> request(String url, [Map<String, String>? data, bool debug = false]) async {
    Map<String, String> body = data ?? {};

    body["_csrf"] = _auth["csrf"]!; body["authorizedID"] = _auth["reg"]!;
    body["nocache"] = "@(new Date().getTime())";

    final Map<String, String> headers = {
      "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8",
      "Sec-GPC": "1", "X-Requested-With": "XMLHttpRequest", "Cookie": _auth["cookies"],
    };
    if (debug) {
      print("HEADERS: $headers");
      print("BODY: $body");
    }

    final res = await _client.post(Uri.parse(url), body: body, headers: headers);

    if (res.statusCode >= 300) throw Exception("Request failed: $url");
    return res.body;
  }
}
