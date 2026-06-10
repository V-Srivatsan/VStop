import 'package:flutter/material.dart';
import 'package:vstop/lib/data/local/assignments.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';


class AddForm extends StatefulWidget {
  final Assignment? assignment;
  const AddForm(this.assignment, {super.key});

  @override
  State<AddForm> createState() => _AddFormState();
}

class _AddFormState extends State<AddForm> {

  final _key = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Padding(
      padding: .fromLTRB(20, 0, 20, 10 + MediaQuery.viewInsetsOf(context).bottom),
      child: FormBuilder(key: _key, child: Column(
        mainAxisSize: .min, spacing: 15, crossAxisAlignment: .stretch,
        children: [
          Text(
              "${widget.assignment == null ? "Add" : "Update"} Assignment",
              style: Theme.of(context).textTheme.titleLarge
          ),

          FormBuilderTextField(
            name: 'title', initialValue: widget.assignment?.title,
            decoration: InputDecoration(labelText: "Title"),
          ),

          FormBuilderTextField(
            name: 'description', initialValue: widget.assignment?.description,
            decoration: InputDecoration(labelText: "Description"),
            maxLines: 3, minLines: 3,
          ),

          FormBuilderDateTimePicker(
            name: 'deadline', initialValue: widget.assignment?.deadline,
            decoration: InputDecoration(labelText: "Deadline"),
            firstDate: .now(),
          ),

          FilledButton(
            onPressed: () {
              if (!_key.currentState!.saveAndValidate()) return;
              Navigator.pop(context, _key.currentState!.value);
            },
            child: Text(widget.assignment == null ? "Add" : "Update")
          )
        ],
      ))
    ));
  }
}
