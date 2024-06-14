import 'package:flutter/widgets.dart';
import 'package:menu_planner/Attribute.dart';
import 'package:menu_planner/Ingredient.dart';
import 'package:menu_planner/UI/MealDetails.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

class tempMealRating {
  const tempMealRating({required this.meal, required this.rating});

  final Meal meal;
  final double rating;
}

class Meal {
  const Meal({required this.ID, required this.Name, required this.Ingredients});

  final int ID;
  final String Name;

  final List<Ingredient> Ingredients;

  static Future<Meal> toObject(Map<String, dynamic> input) async {
    return Meal(
        ID: input["ID"],
        Name: input["Name"],
        Ingredients: await Ingredient.getForMeal(input["ID"]),
        );
  }

  static Future<List<Meal>> getAll() async {
    var temp = await Supabase.instance.client.from("Meals").select();
    List<Meal> output = List.empty(growable: true);
    for (var i in temp) {
      output.add(await toObject(i));
    }
    return output;
  }

  static Future<Meal> getByID(int id) async {
    return await toObject(
        (await Supabase.instance.client.from("Meals").select().eq("ID", id))
            .first);
  }

  static Future<Meal> getByName(String name) async {
    return await toObject(
        (await Supabase.instance.client.from("Meals").select().eq("Name", name))
            .first);
  }

  static Future<Meal> calculateBestMeal(DateTime date) async {
    var tempmeals = await getAll();

    List<Attribute> attributes = await Attribute.getAll();

    List<tempMealRating> meals = List.generate(tempmeals.length, (i) => tempMealRating(meal: tempmeals[i], rating: 5.0));


    for (var i in attributes) {


    return meals.first.meal;
  }

  Widget MealIcon(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MealDetails(meal: this))),
      child: Card.filled(
          color: Colors.blue,
          child: Column(
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(this.Name),
              ]),
            ],
          )),
    );
  }
}
