import 'package:flutter/material.dart';
import 'package:vstop/lib/db.dart';

import 'course_list.dart';

class Screen extends StatelessWidget {
  const Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("My Courses")),
      body: SafeArea(child: ListView(
        children: [
          for (var cat in CourseStore.getCategories())
            Padding(
              padding: .symmetric(horizontal: 20),
              child: Card(child: ListTile(
                title: Text(cat.name.split("Foundation Core - ").last), trailing: Icon(Icons.chevron_right),
                onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => CourseList(category: cat)
                )),
              )),
            )
        ],
      )),
    );
  }
}
