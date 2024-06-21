import 'package:menu_planner/Meal.dart';
import 'package:flutter/material.dart';

class MealDetails extends StatelessWidget {
  const MealDetails({super.key, required this.meal});

  final Meal meal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Text(meal.Name),
              Card.filled(
                  color: Theme.of(context).colorScheme.tertiaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("To make this, you will need:"),
                        for (var i in meal.Ingredients) Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("- ${i.Name}${i.CookingMethod == "null" ? "" : ", " + i.CookingMethod}"),
                        )
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
