
import 'package:menu_planner/Ingredient.dart';
import 'package:menu_planner/UI/MealDetails.dart';
import 'package:menu_planner/User.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

class tempMealRating {
  tempMealRating({required this.meal, required this.rating});

  Meal meal;
  double rating;
}

class Meal {
  Meal({required this.ID, required this.Name, required this.Ingredients});

  int ID;
  String Name;
  final List<Ingredient> Ingredients;

  static Future<Meal> toObject(Map<String, dynamic> input) async {
    return Meal(
      ID: input["ID"],
      Name: input["Name"],
      Ingredients: await Ingredient.getForMeal(input["ID"]),
    );
  }

  static Future<List<Meal>> getAll() async {
    var temp = await Supabase.instance.client.from("Meal").select();
    List<Meal> output = List.empty(growable: true);
    for (var i in temp) {
      output.add(await toObject(i));
    }
    return output;
  }

  static Future<Meal> getByID(int id) async {
    return await toObject(
        (await Supabase.instance.client.from("Meal").select().eq("ID", id))
            .first);
  }

  static Future<Meal> getByName(String name) async {
    return await toObject(
        (await Supabase.instance.client.from("Meal").select().eq("Name", name))
            .first);
  }

  Future<void> pushToDatabase(List<bool> ingredientsOptional) async {
    var temp = await Supabase.instance.client.from("Meal").insert({
      "Name": Name,
    }).select();
    ID = temp[0]["ID"];

    for (int i = 0; i < Ingredients.length; i++) {
      await Supabase.instance.client.from("MealIngredient").insert({
        "MealID": ID,
        "IngredientID": Ingredients[i].ID,
        "IsOptional": ingredientsOptional[i]
      });
    }

    await Supabase.instance.client.from("UserMeal").insert({
      "UserID": Supabase.instance.client.auth.currentUser!.id,
      "MealID": ID
    });
  }

  static Future<Meal> calculateBestMeal(DateTime date) async {
    var tempmeals = await getAll();

    List<AttributeWant> attributeWants = await AttributeWant.getForUser(
        Supabase.instance.client.auth.currentUser!.id);

    List<tempMealRating> meals = List.generate(tempmeals.length,
        (i) => tempMealRating(meal: tempmeals[i], rating: 5.0));

    var previousMealsTemp = await Supabase.instance.client
        .from("MealDate")
        .select()
        .lt("Date", date.toString())
        .eq("User", Supabase.instance.client.auth.currentUser!.id)
        .order("Date", ascending: false)
        .limit(7);

    for (var i in previousMealsTemp) {
      var temp = await getByID(i["MealID"]);

      for (var ingredient in temp.Ingredients) {
        for (var attribute in ingredient.Attributes) {
          for (var attributeWant in attributeWants) {
            if (attribute == attributeWant.attribute) {
              attributeWant.amountInWeek += 1;
            }
          }
        }
      }
    }

    for (var meal in meals) {
      for (var attribute in attributeWants) {
        for (var ingredient in meal.meal.Ingredients) {
          if (ingredient.Attributes.contains(attribute.attribute)) {
            if (attribute.tooMuchIsBad) {
              if (attribute.amount < attribute.amountInWeek) {
                meal.rating += attribute.amount / 7;
              } else {
                meal.rating -= attribute.amount / 7;
              }
            } else {
              if (attribute.amount < attribute.amountInWeek) {
                meal.rating -= attribute.amount / 7;
              } else {
                meal.rating += attribute.amount / 7;
              }
            }
          }
        }
      }
    }
    meals.sort((a, b) => b.rating.compareTo(a.rating));

    await Supabase.instance.client.from("MealDate").insert({
      "Date": date.toString(),
      "User": Supabase.instance.client.auth.currentUser!.id,
      "MealID": meals.first.meal.ID
    });
    return meals.first.meal;
  }

  Widget MealIcon(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (context) => MealDetails(meal: this))),
      child: Card.filled(
          color: Colors.blue,
          child: Column(
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(Name),
              ]),
            ],
          )),
    );
  }
}
