import 'package:flutter/material.dart';
import 'package:menu_planner/Ingredient.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditOptionalIngredientsPage extends StatelessWidget {
  const EditOptionalIngredientsPage({super.key, required this.mealID});

  final int mealID;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit optional ingredients")),
      body: EditOptionalIngredients(mealID: mealID),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pop(context),
        child: Text("Done"),
      ),
    );
  }
}

class EditOptionalIngredients extends StatelessWidget {
  EditOptionalIngredients({super.key, required this.mealID});

  final int mealID;

  Future<List<Widget>> getIngedients() async {
    List<Widget> output = List.empty(growable: true);
    var temp = await Supabase.instance.client
        .from("MealIngredient")
        .select("*, Ingredient(*)")
        .eq("MealID", mealID)
        .eq("IsOptional", true);
    for (var i in temp) {
          var tempUserMealIngredient = await Supabase.instance.client
        .from("UserMealIngredient")
        .select()
        .eq("UserID", Supabase.instance.client.auth.currentUser!.id)
        .eq("MealID", mealID)
        .eq("IngredientID", i["Ingredient"]["ID"]);
      output.add(IngredientItem(
          ingredient: Ingredient(
              ID: i["Ingredient"]["ID"],
              Name: i["Ingredient"]["Name"],
              CookingMethod: i["Ingredient"]["CookingMethod"],
              Attributes: List.empty(growable: true)),
          value: tempUserMealIngredient.isNotEmpty,
          MealID: mealID));
    }
    return output;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getIngedients(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.data!.isEmpty) {
          Navigator.pop(context);
        }
        return Center(
          child: SizedBox(
            width: 450,
            child: Card.filled(
              color: Theme.of(context).colorScheme.tertiaryContainer,
              child: SingleChildScrollView(
                child: Column(children: snapshot.data!),
              ),
            ),
          ),
        );
      },
    );
  }
}

class IngredientItem extends StatefulWidget {
  IngredientItem(
      {super.key,
      required this.ingredient,
      required this.value,
      required this.MealID});
  final Ingredient ingredient;
  final int MealID;
  bool value;

  @override
  State<IngredientItem> createState() => _IngredientItemState();
}

class _IngredientItemState extends State<IngredientItem> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 50,
        child: Card.outlined(
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: Row(
              children: [
                Checkbox(
                    value: widget.value,
                    onChanged: (value) async {
                      if (!value!) {
                        await Supabase.instance.client
                            .from("UserMealIngredient")
                            .delete()
                            .eq("UserID",
                                Supabase.instance.client.auth.currentUser!.id)
                            .eq("IngredientID", widget.ingredient.ID)
                            .eq("MealID", widget.MealID);
                      } else {
                        await Supabase.instance.client
                            .from("UserMealIngredient")
                            .upsert({
                          "UserID":
                              Supabase.instance.client.auth.currentUser!.id,
                          "IngredientID": widget.ingredient.ID,
                          "MealID": widget.MealID
                        });
                      }
                      setState(() {
                        widget.value = value;
                      });
                    }),
                Text(widget.ingredient.Name)
              ],
            )));
  }
}
