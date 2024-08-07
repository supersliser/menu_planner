import 'dart:math';

import 'package:menu_planner/Attribute.dart';
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
    print("starting");
    bool anon = Supabase.instance.client.auth.currentUser!.id ==
            "ef42fb45-b0f9-4759-9db8-946ff14e697c";
    var meals = anon
        ? await Supabase.instance.client.from("Meal").select().eq("Name", "Roast Chicken")
        : await Supabase.instance.client
            .from("UserMeal")
            .select("Meal(ID, Name)")
            .eq("UserID", Supabase.instance.client.auth.currentUser!.id);
    if (meals.length == 0) {
      return [];
    }
    var mealIngredients =
        await Supabase.instance.client.from("MealIngredient").select();
    var ingredients =
        await Supabase.instance.client.from("Ingredient").select();
    var ingredientAttributes =
        await Supabase.instance.client.from("AttributeOfIngredient").select();
    var attributes =
        await Supabase.instance.client.from("IngredientAttribute").select();
    List<Meal> output = List.empty(growable: true);
    for (int i = 0; i < meals.length; i++) {
      print("setting up meal ${meals[i]["Name"]}");
      var tempMealIngredients = mealIngredients
          .where((element) => element["MealID"] == meals[i]["ID"])
          .toList();
      var tempIngredients = ingredients
          .where((element2) => tempMealIngredients
              .any((element) => element["IngredientID"] == element2["ID"]))
          .toList();
      List<List<Map<String, dynamic>>> tempIngredientAttributes =
          List.empty(growable: true);
      List<List<Map<String, dynamic>>> tempAttributes =
          List.empty(growable: true);

      for (int j = 0; j < tempIngredients.length; j++) {
        tempIngredientAttributes.add(ingredientAttributes
            .where((element2) =>
                element2["IngredientID"] == tempIngredients[j]["ID"])
            .toList());
        tempAttributes.add(attributes
            .where((element2) => tempIngredientAttributes[j]
                .where((element) => element["AttributeID"] == element2["ID"])
                .isNotEmpty)
            .toList());
      }
      output.add(Meal(
          ID: anon ? meals[i]["ID"] : meals[i]["Meal"]["ID"],
          Name: anon ? meals[i]["Name"] : meals[i]["Meal"]["Name"],
          Ingredients: List.generate(
              tempMealIngredients.length,
              (j) => Ingredient(
                  ID: tempIngredients[j]["ID"],
                  Name: tempIngredients[j]["Name"],
                  CookingMethod: tempIngredients[j]["CookingMethod"],
                  Attributes: List.generate(
                      tempIngredientAttributes[j].length,
                      (k) => Attribute(
                          ID: tempAttributes[j][k]["ID"],
                          CanBeWanted: tempAttributes[j][k]["CanBeWanted"],
                          Name: tempAttributes[j][k]["Name"],
                          PluralDisplayText: tempAttributes[j][k]
                              ["PluralDisplayText"],
                          SingularDisplayText: tempAttributes[j][k]
                              ["SingularDisplayText"]))))));
    }
    return output;
  }

  static Future<List<Meal>> getNewForUser(String UserID) async {
    // get 30 random meals that are not added by the user using the same methods as getAll and getAllForUser
    var userMeals = await Supabase.instance.client
        .from("UserMeal")
        .select()
        .eq("UserID", UserID);
    var mealIngredients =
        await Supabase.instance.client.from("MealIngredient").select();
    var ingredients =
        await Supabase.instance.client.from("Ingredient").select();
    var ingredientAttributes =
        await Supabase.instance.client.from("AttributeOfIngredient").select();
    var attributes =
        await Supabase.instance.client.from("IngredientAttribute").select();
    List<Meal> output = List.empty(growable: true);
    var possibleMeals =
        await Supabase.instance.client.from("Meal").select().limit(30);
    for (int i = 0; i < possibleMeals.length; i++) {
      if (!userMeals
          .any((element) => element["MealID"] == possibleMeals[i]["ID"])) {
        var tempMealIngredients = mealIngredients
            .where((element) => element["MealID"] == possibleMeals[i]["ID"])
            .toList();
        var tempIngredients = ingredients
            .where((element2) => tempMealIngredients
                .any((element) => element["IngredientID"] == element2["ID"]))
            .toList();
        List<List<Map<String, dynamic>>> tempIngredientAttributes =
            List.empty(growable: true);
        List<List<Map<String, dynamic>>> tempAttributes =
            List.empty(growable: true);
        for (int j = 0; j < tempIngredients.length; j++) {
          tempIngredientAttributes.add(ingredientAttributes
              .where((element2) =>
                  element2["IngredientID"] == tempIngredients[j]["ID"])
              .toList());
          tempAttributes.add(attributes
              .where((element2) => tempIngredientAttributes[j]
                  .where((element) => element["AttributeID"] == element2["ID"])
                  .isNotEmpty)
              .toList());
        }
        output.add(Meal(
            ID: possibleMeals[i]["ID"],
            Name: possibleMeals[i]["Name"],
            Ingredients: List.generate(
                tempMealIngredients.length,
                (j) => Ingredient(
                    ID: tempIngredients[j]["ID"],
                    Name: tempIngredients[j]["Name"],
                    CookingMethod: tempIngredients[j]["CookingMethod"],
                    Attributes: List.generate(
                        tempIngredientAttributes[j].length,
                        (k) => Attribute(
                            ID: tempAttributes[j][k]["ID"],
                            CanBeWanted: tempAttributes[j][k]["CanBeWanted"],
                            Name: tempAttributes[j][k]["Name"],
                            PluralDisplayText: tempAttributes[j][k]
                                ["PluralDisplayText"],
                            SingularDisplayText: tempAttributes[j][k]
                                ["SingularDisplayText"]))))));
      }
    }
    return output;
  }

  static Future<List<Meal>> getAllForUser(String UserID) async {
    var meals =
        await Supabase.instance.client.from("UserMeal").select("Meal(*)").eq("UserID", UserID);
    var mealIngredients =
        await Supabase.instance.client.from("MealIngredient").select();
    var ingredients =
        await Supabase.instance.client.from("Ingredient").select();
    var ingredientAttributes =
        await Supabase.instance.client.from("AttributeOfIngredient").select();
    var attributes =
        await Supabase.instance.client.from("IngredientAttribute").select();
    List<Meal> output = List.empty(growable: true);
    for (int i = 0; i < meals.length; i++) {
      var tempMealIngredients = mealIngredients
          .where((element) => element["MealID"] == meals[i]["Meal"]["MealID"])
          .toList();
      var tempIngredients = ingredients
          .where((element2) => tempMealIngredients
              .any((element) => element["IngredientID"] == element2["ID"]))
          .toList();
      List<List<Map<String, dynamic>>> tempIngredientAttributes =
          List.empty(growable: true);
      List<List<Map<String, dynamic>>> tempAttributes =
          List.empty(growable: true);

      for (int j = 0; j < tempIngredients.length; j++) {
        tempIngredientAttributes.add(ingredientAttributes
            .where((element2) =>
                element2["IngredientID"] == tempIngredients[j]["ID"])
            .toList());
        tempAttributes.add(attributes
            .where((element2) => tempIngredientAttributes[j]
                .where((element) => element["AttributeID"] == element2["ID"])
                .isNotEmpty)
            .toList());
      }
      output.add(Meal(
          ID: meals[i]["Meal"]["ID"],
          Name: meals[i]["Meal"]["Name"],
          Ingredients: List.generate(
              tempMealIngredients.length,
              (j) => Ingredient(
                  ID: tempIngredients[j]["ID"],
                  Name: tempIngredients[j]["Name"],
                  CookingMethod: tempIngredients[j]["CookingMethod"],
                  Attributes: List.generate(
                      tempIngredientAttributes[j].length,
                      (k) => Attribute(
                          ID: tempAttributes[j][k]["ID"],
                          CanBeWanted: tempAttributes[j][k]["CanBeWanted"],
                          Name: tempAttributes[j][k]["Name"],
                          PluralDisplayText: tempAttributes[j][k]
                              ["PluralDisplayText"],
                          SingularDisplayText: tempAttributes[j][k]
                              ["SingularDisplayText"]))))));
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

  static bool intMealListContains(List<int> list, int id) {
    int min = 0;
    int max = list.length - 1;
    while (min <= max) {
      int mid = (min + max) >> 1;
      if (list[mid] == id) {
        return true;
      } else if (list[mid] > id) {
        max = mid - 1;
      } else {
        min = mid + 1;
      }
    }
    return false;
  }

  static bool mealListcontains(List<Meal> list, Meal meal) {
    int min = 0;
    int max = list.length - 1;
    while (min <= max) {
      int mid = (min + max) >> 1;
      if (list[mid].Name.compareTo(meal.Name) == 0) {
        return true;
      } else if (list[mid].Name.compareTo(meal.Name) > 0) {
        max = mid - 1;
      } else {
        min = mid + 1;
      }
    }
    return false;
  }

  static Future<Meal?> calculateBestMeal(DateTime date) async {
    var tempmeals = await getAll();
    if (tempmeals.isEmpty) {
      return null;
    }

    print(1);
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

    List<int> previousMeals = List.empty(growable: true);
    for (var i in previousMealsTemp) {
      previousMeals.add(i["MealID"]);
    }

    previousMeals.sort();
    print(2);

    for (var i in previousMeals) {
      var temp = await getByID(i);

      for (var ingredient in temp.Ingredients) {
        for (var attribute in attributeWants) {
          ingredient.Attributes.sort((a, b) => a.Name.compareTo(b.Name));
          if (Attribute.attributeListContains(
              ingredient.Attributes, attribute.attribute)) {
            attribute.amountHad += 1;
          }
        }
      }
    }
    int subtractor = 7;
    for (var meal in meals) {
      if (Meal.intMealListContains(previousMeals, meal.meal.ID)) {
        meal.rating -= subtractor;
        subtractor--;
      }

      for (var ingredient in meal.meal.Ingredients) {
        ingredient.Attributes.sort((a, b) => a.ID.compareTo(b.ID));
        if ((await Supabase.instance.client
                .from("Users")
                .select()
                .eq("UUID", Supabase.instance.client.auth.currentUser!.id))
            .first["WantsRoastOnSunday"]) {
          if (Attribute.intAttributeListContains(ingredient.Attributes, 10)) {
            if (date.weekday != 7) {
              meal.rating -= 50;
            } else {
              meal.rating += 50;
            }
          }
        }
        for (var ingredientAttribute in ingredient.Attributes) {
          int att =
              Attribute.findAttributeWants(attributeWants, ingredientAttribute);
          if (att != -1) {
            if (attributeWants[att].amountHad <
                attributeWants[att].amountWanted) {
              meal.rating += 5;
            } else {
              meal.rating -= attributeWants[att].tooMuchIsBad ? 5 : -5;
            }
          }
        }
      }
    }
    meals.sort((a, b) => b.rating.compareTo(a.rating));
    var outputMeals =
        meals.where((element) => element.rating == meals.first.rating).toList();
    print(3);

    for (var i in meals) {
      print("${i.meal.Name}: ${i.rating}");
    }
    var outputMeal = outputMeals[Random().nextInt(outputMeals.length)];
    if (Supabase.instance.client.auth.currentUser!.id !=
        "ef42fb45-b0f9-4759-9db8-946ff14e697c") {
      await Supabase.instance.client.from("MealDate").insert({
        "Date": date.toString(),
        "User": Supabase.instance.client.auth.currentUser!.id,
        "MealID": outputMeal.meal.ID
      });
    }
    return outputMeal.meal;
  }

  Widget MealIcon(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: GestureDetector(
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => MealDetails(meal: this))),
        child: Card.filled(
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(Name),
                const Icon(Icons.fastfood, size: 100),
              ],
            )),
      ),
    );
  }
}
