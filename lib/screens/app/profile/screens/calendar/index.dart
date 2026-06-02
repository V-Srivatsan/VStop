import 'package:flutter/material.dart';
import 'package:vstop/lib/data/calendar.dart' show CalendarEntry;
import 'package:vstop/widgets/calendar.dart';
import 'logic.dart' as logic;

class Screen extends StatelessWidget {
  const Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Calendar"),
        actions: [
          IconButton(
            onPressed: () => logic.syncCalendar(context),
            icon: Icon(Icons.sync)
          )
        ],
      ),
      body: SafeArea(child: Calendar()),
    );
  }
}

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {

  late final Map<String, CalendarEntry> entries;
  int month = 0, year = 0; String? selected;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    month = now.month; year = now.year; selected = now.day.toString();
    entries = .fromEntries(logic.getEntries().map((e) => MapEntry(e.date, e)));
    print(entries);
  }

  bool isToday(String day) {
    final now = DateTime.now();
    return (year == now.year && month == now.month && now.day.toString() == day);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: .symmetric(horizontal: 20, vertical: 10),
      child: Column(
        spacing: 20,
        children: [

          Flexible(flex: 7, child: Column(
            mainAxisSize: .min, spacing: 5, mainAxisAlignment: .spaceBetween,
            children: [

              Row(
                mainAxisSize: .min, spacing: 5,
                children: [

                  IconButton(
                    onPressed: () => setState(() {
                      selected = null; month--;
                      if (month == 0) { month = 12; year--; }
                    }),
                    icon: Icon(Icons.chevron_left)
                  ),
                  Text('${MONTHS[month-1]} $year'),
                  IconButton(
                    onPressed: () => setState(() {
                      selected = null; month++;
                      if (month == 13) { month = 1; year++; }
                    }),
                    icon: Icon(Icons.chevron_right)
                  )

                ],
              ),

              CalendarBuilder(month: month, year: year, expand: true, builder: (String day) =>
                int.tryParse(day) == null ?
                  Container(
                    width: 35, height: 25,
                    child: Center(child: Text(day)),
                  ) :
                  GestureDetector(
                    onTap: () => setState(() { selected = day; }),
                    child: Container(
                      width: 35, height: 35,
                      decoration: BoxDecoration(
                        shape: .circle,
                        color: isToday(day) ? Theme.of(context).colorScheme.primary : null,
                        border: selected == null || selected != day ? null :
                            .all(color: Theme.of(context).colorScheme.secondary, width: 2)
                      ),
                      child: Column(
                        mainAxisAlignment: .center,
                        children: [
                          Text(day, style: TextStyle(color: isToday(day) ? Colors.black : null)),

                          (String day) {
                            final key = '$year${month.toString().padLeft(2, "0")}${day.padLeft(2, "0")}';
                            if (entries[key] == null) return SizedBox();
                            return Badge(backgroundColor: (String t){
                              if (t == "Instructional Day") return Theme.of(context).colorScheme.primary;
                              if (t == "Holiday" || t == "No Instructional Day") return Theme.of(context).colorScheme.secondary;
                              return Theme.of(context).colorScheme.error;
                            }(entries[key]!.type));
                          }(day)
                        ],
                      ),
                    ),
                  )
              )

            ],
          )),

          (){
            if (selected == null) return SizedBox();

            final entry = entries['$year${month.toString().padLeft(2, "0")}${selected!.padLeft(2, "0")}'];
            if (entry == null) return SizedBox();

            return Card(child: ListTile(
              leading: Text('${selected.toString()}\n${MONTHS[month-1]}', textAlign: .center,),
              title: Text(entry.comment),
              trailing: Badge(
                backgroundColor: (String t){
                  if (t == "Instructional Day") return Theme.of(context).colorScheme.primary;
                  if (t == "Holiday" || t == "No Instructional Day") return Theme.of(context).colorScheme.secondary;
                  return Theme.of(context).colorScheme.error;
                }(entry.type)
              ),
            ));
          }()


        ],
      ),
    );
  }
}


const MONTHS = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
