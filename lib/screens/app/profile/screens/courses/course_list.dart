import 'package:flutter/material.dart';
import 'package:vstop/lib/db.dart';
import 'package:vstop/widgets/searchable_list.dart';
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

          SearchableList(
            items: courses, hintText: "Search Courses",
            searchKey: (course) => course.name.toLowerCase(),
            itemBuilder: (course) => Card(
              color: course.completed ? Theme.of(context).colorScheme.tertiary.withAlpha(128) : null,
              child: ListTile(
                title: Text(course.name),
                subtitle: Text(course.completed ? 'Grade: ${course.grade!}' : course.code),
                trailing: Text(course.credits.toStringAsFixed(1)),
                leading: (
                  course.type == "TH" ? Icon(Icons.book_outlined) :
                  course.type == "LO" ? Icon(Icons.science_outlined) :
                  course.type == "OC" ? Icon(Icons.computer) :
                  course.type == "PJT" ? Icon(Icons.account_tree_outlined) :
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

        ])
      ))
    );
  }
}