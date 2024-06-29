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
          print("setting up ingredient ${input["Name"]}");

      return Ingredient(
          ID: input["ID"],
          Name: input["Name"],
          CookingMethod: input["CookingMethod"].toString(),
          Attributes: temp);
  }

  Future<void> pushToDatabase() async {
    var temp = await Supabase.instance.client.from("Ingredient").insert({
      "Name": Name,
      "CookingMethod": CookingMethod == "" ? "null" : CookingMethod
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
    var ingredients = await Supabase.instance.client.from("Ingredient").select();
    var ingredientAttributes =
        await Supabase.instance.client.from("AttributeOfIngredient").select();
    var attributes =
        await Supabase.instance.client.from("IngredientAttribute").select();
    List<Ingredient> temp = List.empty(growable: true);
    for (int i = 0; i < ingredients.length; i++) {
      print("setting up ingredient ${ingredients[i]["Name"]}");
      List<Attribute> tempAttributes = List.empty(growable: true);
      for (int j = 0; j < attributes.length; j++) {
        if (ingredientAttributes
            .where((element) =>
                element["IngredientID"] == ingredients[i]["ID"] &&
                element["AttributeID"] == attributes[j]["ID"])
            .isNotEmpty) {
          tempAttributes.add(Attribute(
              ID: attributes[j]["ID"],
              CanBeWanted: attributes[j]["CanBeWanted"],
              Name: attributes[j]["Name"],
              PluralDisplayText: attributes[j]["PluralDisplayText"],
              SingularDisplayText: attributes[j]["SingularDisplayText"]));
        }
      }
      temp.add(Ingredient(ID: ingredients[i]["ID"], Name: ingredients[i]["Name"], CookingMethod: ingredients[i]["CookingMethod"], Attributes: tempAttributes));
    
    }
    return temp;
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

    print("getting ingredients for meal $id");
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
