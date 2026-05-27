import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vstop/lib/data/index.dart';
import 'package:vstop/lib/store.dart';

import 'package:vstop/screens/login/index.dart' as auth;
import 'package:vstop/screens/sync/index.dart' as sync;
import 'package:vstop/screens/login/form.dart';

Future<void> logout(BuildContext context) async {
  Database.clear();
  await PrefStore.clear();
  await SecureStorage.clear();

  if (context.mounted)
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (ctx) => auth.Screen()),
      (_) => false
    );
}

Future<void> updateTheme(BuildContext context) async {

  void change(BuildContext ctx, bool? dark) async {
    await PrefStore.setTheme(dark);
    if (ctx.mounted) Navigator.pop(ctx);
  }

  showDialog(context: context, builder: (ctx) => AlertDialog(
    title: Text("Change Theme"),
    content: Column(
      mainAxisSize: .min, crossAxisAlignment: .stretch,
      children: [

        Card(child: ListTile(
          title: Text("Light Theme"), leading: Icon(Icons.light_mode),
          onTap: () => change(ctx, false),
        )),

        Card(child: ListTile(
          title: Text("Dark Theme"), leading: Icon(Icons.dark_mode),
          onTap: () => change(ctx, true),
        )),

        Card(child: ListTile(
          title: Text("System Theme"), leading: Icon(Icons.brightness_medium),
          onTap: () => change(ctx, null),
        ))

      ],
    ),
  ));
}

void syncData(BuildContext ctx) =>
  showDialog(context: ctx, builder: (context) => AlertDialog(
    title: Text("Sync Data"),
    content: LoginForm(onAuth: (ctx) => Navigator.pushReplacement(
      ctx, MaterialPageRoute(builder: (_) => sync.Screen())
    )),
  ));

void shareApp() => SharePlus.instance.share(ShareParams(
    text: "Check out this one-stop solution for V-TOP: V-STOP! Download here: https://github.com/V-Srivatsan/VStop/releases"
));