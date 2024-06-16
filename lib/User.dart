import 'package:menu_planner/Attribute.dart';
import 'package:menu_planner/Meal.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AttributeWant {
  AttributeWant({required this.attribute, required this.amount, required this.tooMuchIsBad, this.amountInWeek = 0});

  final Attribute attribute;
  final int amount;
  final bool tooMuchIsBad;
  int amountInWeek;

  static Future<List<AttributeWant>> getForUser(String userID) async {
    List<AttributeWant> output = List.empty(growable: true);
    
    var temp = await Supabase.instance.client.from("UserAttributeWants").select().eq("UserID", userID);
    
    for (var i in temp) {
      output.add(AttributeWant(attribute: await Attribute.getByID(i["AttributeID"]), amount: i["AmountPerWeek"], tooMuchIsBad: i["DontHaveTooMuch"]));
    }
    
    return output;
  }
}

class User {
  const User({required this.ID, required this.Name, required this.Attributes});

  final String ID;
  final String Name;
  final List<AttributeWant> Attributes;

  static Future<User> toObject(Map<String, dynamic> input) async {
    return User(ID: input["UUID"], Name: input["Username"], Attributes: await AttributeWant.getForUser(input["UUID"]));
  }

  static Future<User> getByID(String id) async {
    return toObject((await Supabase.instance.client.from("Users").select().eq("UUID", id)).first);
  }

  static Future<User> getByName(String name) async {
    return toObject((await Supabase.instance.client.from("Users").select().eq("Username", name)).first);
  }

  Future<Meal> getMealForDate(DateTime date) async {
    var temp = await Supabase.instance.client.from("MealDate").select().eq("Date", date.toString()).eq("User", ID).limit(1);

    if (temp.isEmpty) {
      return await Meal.calculateBestMeal(date);
    } else {
      return await Meal.getByID(temp.first["MealID"]);
    }
  }
}