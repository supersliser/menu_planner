import 'package:flutter/material.dart';
import 'package:menu_planner/Meal.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TodaysMeal extends StatefulWidget {
  TodaysMeal({super.key});

  DateTime date = DateTime.now();
  Meal meal;
  int mealVariant;

  @override
  State<TodaysMeal> createState() => _TodaysMealState();
}

class _TodaysMealState extends State<TodaysMeal> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Card.filled(
        color: Theme.of(context).colorScheme.tertiaryContainer,
        child: dateCardItem(context, date, meal),
      ),
    )
  }

  Widget dateCardItem(BuildContext context, DateTime date, Meal meal) {
    return Column(
      children: [
        SizedBox(width: 150, height: 200, child: Card.filled(
          color: Colors.white,
          child: Column(children: [
            Text(date.day.toString()),
            Text(date.month.toString() + ", " + date.year.toString()),
          ],)
        )
        ,),
        meal.MealIcon(context)
      ],
    );
  }
}