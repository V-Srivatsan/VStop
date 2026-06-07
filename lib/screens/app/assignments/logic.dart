import 'package:flutter/material.dart';
import 'create.dart';
import 'package:vstop/lib/data/assignments.dart';

Future<Assignment?> updateAssignment(BuildContext ctx, { required String sem, Assignment? assignment }) async {
  final Map<String, dynamic>? res = await showModalBottomSheet(
    isScrollControlled: true,
    context: ctx, builder: (_) => AddForm(assignment)
  );

  if (res == null) return null;

  final store = AssignmentStore(sem);
  if (assignment == null) return store.addAssignment(res['title'], res['description'], res['deadline']);

  assignment.title = res['title']; assignment.description = res['description'];
  assignment.deadline = res['deadline'];
  store.updateAssignment(assignment);
  return assignment;
}

void completeAssignment(Assignment assignment, [bool completed = true]) {
  assignment.completed = completed;
  AssignmentStore(assignment.sem).updateAssignment(assignment);
}
void deleteAssignment(Assignment assignment) =>
    AssignmentStore(assignment.sem).removeAssignment(assignment);