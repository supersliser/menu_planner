import 'package:cloud_firestore/cloud_firestore.dart';

class Meal {
  Meal({required this.id, required this.Name, this.inDatabase = false});

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'],
      Name: json['Name'],
      inDatabase: true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'Name': Name,
    };
  }

  final String id;
  final String Name;
  bool inDatabase = false;

  void pushToDatabase() {
    // Add this meal to the database
    var db = FirebaseFirestore.instance;

    db.collection("Meal").add(toJson());
    inDatabase = true;
  }

  Future<List<Meal>> pullAllFromDatabase() async {
    var db = FirebaseFirestore.instance;
    var temp = await db.collection("Meal").get();

    List<Meal> output = List.empty(growable: true);

    for (var i in temp.docs) {
      output.add(Meal.fromJson(i.data()));
    }

    return output;
  }

  Future<Meal> pullFromDatabaseByName(String name) async {
    var db = FirebaseFirestore.instance;
    var temp = await db.collection("Meal").where("Name", isEqualTo: name).get();
     inDatabase = true;
    return Meal.fromJson(temp.docs.first.data());
  }

  Future<Meal> pullFromDatabaseById(String id) async {
    var db = FirebaseFirestore.instance;
    var temp = await db.collection("Meal").where("id", isEqualTo: id).get();
     inDatabase = true;
    return Meal.fromJson(temp.docs.first.data());
  }
}
