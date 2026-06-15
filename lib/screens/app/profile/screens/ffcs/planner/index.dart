import 'package:flutter/material.dart';
import 'package:vstop/lib/db.dart';
import 'logic.dart' as logic;
import '../visualiser.dart';
import 'course_list.dart';

class Planner extends StatefulWidget {
  const Planner({super.key});

  @override
  State<Planner> createState() => _PlannerState();
}

class _PlannerState extends State<Planner> {

  Map<String, List<FFCSCourse>> courses = {};
  List<TimetableDraft> drafts = [];
  int idx = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .stretch, mainAxisSize: .min,
      children: [

        Row(spacing: 10, mainAxisAlignment: .spaceBetween, children: [
          Row(
            mainAxisSize: .min, spacing: 10,
            children: [
              IconButton(
                onPressed: idx == 0 ? null : () => setState(() => idx--),
                icon: Icon(Icons.chevron_left)
              ),

              Text("${drafts.isEmpty ? 0 : idx+1} / ${drafts.length}"),

              IconButton(
                onPressed: idx+1 >= drafts.length ? null : () => setState(() => idx++),
                icon: Icon(Icons.chevron_right)
              )
            ],
          ),

          Row(
            mainAxisSize: .min,
            children: [
              IconButton(
                onPressed: drafts.isEmpty ? null : () =>
                  showDialog(context: context, builder: (ctx) {
                    final controller = TextEditingController();
                    return AlertDialog(
                      title: Text("Save Draft"),
                      content: TextField(
                        controller: controller,
                        autofocus: true, decoration: InputDecoration(hintText: "Draft Name"),
                      ),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Cancel")),
                        TextButton(
                          onPressed: () {
                            final name = controller.text;
                            if (name.isEmpty) return;
                            drafts[idx].save(name);
                            Navigator.of(ctx).pop();
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$name draft saved")));
                          }, child: Text("Save"))
                      ],
                    );
                  }),
                icon: Icon(Icons.save_alt)
              ),
              IconButton(
                onPressed: () => setState(() { drafts = logic.makeDrafts(courses); idx = 0; }),
                icon: Icon(Icons.refresh)
              )
            ],
          )

        ]),

        (drafts.isEmpty ?
          Center(child: Text("No combinations found")) :
          Visualiser(drafts[idx])
        ),
        Expanded(child: CourseList(update: (map) => courses = map))

      ],
    );
  }
}
