import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vstop/lib/data/assignments.dart' show Assignment;

class AssignmentTile extends StatelessWidget {
  final Assignment assignment;
  final DismissDirection? direction; final void Function(DismissDirection)? onDismiss;
  final void Function()? onTap;
  final Icon? start, end;

  const AssignmentTile({
    super.key, required this.assignment, this.direction, this.onDismiss, this.onTap,
    this.start, this.end
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(assignment.id.toString()),
      direction: direction ?? .none,
      onDismissed: onDismiss,
      background: Card(
        color: Theme.of(context).colorScheme.tertiary,
        child: start == null ? null : Container(padding: .only(left: 20), alignment: .centerStart, child: start),
      ),
      secondaryBackground: Card(
        color: Theme.of(context).colorScheme.error,
        child: end == null ? null : Container(padding: .only(right: 20), alignment: .centerEnd, child: end),
      ),
      child: Card(child: ListTile(
        title: Text(assignment.title),
        subtitle: Text(DateFormat("dd MMM, HH:mm").format(assignment.deadline)),
        trailing: assignment.completed || assignment.deadline.isAfter(.now()) ? null :
          Chip(label: Text("Due"), backgroundColor: Theme.of(context).colorScheme.error),
        onTap: onTap,
      )),
    );
  }
}
