import 'package:flutter/material.dart';
import 'package:vstop/lib/store.dart';
import 'package:vstop/screens/login/form.dart';
import 'package:vstop/lib/data/marks.dart';

void syncMarks(
  BuildContext ctx,
  void Function(bool, Map<String, List<Mark>>) setState
) {

  showDialog(context: ctx, builder: (context) => AlertDialog(
    title: Text("Sync Marks"),
    content: LoginForm(onAuth: (_) async {
      if (context.mounted) Navigator.pop(context);
      setState(true, {});

      final store = MarkStore(await PrefStore.getSem());
      await store.fetch();
      final marks = store.getMarks();
      if (marks.values.isNotEmpty) await MarkStore.syncToFirestore(marks.values.reduce((c, e) => c+e));

      setState(false, store.getMarks());
    }),
  ));
}