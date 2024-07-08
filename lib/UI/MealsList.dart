import 'package:flutter/material.dart';
import 'package:menu_planner/Meal.dart';
import 'package:menu_planner/UI/EditAttributeWants.dart';
import 'package:menu_planner/UI/EditOptionalIngredients.dart';
import 'package:menu_planner/UI/Navbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MealsList extends StatefulWidget {
  const MealsList({super.key});

  @override
  State<MealsList> createState() => _MealsListState();
}

class _MealsListState extends State<MealsList> {
  bool showUserList = false;
  bool showAdvancedSearchOptions = false;

  var searchTextController = TextEditingController();

  Widget ListItem(Meal meal, bool isUserList) {
    return SizedBox(
      height: 50,
      child: Card.outlined(
        color: Theme.of(context).colorScheme.secondaryContainer,
        child: Row(
          children: [
            Checkbox(
                value: isUserList,
                onChanged: (value) async {
                  if (!value!) {
                    await Supabase.instance.client
                        .from("UserMeal")
                        .delete()
                        .eq("UserID",
                            Supabase.instance.client.auth.currentUser!.id)
                        .eq("MealID", meal.ID);
                    setState(() {});
                  } else {
                    await Supabase.instance.client.from("UserMeal").insert({
                      "UserID": Supabase.instance.client.auth.currentUser!.id,
                      "MealID": meal.ID
                    });
                    setState(() {});
                    await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                EditOptionalIngredientsPage(mealID: meal.ID)));
                  }
                }),
            Text(meal.Name),
            Spacer(),
            isUserList
                ? ElevatedButton(
                    onPressed: () async {
                      await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EditOptionalIngredientsPage(
                                  mealID: meal.ID)));
                    },
                    child: Text("Edit"))
                : Container()
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add a meal to your list")),
      bottomNavigationBar: const Navbar(currentPageIndex: 3),
      body: Center(
        child: SizedBox(
          width: 350,
          child: SingleChildScrollView(
            child: Column(
              children: [
                ElevatedButton(
                    onPressed: () => setState(() {
                          showUserList = !showUserList;
                        }),
                    child: Text(
                        showUserList ? "Hide your list" : "Show your list")),
                Card.filled(
                  color: Theme.of(context).colorScheme.tertiaryContainer,
                  child: Column(children: [
                    Card.filled(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: searchTextController,
                                  decoration: const InputDecoration(
                                      labelText: "Search"),
                                  autocorrect: true,
                                  onChanged: (_) => setState(() {}),
                                ),
                              ),
                              // IconButton(
                              //   onPressed: () => setState(() {
                              //     showAdvancedSearchOptions = true;
                              //   }),
                              //   icon: const Icon(Icons.settings),
                              // ),
                            ],
                          ),
                        )),
                    showUserList
                        ? FutureBuilder(
                            future: Meal.getAllForUser(
                                Supabase.instance.client.auth.currentUser!.id),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return Center(
                                    child: Column(
                                  children: [
                                    Text("Loading..."),
                                    CircularProgressIndicator(),
                                    FutureBuilder(
                                        future: Future.delayed(
                                            Duration(seconds: 5)),
                                        builder: (context, snapshot) {
                                          if (!snapshot.hasData) {
                                            return Padding(
                                                padding: EdgeInsets.all(8.0));
                                          }
                                          return Column(
                                            children: [
                                              Text(
                                                  "You've added all available meals to your list"),
                                            ],
                                          );
                                        })
                                  ],
                                ));
                              }
                              List<Meal> displayMeals =
                                  List.empty(growable: true);
                              for (int i = 0; i < snapshot.data!.length; i++) {
                                if (snapshot.data![i].Name
                                    .toLowerCase()
                                    .contains(searchTextController.text
                                        .toLowerCase())) {
                                  displayMeals.add(snapshot.data![i]);
                                }
                              }
                              if (displayMeals.isEmpty) {
                                return Center(
                                  child: Text("You need to add some meals to your list first"),
                                );
                              }
                              return Column(children: [
                                for (int i = 0; i < displayMeals.length; i++)
                                  ListItem(displayMeals[i], true),
                              ]);
                            })
                        : FutureBuilder(
                            future: Meal.getNewForUser(
                                Supabase.instance.client.auth.currentUser!.id),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return Center(
                                    child: Column(
                                  children: [
                                    Text("Loading..."),
                                    CircularProgressIndicator(),
                                    FutureBuilder(
                                        future: Future.delayed(
                                            Duration(seconds: 5)),
                                        builder: (context, snapshot) {
                                          if (!snapshot.hasData) {
                                            return Padding(
                                                padding: EdgeInsets.all(8.0));
                                          }
                                          return Column(
                                            children: [
                                              Text(
                                                  "You've added all available meals to your list"),
                                            ],
                                          );
                                        })
                                  ],
                                ));
                              }
                              List<Meal> displayMeals =
                                  List.empty(growable: true);
                              for (int i = 0; i < snapshot.data!.length; i++) {
                                if (snapshot.data![i].Name
                                    .toLowerCase()
                                    .contains(searchTextController.text
                                        .toLowerCase())) {
                                  displayMeals.add(snapshot.data![i]);
                                }
                              }
                              return Column(children: [
                                for (int i = 0; i < displayMeals.length; i++)
                                  ListItem(displayMeals[i], false)
                              ]);
                            })
                  ]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
