import 'package:flutter/material.dart';
import 'package:vstop/lib/db.dart';
import 'package:vstop/screens/app/profile/screens/ffcs/visualiser.dart';

class Drafts extends StatefulWidget {
  const Drafts({super.key});

  @override
  State<Drafts> createState() => _DraftsState();
}

class _DraftsState extends State<Drafts> {

  final drafts = TimetableDraft.getAll();

  @override
  Widget build(BuildContext context) {
    return drafts.isEmpty ? Center(child: Text("No drafts saved yet")) :
     ListView(children: [
       for (var i=0; i < drafts.length; i++)
         ListTile(
           title: Text(drafts[i].draft!.name),
           trailing: IconButton(onPressed: () {
             drafts[i].delete();
             setState(() => drafts.removeAt(i));
           }, icon: Icon(Icons.delete)),
           onTap: () => showModalBottomSheet(context: context, builder: (_) => Padding(
             padding: .symmetric(horizontal: 20, vertical: 10),
             child: Column(
               mainAxisSize: .min, spacing: 10,
               children: [
                 Text(drafts[i].draft!.name, style: Theme.of(context).textTheme.titleLarge),
                 Visualiser(drafts[i])
               ],
             ),
           )),
         )
     ]);
  }
}
