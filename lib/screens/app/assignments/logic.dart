import 'package:flutter/material.dart';
import 'package:vstop/lib/db.dart';
import 'package:vstop/lib/notification.dart';
import 'create.dart';

Future<void> cancelNotifications(Assignment assignment) async {
  final notif = 'assignment_${assignment.id}';
  await Future.wait([10, 30, 60].map((x) => NotificationController.cancelNotification('$notif-$x')));
}

void scheduleNotifications(Assignment assignment) {
  final notif = 'assignment_${assignment.id}';
  final title = 'Pending: ${assignment.title}';
  final body = assignment.description;

  for (var x in [10, 30, 60]) {
    NotificationController.showNotification(
      id: '$notif-$x', channel: NotificationController.ASSIGNMENT_REMINDER_CHANNEL,
      title: title, body: body,
      schedule: assignment.deadline.subtract(Duration(minutes: x))
    );
  }
}

Future<Assignment?> updateAssignment(BuildContext ctx, { required String sem, Assignment? assignment }) async {
  final Map<String, dynamic>? res = await showModalBottomSheet(
    isScrollControlled: true,
    context: ctx, builder: (_) => AddForm(assignment)
  );

  if (res == null) return null;

  final store = AssignmentStore(sem);
  if (assignment == null)
    assignment = store.addAssignment(res['title'], res['description'], res['deadline']);
  else {
    assignment.title = res['title']; assignment.description = res['description'];
    assignment.deadline = res['deadline'];
    store.updateAssignment(assignment);
  }
  scheduleNotifications(assignment);
  return assignment;
}

void completeAssignment(Assignment assignment, [bool completed = true]) {
  assignment.completed = completed;
  AssignmentStore(assignment.sem).updateAssignment(assignment);
  if (completed) cancelNotifications(assignment);
  else scheduleNotifications(assignment);
}

void deleteAssignment(Assignment assignment) {
  cancelNotifications(assignment);
  AssignmentStore(assignment.sem).removeAssignment(assignment);
}