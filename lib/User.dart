import 'package:menu_planner/Attribute.dart';
import 'package:menu_planner/Meal.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AttributeWant {
  AttributeWant(
      {required this.attribute,
      required this.amountWanted,
      required this.tooMuchIsBad,
      this.amountHad = 0});

  final Attribute attribute;
  final int amountWanted;
  final bool tooMuchIsBad;
  int amountHad;

  static Future<List<AttributeWant>> getForUser(String userID) async {
    List<AttributeWant> output = List.empty(growable: true);

    var temp = await Supabase.instance.client
        .from("UserAttributeWants")
        .select()
        .eq("UserID", userID);

    for (var i in temp) {
      output.add(AttributeWant(
          attribute: await Attribute.getByID(i["AttributeID"]),
          amountWanted: i["AmountPerWeek"],
          tooMuchIsBad: i["DontHaveTooMuch"]));
    }

    return output;
  }

  static Future<List<AttributeWant>> getDefault() async {
    List<AttributeWant> output = List.empty(growable: true);
    var temp = await Supabase.instance.client
        .from("IngredientAttribute")
        .select()
        .eq("CanBeWanted", true);
    for (var i in temp) {
      output.add(AttributeWant(
          attribute: Attribute(
              ID: i["ID"],
              Name: i["Name"],
              CanBeWanted: true,
              SingularDisplayText: i["SingularDisplayText"],
              PluralDisplayText: i["PluralDisplayText"]),
          amountWanted: i["DefaultWantedValues"],
          tooMuchIsBad: i["DefaultDontHaveTooMuch"]));
    }
    return output;
  }
}

class UserData {
  UserData({this.ID = "-1", required this.Name, required this.Attributes});

  String ID;
  final String Name;
  final List<AttributeWant> Attributes;

  static Future<UserData> toObject(Map<String, dynamic> input) async {
    return UserData(
        ID: input["UUID"],
        Name: input["Username"],
        Attributes: await AttributeWant.getForUser(input["UUID"]));
  }

  static Future<UserData> getByID(String id) async {
    return toObject(
        (await Supabase.instance.client.from("Users").select().eq("UUID", id))
            .first);
  }

  Future<void> pushToDatabase(String email, String password) async {
    if (email != "" && password != "") {
      await Supabase.instance.client.auth
          .signUp(email: email, password: password);
      await Supabase.instance.client.auth
          .signInWithPassword(email: email, password: password);
    }
    ID = Supabase.instance.client.auth.currentUser!.id;
    await Supabase.instance.client
        .from("Users")
        .insert({"UUID": ID, "Username": Name, "WantsRoastOnSunday": false});
    for (var i in Attributes) {
      await Supabase.instance.client.from("UserAttributeWants").insert({
        "UserID": ID,
        "AttributeID": i.attribute.ID,
        "AmountPerWeek": i.amountWanted,
        "DontHaveTooMuch": i.tooMuchIsBad
      });
    }
  }

  static Future<UserData> getByName(String name) async {
    return toObject((await Supabase.instance.client
            .from("Users")
            .select()
            .eq("Username", name))
        .first);
  }

  Future<Meal?> getMealForDate(DateTime date) async {
    var temp = await Supabase.instance.client
        .from("MealDate")
        .select()
        .eq("Date", date.toString())
        .eq("User", ID)
        .limit(1);

    if (temp.isEmpty) {
      return await Meal.calculateBestMeal(date); 
    } else {
      return await Meal.getByID(temp.first["MealID"]);
    }
  }
}
