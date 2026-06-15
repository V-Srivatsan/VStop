import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import 'package:vstop/lib/webview.dart';
import 'logic.dart' as logic;

class LoginForm extends StatefulWidget {
  static bool loaded = true;
  final bool scrollable;
  final void Function(BuildContext) onAuth;
  const LoginForm({super.key, required this.onAuth, this.scrollable = true});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {

  final _key = GlobalKey<FormBuilderState>();
  bool loading = true, showPassword = false;
  Uint8List? captcha; String? error;

  bool first = true; int tries = 0;

  void submitForm() {
    if (!_key.currentState!.saveAndValidate()) return;
    final data = _key.currentState!.value;
    logic.login(data['username'], data['password'], data['captcha']);
    setState(() { loading = true; error = null; });
  }

  @override
  void initState() {
    super.initState();

    logic.getCred().then((value) {
      if (value == null) return;
      _key.currentState!.patchValue({'username': value.$1, 'password': value.$2});
    });

    WebView.initialize(onPageLoad: (url) async {
      if (url != WebView.homeUrl && url != WebView.loginUrl && url != WebView.loginErrorUrl) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("An unexpected error occurred!")));
        return;
      }

      if (url == WebView.homeUrl) {
        if (first) { first = false; return; }
        await WebView.setAuth();

        final formData = _key.currentState!.value;
        await logic.saveCred(formData['username'], formData['password']);
        if (mounted) widget.onAuth(context);
        return;
      }

      captcha = await logic.getCaptcha();
      if (captcha != null) {
        final captchaStr = await logic.getCaptchaStr(captcha!);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _key.currentState!.patchValue({'captcha': captchaStr});
          if (tries < 3) submitForm();
        });
      } else WidgetsBinding.instance.addPostFrameCallback((_) { if (tries < 3) submitForm(); });

      if (url == WebView.loginErrorUrl) { 
        error = await logic.getLoginError();
        if (_key.currentState!.value["username"].isNotEmpty)
          tries += (error?.contains('Captcha') ?? false) ? 1 : 5;
      }

      if (mounted) setState(() { loading = false; });
    });
  }

  @override
  void dispose() {
    logic.free(); WebView.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final res = FormBuilder(
      key: _key,
      child: Column(
        mainAxisSize: .min, spacing: 10,
        crossAxisAlignment: .stretch,
        children: [

          FormBuilderTextField(
            name: "username", textCapitalization: .characters,
            decoration: InputDecoration(labelText: "V-TOP Username"),
          ),

          FormBuilderTextField(
            name: "password", obscureText: !showPassword,
            decoration: InputDecoration(
              labelText: "Password",
              suffixIcon: IconButton(
                onPressed: () => setState(() => showPassword = !showPassword),
                icon: Icon(showPassword ? Icons.visibility_off : Icons.visibility)
              )
            ),
          ),

          ...(captcha == null ? [] : [
            Image.memory(captcha!),
            FormBuilderTextField(
              name: "captcha", textCapitalization: .characters,
              decoration: InputDecoration(labelText: "Captcha"),
            )
          ]),

          if (error != null)
            Text(error!, style: TextStyle(color: Colors.red, fontWeight: .bold), textAlign: .center),

          FilledButton(
            onPressed: loading ? null : submitForm,
            child: !loading ? Text("Sync with V-TOP") :
                Row(mainAxisAlignment: .spaceBetween, spacing: 10, children: [
                  Text("Loading V-Top..."), CircularProgressIndicator(constraints: .tight(Size(25, 25)))
                ],)
          ),

        ],
      ),
    );

    return widget.scrollable ? SingleChildScrollView(child: res) : res;
  }
}
