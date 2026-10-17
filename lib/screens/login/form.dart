import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _captchaController = TextEditingController();

  bool loading = true, showPassword = false;
  Uint8List? captcha;
  String? captchaStr;
  String? error;

  int tries = 0;

  void submitForm() {
    TextInput.finishAutofillContext();
    _key.currentState?.save();

    final u = _usernameController.text.trim().isNotEmpty
        ? _usernameController.text.trim()
        : (_key.currentState?.value['username']?.toString().trim() ?? '');
    final p = _passwordController.text.trim().isNotEmpty
        ? _passwordController.text.trim()
        : (_key.currentState?.value['password']?.toString().trim() ?? '');
    final c = _captchaController.text.trim().isNotEmpty
        ? _captchaController.text.trim()
        : (_key.currentState?.value['captcha']?.toString().trim() ?? (captchaStr ?? ''));

    if (u.isEmpty || p.isEmpty) {
      setState(() { error = "Please enter username and password"; loading = false; });
      return;
    }
    logic.login(u, p, c.isNotEmpty ? c : null);
    setState(() { loading = true; error = null; });
  }

  @override
  void initState() {
    super.initState();

    logic.getCred().then((value) {
      if (value == null || !mounted) return;
      _usernameController.text = value.$1;
      _passwordController.text = value.$2;
      _key.currentState?.patchValue({'username': value.$1, 'password': value.$2});
    });

    // Safety fallback: ensure loading spinner never traps the user indefinitely
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted && loading) {
        setState(() { loading = false; });
      }
    });

    WebView.initialize(onPageLoad: (url) async {
      print("WebView onPageLoad: $url");
      if (url.contains('/init/page') || url.contains('/prelogin/') || url.contains('/open/page')) return;

      if (url.contains('/content')) {
        print("Login succeeded! Navigating to sync...");
        final username = _usernameController.text.trim().isNotEmpty
            ? _usernameController.text.trim()
            : (_key.currentState?.value['username']?.toString().trim() ?? '');
        final password = _passwordController.text.trim().isNotEmpty
            ? _passwordController.text.trim()
            : (_key.currentState?.value['password']?.toString().trim() ?? '');
        await WebView.setAuth(username);

        if (username.isNotEmpty && password.isNotEmpty) {
          await logic.saveCred(username, password);
        }
        if (mounted) widget.onAuth(context);
        return;
      }

      if (url.contains('/login/error')) { 
        error = await logic.getLoginError();
        print("Login error: $error");
        final user = _usernameController.text.trim().isNotEmpty
            ? _usernameController.text.trim()
            : (_key.currentState?.value['username']?.toString().trim() ?? '');
        if (user.isNotEmpty) {
          tries += (error?.contains('Captcha') ?? false) ? 1 : 1000;
        }
      }

      // Retry fetching captcha up to 10 times (up to 2.5s) if DOM is still rendering
      for (int i = 0; i < 10; i++) {
        captcha = await logic.getCaptcha();
        if (captcha != null) break;
        await Future.delayed(const Duration(milliseconds: 250));
      }

      if (captcha != null) {
        final decoded = await logic.getCaptchaStr(captcha!);
        captchaStr = decoded;
        if (mounted) {
          _captchaController.text = decoded;
          _key.currentState?.patchValue({'captcha': decoded});
          setState(() {
            this.captcha = captcha;
            captchaStr = decoded;
            loading = false;
          });

          final u = _usernameController.text.trim().isNotEmpty
              ? _usernameController.text.trim()
              : (_key.currentState?.value['username']?.toString().trim() ?? '');
          final p = _passwordController.text.trim().isNotEmpty
              ? _passwordController.text.trim()
              : (_key.currentState?.value['password']?.toString().trim() ?? '');

          if (u.isNotEmpty && p.isNotEmpty && tries < 5) {
            submitForm();
            return;
          }
        }
      } else {
        if (mounted) setState(() { loading = false; });
      }
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _captchaController.dispose();
    logic.free();
    WebView.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final res = AutofillGroup(
      child: FormBuilder(
        key: _key,
        child: Column(
          mainAxisSize: .min, spacing: 10,
          crossAxisAlignment: .stretch,
          children: [

            FormBuilderTextField(
              name: "username",
              controller: _usernameController,
              textCapitalization: TextCapitalization.characters,
              autofillHints: const [AutofillHints.username],
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(labelText: "V-TOP Username"),
            ),

            FormBuilderTextField(
              name: "password",
              controller: _passwordController,
              obscureText: !showPassword,
              autofillHints: const [AutofillHints.password],
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
                name: "captcha",
                controller: _captchaController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(labelText: "Captcha"),
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
      ),
    );

    return widget.scrollable ? SingleChildScrollView(child: res) : res;
  }
}
