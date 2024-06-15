import 'package:menu_planner/Attribute.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AttributeWant {
  const AttributeWant({required this.attribute, required this.amount, required this.tooMuchIsBad, this.amountInWeek = 0});

  final Attribute attribute;
  final int amount;
  final bool tooMuchIsBad;
  final int amountInWeek;

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
    return User(ID: input["ID"], Name: input["Name"], Attributes: await AttributeWant.getForUser(input["ID"]));
  }
}