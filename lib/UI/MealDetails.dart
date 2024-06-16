import 'package:menu_planner/Meal.dart';
import 'package:flutter/material.dart';

class MealDetails extends StatelessWidget {
  const MealDetails({super.key, required this.meal, this.varientIndex = 0});

  final Meal meal;
  final int varientIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(child: Column(children: [
        Text(meal.Name),
        Expanded(child: 
        Card.filled(color: Colors.white,
        child: Column(
          children: [
            const Text("To make this, you will need:"),
            for (var i in meal.Ingredients)
              Text("- ${i.Name}")
          ],
        )),),
      ],),),
    );
  }
}