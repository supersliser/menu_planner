
import 'package:counter_slider/counter_slider.dart';
import 'package:flutter/material.dart';
import 'package:menu_planner/Attribute.dart';
import 'package:menu_planner/UI/Navbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditAttributeWantsPage extends StatelessWidget {
  const EditAttributeWantsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit attributes")),
      body: const EditAttributeWants(),
      bottomNavigationBar: Navbar(currentPageIndex: 4,),);
  }
}

class EditAttributeWants extends StatelessWidget {
  const EditAttributeWants({super.key});

  Future<List<Widget>> getAttributeSliders() async {
    List<Widget> output = List.empty(growable: true);
    var temp = await Supabase.instance.client
        .from("UserAttributeWants")
        .select("*, IngredientAttribute(*)")
        .eq("UserID", Supabase.instance.client.auth.currentUser!.id);

    for (var i in temp) {
      if (i["IngredientAttribute"]["WantedDataType"] == "Int") {
        output.add(IntDisplay(
            attribute: Attribute(
                ID: i["IngredientAttribute"]["ID"],
                Name: i["IngredientAttribute"]["Name"],
                PluralDisplayText: i["IngredientAttribute"]
                    ["PluralDisplayText"],
                SingularDisplayText: i["IngredientAttribute"]
                    ["SingularDisplayText"],
                CanBeWanted: true),
            value: i["AmountPerWeek"],
            tooMuchBad: i["DontHaveTooMuch"]));
      } else if (i["IngredientAttribute"]["WantedDataType"] == "Bool") {
        output.add(BoolDisplay(
          attribute: Attribute(
              ID: i["IngredientAttribute"]["ID"],
              Name: i["IngredientAttribute"]["Name"],
              PluralDisplayText: i["IngredientAttribute"]["PluralDisplayText"],
              SingularDisplayText: i["IngredientAttribute"]
                  ["SingularDisplayText"],
              CanBeWanted: true),
          value: i["AmountPerWeek"] == 1,
          tooMuchBad: i["DontHaveTooMuch"],
        ));
      }
    }
    var tempUser = await Supabase.instance.client.from("Users")
        .select()
        .eq("UUID", Supabase.instance.client.auth.currentUser!.id)
        .single();
    output.add(BoolMealOnSundayDisplay(value: tempUser["WantsRoastOnSunday"]));
    return output;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getAttributeSliders(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
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
        });
  }
}

class IntDisplay extends StatefulWidget {
  IntDisplay(
      {super.key,
      required this.attribute,
      required this.value,
      required this.tooMuchBad});

  int value;
  bool tooMuchBad;
  final Attribute attribute;

  @override
  State<IntDisplay> createState() => _IntDisplayState();
}

class _IntDisplayState extends State<IntDisplay> {
  @override
  Widget build(BuildContext context) {
    return Card.filled(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
                "Amount of ${widget.attribute.PluralDisplayText} you want per week"),
            CounterSlider(
              value: widget.value,
              width: 400,
              height: 50,
              minValue: 0,
              maxValue: 7,
              onChanged: (value) async {
                await Supabase.instance.client
                    .from("UserAttributeWants")
                    .update({
                      "AmountPerWeek": value,
                    })
                    .eq("UserID", Supabase.instance.client.auth.currentUser!.id)
                    .eq("AttributeID", widget.attribute.ID);
                setState(() {
                  widget.value = value;
                });
              },
              slideFactor: 1,
            ),
            Row(
              children: [
                Checkbox(
                    value: widget.tooMuchBad,
                    onChanged: (value) async {
                      await Supabase.instance.client
                          .from("UserAttributeWants")
                          .update({"DontHaveTooMuch": value})
                          .eq("UserID",
                              Supabase.instance.client.auth.currentUser!.id)
                          .eq("AttributeID", widget.attribute.ID);
                      setState(() {
                        widget.tooMuchBad = value!;
                      });
                    }),
                Text("Is too much of this bad for you?")
              ],
            )
          ],
        ),
      ),
    );
  }
}

class BoolDisplay extends StatefulWidget {
  BoolDisplay(
      {super.key,
      required this.attribute,
      required this.value,
      required this.tooMuchBad});

  bool value;
  bool tooMuchBad;
  final Attribute attribute;

  @override
  State<BoolDisplay> createState() => _BoolDisplayState();
}

class _BoolDisplayState extends State<BoolDisplay> {
  @override
  Widget build(BuildContext context) {
    return Card.filled(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                Checkbox(
                    value: widget.value,
                    onChanged: (value) async {
                      await Supabase.instance.client
                          .from("UserAttributeWants")
                          .update({"AmountPerWeek": value! ? 1 : 0})
                          .eq("UserID",
                              Supabase.instance.client.auth.currentUser!.id)
                          .eq("AttributeID", widget.attribute.ID);
                      setState(() {
                        widget.value = value;
                      });
                    }),
                Text("Do you want any ${widget.attribute.PluralDisplayText}"),
              ],
            ),
            Row(
              children: [
                Checkbox(
                    value: widget.tooMuchBad,
                    onChanged: (value) async {
                      await Supabase.instance.client
                          .from("UserAttributeWants")
                          .update({"DontHaveTooMuch": value})
                          .eq("UserID",
                              Supabase.instance.client.auth.currentUser!.id)
                          .eq("AttributeID", widget.attribute.ID);
                      setState(() {
                        widget.tooMuchBad = value!;
                      });
                    }),
                Text("Is this bad for you?")
              ],
            )
          ],
        ),
      ),
    );
  }
}

class BoolMealOnSundayDisplay extends StatefulWidget {
  BoolMealOnSundayDisplay(
      {super.key,
      required this.value});

  bool value;

  @override
  State<BoolMealOnSundayDisplay> createState() => _BoolMealOnSundayDisplayState();
}

class _BoolMealOnSundayDisplayState extends State<BoolMealOnSundayDisplay> {
  @override
  Widget build(BuildContext context) {
    return Card.filled(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                Checkbox(
                    value: widget.value,
                    onChanged: (value) async {
                      await Supabase.instance.client
                          .from("Users")
                          .update({"WantsRoastOnSunday": value!})
                          .eq("UUID",
                              Supabase.instance.client.auth.currentUser!.id);
                      setState(() {
                        widget.value = value;
                      });
                    }),
                Text("Do you want to have a roast on Sunday?"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
