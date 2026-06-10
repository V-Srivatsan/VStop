import 'package:flutter/material.dart';
import 'package:vstop/lib/db.dart';

import 'package:vstop/widgets/display_card.dart';


class CourseList extends StatelessWidget {
  final CourseCategory category;
  const CourseList({super.key, required this.category });

  @override
  Widget build(BuildContext context) {

    final courses = CourseStore.getCoursesByCategory(category.id);
    final completed = courses.fold(0.0, (p, c) => p + (c.completed ? c.credits : 0));

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(child: Padding(
        padding: .symmetric(horizontal: 20),
        child: CustomScrollView(slivers: [

          SliverToBoxAdapter(child: Column(
            mainAxisSize: .min, spacing: 10,
            children: [

              Text(category.name, style: Theme.of(context).textTheme.titleLarge, textAlign: .center),
              Row(
                spacing: 10, mainAxisAlignment: .spaceBetween,
                children: [

                  DisplayCard(
                    label: "Completed", color: Theme.of(context).colorScheme.secondary,
                    child: Text(
                      completed.toStringAsFixed(2),
                      style: Theme.of(context).textTheme.displaySmall,
                    )
                  ),

                  DisplayCard(
                    label: "Remaining", color: Theme.of(context).colorScheme.primary,
                    child: Text(
                      (category.credits - completed).toStringAsFixed(2),
                      style: Theme.of(context).textTheme.displaySmall,
                    )
                  )

                ],
              ),

              SizedBox(height: 15)

            ],
          )),

          SearchableList(courses)

        ])
      ))
    );
  }
}



class SearchableList extends StatefulWidget {
  final List<Course> courses;
  final void Function(Course course)? onTap;
  const SearchableList(this.courses, {super.key, this.onTap});

  @override
  State<SearchableList> createState() => _SearchableListState();
}

class _SearchableListState extends State<SearchableList> {

  List<Course> filtered = [];
  final controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    filtered = widget.courses;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(slivers: [
      
      SliverToBoxAdapter(child: SearchBar(
        leading: const Icon(Icons.search), hintText: "Search Courses",
        controller: controller,
        onChanged: (query) => setState(() => filtered = 
            widget.courses.where((c) => c.name.toLowerCase().contains(query.toLowerCase())).toList()
        ),
        trailing: filtered.length == widget.courses.length ? null : [IconButton(
          onPressed: () {
            controller.clear();
            setState(() => filtered = widget.courses);
          },
          icon: const Icon(Icons.close)
        )],
      )),
      
      SliverList.builder(
        itemCount: filtered.length,
        itemBuilder: (_, i) => Card(
          color: filtered[i].completed ? Theme.of(context).colorScheme.tertiary.withAlpha(128) : null,
          child: ListTile(
            title: Text(filtered[i].name), onTap: widget.onTap == null ? null : () => widget.onTap!(filtered[i]),
            subtitle: Text(filtered[i].completed ? 'Grade: ${filtered[i].grade!}' : filtered[i].code),
            trailing: Text(filtered[i].credits.toStringAsFixed(1)),
            leading: (
                filtered[i].type == "TH" ? Icon(Icons.book_outlined) :
                filtered[i].type == "LO" ? Icon(Icons.science_outlined) :
                filtered[i].type == "OC" ? Icon(Icons.computer) :
                filtered[i].type == "PJT" ? Icon(Icons.account_tree_outlined) :
                Stack(
                  alignment: .center,
                  children: [
                    Transform.translate(
                      offset: .new(-5, -5),
                      child: Icon(Icons.book_outlined),
                    ),
                    Transform.translate(
                      offset: .new(5, 5),
                      child: Icon(Icons.science_outlined),
                    ),
                  ],
                )
            ),
          ),
        ),
      )

    ]);
  }
}
