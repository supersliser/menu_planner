import 'package:supabase_flutter/supabase_flutter.dart';
class Attribute {
  const Attribute({required this.ID, required this.Name, required this.PluralDisplayText, required this.SingularDisplayText, required this.CanBeWanted});

  final int ID;
  final String Name;
  final String PluralDisplayText;
  final String SingularDisplayText;
  final bool CanBeWanted;

  static Attribute toObject(Map<String, dynamic> input) {
    return Attribute(ID: input["ID"], Name: input["Name"], PluralDisplayText: input["PluralDisplayText"], SingularDisplayText: input["SingularDisplayText"], CanBeWanted: input["CanBeWanted"]);
  }

  static Future<List<Attribute>> getAll() async {
    var temp = await Supabase.instance.client.from("IngredientAttribute").select();
    return List.generate(temp.length, (i) => toObject(temp[i]));
  }

  static Future<Attribute> getByID(int id) async {
    return toObject((await Supabase.instance.client.from("IngredientAttribute").select().eq("ID", id)).first);
  }

  static Future<Attribute> getByName(String name) async {
    return toObject((await Supabase.instance.client.from("IngredientAttribute").select().eq("Name", name)).first);
  }

  static Future<List<Attribute>> getForIngredient(int ingredientID) async {
    List<Attribute> output = List.empty(growable: true);
    
    var temp = await Supabase.instance.client.from("AttributeOfIngredient").select().eq("IngredientID", ingredientID);
    
    for (var i in temp) {
      output.add(await getByID(i["AttributeID"]));
    }
    
    return output;
  }

  static Future<List<Attribute>> getForUser(String userID) async {
    List<Attribute> output = List.empty(growable: true);
    
    var temp = await Supabase.instance.client.from("UserAttributeWants").select().eq("UserID", userID);
    
    for (var i in temp) {
      output.add(await getByID(i["AttributeID"]));
    }
    
    return output;
  }
}