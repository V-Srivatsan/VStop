import 'package:flutter/material.dart';
import 'package:vstop/lib/consts.dart';
import 'package:vstop/lib/db.dart';
import 'package:vstop/widgets/searchable_list.dart';

class CourseList extends StatefulWidget {
  final void Function(Map<String, List<FFCSCourse>>) update;
  const CourseList({super.key, required this.update});

  @override
  State<CourseList> createState() => _CourseListState();
}

class _CourseListState extends State<CourseList> {

  final _box = Database.getBox<FFCSCourse>();
  final Map<Course, List<FFCSCourse>> options = {};
  final List<Course> courses = [];

  void updateOptions(void Function() fn) {
    fn();
    _box.putMany(options.values.fold([], (p, e) => p+e));
    widget.update(.fromEntries(options.entries.map((e) => MapEntry(e.key.code, e.value))));
    setState((){});
  }

  @override
  void initState() {
    super.initState();
    for (var cat in CourseStore.getCategories())
      for (var course in CourseStore.getCoursesByCategory(cat.id))
        if (!course.completed) courses.add(course);

    for (var option in _box.getAll())
      options.putIfAbsent(CourseStore.getCourse(option.code)!, () => []).add(option);

    widget.update(.fromEntries(options.entries.map((e) => MapEntry(e.key.code, e.value))));
  }

  @override
  Widget build(BuildContext context) {
    return Column(spacing: 10, children: [
      Row(
        mainAxisAlignment: .spaceBetween,
        children: [
          Text("Courses", style: Theme.of(context).textTheme.headlineSmall),
          IconButton(
            onPressed: () => showModalBottomSheet(
              context: context, isScrollControlled: true, useSafeArea: true,
              builder: (ctx) {
                final insets = MediaQuery.viewInsetsOf(ctx);
                return SafeArea(child: Padding(
                  padding: .fromLTRB(20, 0, 20, insets.bottom + 10),
                  child: CustomScrollView(slivers: [
                    SearchableList(
                      items: courses.where((c) => options[c] == null).toList(), hintText: "Search Courses",
                      searchKey: (course) => course.name.toLowerCase(),
                      itemBuilder: (course) => Card(child: ListTile(
                        title: Text(course.name),
                        subtitle: Text(course.code),
                        onTap: () {
                          setState(() => options[course] = []);
                          Navigator.of(ctx).pop();
                        }
                      )),
                    )
                  ]),
                ));
              }
            ),
            icon: Icon(Icons.add)
          )
        ],
      ),

      Expanded(child: ListView(children: [
        for (var course in options.keys)
          Card(child: ListTile(
            title: Text(course.name), subtitle: Text('${options[course]?.length ?? 0} options'),
            trailing: IconButton(
              onPressed: () {
                _box.removeMany(options[course]!.map((e) => e.id).toList());
                updateOptions(() => options.remove(course));
              },
              icon: Icon(Icons.delete)
            ),
            onTap: () => showModalBottomSheet(context: context, builder: (_) =>
              OptionList(
                course: course, options: options[course]!,
                onUpdate: (opt) => updateOptions(() => options[course] = opt)
              )
            ),
          ))
      ]))

    ]);
  }
}

class OptionList extends StatelessWidget {
  final Course course;
  final List<FFCSCourse> options;
  final void Function(List<FFCSCourse>) onUpdate;
  OptionList({super.key, required this.course, required this.options, required this.onUpdate });

  final _box = Database.getBox<FFCSCourse>();

  void update(BuildContext ctx) {
    onUpdate(options);
    Navigator.pop(ctx);
    showModalBottomSheet(context: ctx, builder: (_) => OptionList(course: course, options: options, onUpdate: onUpdate));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Padding(
      padding: .symmetric(horizontal: 20),
      child: Column(
        spacing: 5,
        children: [
          Text(course.name, style: Theme.of(context).textTheme.titleLarge, textAlign: .center),
          Expanded(child: (options.isEmpty ?
          Center(child: Text("No options added yet")) :
          ListView(children: [
            for (var i = 0; i < options.length; i++)
              Card(child: ListTile(
                title: Text(options[i].faculty),
                subtitle: Text(options[i].slots.join("+")),
                trailing: IconButton(
                  onPressed: () {
                    _box.remove(options.removeAt(i).id);
                    update(context);
                  },
                  icon: Icon(Icons.delete)
                ),
                onTap: () async {
                  final FFCSCourse? option = await showModalBottomSheet(
                    context: context, isScrollControlled: true,
                    builder: (ctx) {
                      final insets = MediaQuery.viewInsetsOf(ctx);
                      return SafeArea(child: Padding(
                        padding: .fromLTRB(20, 0, 20, insets.bottom + 10),
                        child: AddOption(course: course, option: options[i])
                      ));
                    }
                  );
                  if (option != null && context.mounted) { options[i] = option; update(context); }
                },
              ))
          ])
          )),
          FilledButton(
            onPressed: () async {
              final FFCSCourse? option = await showModalBottomSheet(
                context: context, isScrollControlled: true,
                builder: (ctx) {
                  final insets = MediaQuery.viewInsetsOf(ctx);
                  return SafeArea(child: Padding(
                    padding: .fromLTRB(20, 0, 20, insets.bottom + 10),
                    child: AddOption(course: course)
                  ));
                }
              );
              if (option != null && context.mounted) { options.add(option); update(context); }
            },
            child: Text("Add Option")
          )
        ],
      )
    ));
  }
}

class AddOption extends StatefulWidget {
  final Course course;
  final FFCSCourse? option;
  const AddOption({super.key, required this.course, this.option });

  @override
  State<AddOption> createState() => _AddOptionState();
}

class _AddOptionState extends State<AddOption> {

  late final List<String> slots;
  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.option?.faculty ?? "");
    slots = widget.option?.slots ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: .min, crossAxisAlignment: .stretch, spacing: 5,
      children: [
        Text(
          widget.option == null ? "Add Option" : "Edit Option",
          style: Theme.of(context).textTheme.titleLarge
        ),
        SizedBox(),
        TextField(controller: controller, decoration: InputDecoration(labelText: "Faculty")),
        ConstrainedBox(
          constraints: .tight(Size(.infinity, 300)),
          child: SingleChildScrollView(child:  Wrap(spacing: 1, children: [
            for (var slot in slot_loc.keys)
              ChoiceChip(
                label: Text(slot), selected: slots.contains(slot),
                onSelected: (sel) => setState(() => sel ? slots.add(slot) : slots.remove(slot)),
              )
          ]))
        ),

        Row(
          mainAxisAlignment: .end, spacing: 5,
          children: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
            ElevatedButton(
              onPressed: () =>
                controller.text.isEmpty || slots.isEmpty ? null :
                Navigator.pop(context, FFCSCourse(
                  id: widget.option?.id ?? 0,
                  code: widget.course.code, name: widget.course.name,
                  faculty: controller.text, slots: slots
                )),
              child: Text("Save")
            )
          ],
        )
      ],
    );
  }
}
