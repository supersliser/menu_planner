import 'package:flutter/material.dart';
import 'package:menu_planner/Ingredient.dart';
import 'package:menu_planner/Meal.dart';
import 'package:menu_planner/UI/CreateNewIngredient.dart';
import 'package:menu_planner/UI/Navbar.dart';

class CreateNewMeal extends StatefulWidget {
  const CreateNewMeal({super.key});

  @override
  State<CreateNewMeal> createState() => _CreateNewMealState();
}

class _CreateNewMealState extends State<CreateNewMeal> {
  var nameController = TextEditingController();
  var searchController = TextEditingController();

  bool listsSet = false;
  List<bool> ingredientOptional = [];
  List<bool> ingredientSelected = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("New meal")),
      bottomNavigationBar: const Navbar(
        currentPageIndex: 2,
      ),
      body: FutureBuilder(
          future: Ingredient.getAll(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: Text("Loading..."));
            }
            List<int> displayIngredients = List.empty(growable: true);
            for (int i = 0; i < snapshot.data!.length; i++) {
              if (snapshot.data![i].Name
                  .toLowerCase()
                  .contains(searchController.text.toLowerCase())) {
                displayIngredients.add(i);
              }
            }
            if (!listsSet) {
              ingredientSelected = List.filled(snapshot.data!.length, false, growable: true);
              ingredientOptional = List.filled(snapshot.data!.length, false, growable: true);
              listsSet = true;
            }
            return Center(
              child: SizedBox(
                width: 400,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                            labelText: "Name of the meal"),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card.filled(
                          color:
                              Theme.of(context).colorScheme.tertiaryContainer,
                          child: Column(children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  const Text("Ingredients"),
                                  ElevatedButton(
                                      onPressed: () async {
                                        final temp = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const CreateNewIngredient()));
                                        if (!context.mounted || temp == null) return;
                                        setState(() {
                                          ingredientOptional.add(false);
                                          ingredientSelected.add(false);
                                          snapshot.data!.add(temp);
                                        });
                                      },
                                      child: const Text("Add New Ingredient"))
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: TextField(
                                autocorrect: true,
                                controller: searchController,
                                onChanged: (value) => setState(() {}),
                                decoration: const InputDecoration(
                                    labelText: "Search ingredients"),
                              ),
                            ),
                            for (int i = 0; i < snapshot.data!.length; i++)
                              if (searchController.text.isEmpty ||
                                  displayIngredients.contains(i))
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 8, right: 8),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Checkbox(
                                              value: ingredientSelected[i],
                                              onChanged: (val) {
                                                setState(() {
                                                  ingredientSelected[i] = val!;
                                                });
                                              }),
                                          Text(snapshot.data![i].Name +
                                              (snapshot.data![i]
                                                          .CookingMethod !=
                                                      "null"
                                                  ? ", ${snapshot.data![i]
                                                          .CookingMethod}"
                                                  : ""))
                                        ],
                                      ),
                                      const Padding(padding: EdgeInsets.all(8.0)),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          const Text("("),
                                          Checkbox(
                                              value: ingredientOptional[i],
                                              onChanged: (val) {
                                                setState(() {
                                                  ingredientOptional[i] = val!;
                                                });
                                              }),
                                          const Text("Optional"),
                                          const Text("  )"),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                          ]),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                            onPressed: () async {
                              var ingredients = snapshot.data!;
                              ingredients.removeWhere(
                                  (element) => !ingredientSelected[ingredients
                                      .indexOf(element)]);
                              var temp = Meal(
                                  ID: -1,
                                  Name: nameController.text,
                                  Ingredients: ingredients);
                              await temp.pushToDatabase(ingredientOptional);
                              Navigator.pop(context);
                            },
                            child: const Text("Create New Meal")),
                      )
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }
}
