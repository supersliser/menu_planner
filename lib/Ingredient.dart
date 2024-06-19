import 'Attribute.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Ingredient {
  Ingredient({required this.ID, required this.Name, required this.CookingMethod, required this.Attributes});

  int ID;
  String Name;
  String CookingMethod;
  List<Attribute> Attributes;

  static Future<Ingredient> toObject(Map<String, dynamic> input) async {
    var temp = await Attribute.getForIngredient(input["ID"]);
      return Ingredient(
          ID: input["ID"],
          Name: input["Name"],
          CookingMethod: input["CookingMethod"].toString(),
          Attributes: temp);
  }

  Future<void> pushToDatabase() async {
    var temp = await Supabase.instance.client.from("Ingredient").insert({
      "Name": Name,
      "CookingMethod": CookingMethod
    }).select();

    ID = temp[0]["ID"];

    for (var i in Attributes) {
      await Supabase.instance.client.from("AttributeOfIngredient").insert({
        "IngredientID": ID,
        "AttributeID": i.ID,
      });
    }
  }

  static Future<List<Ingredient>> getAll() async {
    var temp = await Supabase.instance.client.from("Ingredient").select();
    List<Ingredient> output = List.empty(growable: true);
    for (var i in temp) {
      output.add(await toObject(i));
    }
    return output;
  }

  static Future<Ingredient> getByID(int id) async {
    return await toObject((await Supabase.instance.client
            .from("Ingredient")
            .select()
            .eq("ID", id))
        .first);
  }

  static Future<Ingredient> getByName(String name) async {
    return await toObject((await Supabase.instance.client
            .from("Ingredient")
            .select()
            .eq("Name", name))
        .first);
  }

  static Future<List<Ingredient>> getForMeal(int id) async {
    List<Ingredient> output = List.empty(growable: true);

    var temp = await Supabase.instance.client
        .from("MealIngredient")
        .select()
        .eq("MealID", id);

    for (var i in temp) {
      output.add(await getByID(i["IngredientID"]));
    }

    return output;
  }

  static Future<bool> getOptional(int MealID, int ID) async {
    return (await Supabase.instance.client
            .from("MealIngredient")
            .select()
            .filter("MealID", "eq", MealID)
            .filter("IngredientID", "eq", ID))
        .first["IsOption"];
  }
}
