import 'package:objectbox/objectbox.dart';
import 'package:vstop/objectbox.g.dart';
import 'index.dart';
import 'sem.dart';

@Entity()
class Assignment {
  int id;
  String sem, title, description;
  DateTime deadline; bool completed;
  Assignment({
    this.id = 0, required this.sem, required this.title, required this.description,
    required this.deadline, this.completed = false
  });
}

class AssignmentStore {
  static final _box = Database.getBox<Assignment>();

  final String sem;
  const AssignmentStore(this.sem);

  List<Assignment> getAssignments() => _box.query(Assignment_.sem.equals(sem)).order(Assignment_.deadline).build().find();

  Assignment addAssignment(String title, String desc, DateTime deadline) {
    final assignment = Assignment(sem: sem, title: title, description: desc, deadline: deadline);
     _box.put(assignment);
     return assignment;
  }
  void updateAssignment(Assignment assignment) => _box.put(assignment);
  void removeAssignment(Assignment assignment) => _box.remove(assignment.id);

  static void clear() => _box.removeAll();
}