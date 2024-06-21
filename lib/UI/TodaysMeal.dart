import 'package:flutter/material.dart';
import 'package:menu_planner/Meal.dart';
import 'package:menu_planner/UI/CreateNewUser.dart';
import 'package:menu_planner/UI/Navbar.dart';
import 'package:menu_planner/User.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TodaysMeal extends StatefulWidget {
  TodaysMeal({super.key});

  DateTime date = DateTime.now();
  late UserData user;

  @override
  State<TodaysMeal> createState() => _TodaysMealState();
}

class _TodaysMealState extends State<TodaysMeal> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Today's meal")),
      bottomNavigationBar: const Navbar(currentPageIndex: 0),
      body: Card.filled(
        color: Theme.of(context).colorScheme.tertiaryContainer,
        child: FutureBuilder(
            future: setup(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: Text("Loading..."));
              }
              return dateCardItem(context, widget.date, snapshot.data!);
            }),
      ),
    );
  }

  Future<Meal> setup() async {
    widget.user =
        await UserData.getByID(Supabase.instance.client.auth.currentUser!.id);
    // for (int i = 1; i < 27; i++) {
    //   if (i != 11) {
    //     await Supabase.instance.client.from("UserMeal").insert(
    //         {"UserID": widget.user.ID, "MealID": i});
    //   }
    // }

    return await widget.user.getMealForDate(widget.date);
  }

  Widget dateCardItem(BuildContext context, DateTime date, Meal meal) {
    return Column(
      children: [
        SizedBox(
          width: 150,
          height: 200,
          child: Card.filled(
              color: Colors.white,
              child: Column(
                children: [
                  Text(date.day.toString()),
                  Text("${date.month}, ${date.year}"),
                ],
              )),
        ),
        meal.MealIcon(context)
      ],
    );
  }
}
