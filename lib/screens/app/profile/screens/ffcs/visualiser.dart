import 'package:flutter/material.dart';
import 'package:vstop/lib/consts.dart' as consts;
import 'package:vstop/lib/db.dart';

class Visualiser extends StatelessWidget {
  final TimetableDraft draft;
  const Visualiser(this.draft, {super.key});

  String formatTime(Duration d) => (
    '${d.inHours.toString().padLeft(2, '0')}:${d.inMinutes.remainder(60).toString().padLeft(2, '0')}'
  );

  @override
  Widget build(BuildContext context) {
    for (var course in draft.courses)
      print("${course.name} - ${course.slots}");

    return SingleChildScrollView(
      scrollDirection: .horizontal,
      child: DataTable(
        columns: [
          for (var i=0; i < 12; i++)
            DataColumn(label: Column(mainAxisSize: .min, children: [
              Text('${formatTime(consts.theory[i].$1)} - ${formatTime(consts.theory[i].$2)}'),
              Text('${formatTime(consts.lab[i].$1)} - ${formatTime(consts.lab[i].$2)}')
            ]))
        ],
        rows: [
          for (var day = 0; day < 5; day++)
            DataRow(cells: [
              for (var i = 0; i < 12; i++)
                DataCell(Container(
                    height: 50, width: 100, alignment: Alignment.center,
                    child: Tooltip(
                      message: draft.selected[day][i]?.faculty ?? '',
                      triggerMode: draft.selected[day][i] == null ? .manual : .tap,
                      child: Chip(
                        backgroundColor: draft.selected[day][i] == null ? null :
                        Theme.of(context).colorScheme.tertiary,
                        label: Text(
                          draft.selected[day][i] == null ?
                            "${consts.slots[day].$1[i]} / ${consts.slots[day].$2[i]}" :
                            draft.selected[day][i]!.slots.contains(consts.slots[day].$1[i]) ?
                              consts.slots[day].$1[i] :
                              consts.slots[day].$2[i]
                        )
                      )
                    ),
                  )
                )
            ])
        ],
      )
    );
  }
}

