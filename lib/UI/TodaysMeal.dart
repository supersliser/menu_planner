import 'package:flutter/material.dart';
import 'package:menu_planner/Meal.dart';
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
      bottomNavigationBar: const Navbar(currentPageIndex: 1),
      body: Card.filled(
        color: Theme.of(context).colorScheme.tertiaryContainer,
        child: FutureBuilder(
            future: setup(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                    child: Column(
                  children: [Text("Loading..."), CircularProgressIndicator()],
                ));
              }
              return dateCardItem(context, widget.date, snapshot.data!);
            }),
      ),
    );
  }

  Future<Meal> setup() async {
    widget.user =
        await UserData.getByID(Supabase.instance.client.auth.currentUser!.id);

    return await widget.user.getMealForDate(widget.date);
  }

  Widget dateCardItem(BuildContext context, DateTime date, Meal meal) {
    return Column(
      children: [
        Center(
          child: SizedBox(
            width: 150,
            child: Card.filled(
                color: Colors.white,
                child: Column(
                  children: [
                    Text(date.weekday == DateTime.sunday ? "Sunday" : date.weekday == DateTime.monday ? "Monday" : date.weekday == DateTime.tuesday ? "Tuesday" : date.weekday == DateTime.wednesday ? "Wednesday" : date.weekday == DateTime.thursday ? "Thursday" : date.weekday == DateTime.friday ? "Friday" : "Saturday"),
                    Text("${date.day}${date.day % 10 == 1 ? 'st' : date.day % 10 == 2 ? 'nd' : date.day % 10 == 3 ? 'rd' : 'th'}"),
                    Text("${date.month}, ${date.year}"),
                  ],
                )),
          ),
        ),
        meal.MealIcon(context)
      ],
    );
  }
}
