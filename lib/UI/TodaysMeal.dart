import 'package:flutter/material.dart';
import 'package:menu_planner/Meal.dart';
import 'package:menu_planner/User.dart';

class TodaysMeal extends StatefulWidget {
  TodaysMeal({super.key, required this.user});

  DateTime date = DateTime.now();
  User user;

  @override
  State<TodaysMeal> createState() => _TodaysMealState();
}

class _TodaysMealState extends State<TodaysMeal> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Card.filled(
        color: Theme.of(context).colorScheme.tertiaryContainer,
        child: FutureBuilder(
          future: widget.user.getMealForDate(widget.date),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Text("Loading...");
            }
            return dateCardItem(context, widget.date, snapshot.data!);
          }
        ),
      ),
    );
  }

  Widget dateCardItem(BuildContext context, DateTime date, Meal meal) {
    return Column(
      children: [
        SizedBox(width: 150, height: 200, child: Card.filled(
          color: Colors.white,
          child: Column(children: [
            Text(date.day.toString()),
            Text("${date.month}, ${date.year}"),
          ],)
        )
        ,),
        meal.MealIcon(context)
      ],
    );
  }
}