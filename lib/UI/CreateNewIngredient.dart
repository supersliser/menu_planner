import 'package:flutter/material.dart';
import 'package:menu_planner/Attribute.dart';
import 'package:menu_planner/Ingredient.dart';
import 'package:menu_planner/UI/Navbar.dart';

class CreateNewIngredient extends StatefulWidget {
  const CreateNewIngredient({super.key});

  @override
  State<CreateNewIngredient> createState() => _CreateNewIngredientState();
}

class _CreateNewIngredientState extends State<CreateNewIngredient> {
  
  var nameController = TextEditingController();
  var prepMethodController = TextEditingController();

  bool listsSet = false;
  List<bool> attributeSelected = [];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("New Ingredient")),
      bottomNavigationBar: const Navbar(currentPageIndex: 1),
      body: FutureBuilder(
        future: Attribute.getAll(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: Text("Loading..."));
          }
          if (!listsSet) {
            attributeSelected = List.filled(snapshot.data!.length, false);
            listsSet = true;
          }
          return Center(
            child: SizedBox(
              width: 400,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: "Name of the ingredient"),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: prepMethodController,
                        decoration: const InputDecoration(labelText: "Preparation Method"),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card.filled(
                        color: Theme.of(context).colorScheme.tertiaryContainer,
                        child: Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text("Attributes (select as many as are true): "),
                            ),
                            for (int i = 0; i < snapshot.data!.length; i++)
                              Row(
                                children: [
                                  Checkbox(
                                      value: attributeSelected[i],
                                      onChanged: (val) {
                                        setState(() {
                                          attributeSelected[i] = val!;
                                        });
                                      }),
                                  Text("This ingredient is ${snapshot.data![i].SingularDisplayText}")
                                ],
                              ),
                          ],),
                      ),
                    ),
                    ElevatedButton(onPressed: () async {
                      List<Attribute> tempList = List.empty(growable: true); 
                      for (int i = 0; i < attributeSelected.length; i++) {
                        if (attributeSelected[i]) {
                          tempList.add(snapshot.data![i]);
                        }
                      }
                      Ingredient temp = Ingredient(ID: -1, Name: nameController.text, CookingMethod: prepMethodController.text, Attributes: tempList);
                      await temp.pushToDatabase();
                      Navigator.pop(context, temp);
                    }, child: const Text("Add Ingredient")),
                  ],
                ),
              ),
            ),
          );
        }
      ),
    );
  }
}