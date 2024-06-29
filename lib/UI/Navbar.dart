import 'package:flutter/material.dart';
import 'package:menu_planner/UI/CreateNewMeal.dart';
import 'package:menu_planner/UI/MealsList.dart';
import 'package:menu_planner/UI/TodaysMeal.dart';

class Navbar extends StatelessWidget {
  const Navbar({super.key, required this.currentPageIndex});

  final int currentPageIndex;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home), label: "Home"),
        NavigationDestination(
            icon: Icon(Icons.fastfood), label: "Today's meal"),
        NavigationDestination(icon: Icon(Icons.add), label: "Create new meal"),
        NavigationDestination(
            icon: Icon(Icons.list), label: "Add a meal to your list")
      ],
      selectedIndex: currentPageIndex,
      onDestinationSelected: (value) {
        switch (value) {
          case 0:
          Navigator.popUntil(context, (ModalRoute.withName('/')));
            break;
          case 1:
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => TodaysMeal()));
            break;
          case 2:
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const CreateNewMeal()));
            break;
          case 3: Navigator.push(context, MaterialPageRoute(builder: (context) => const MealsList()));
        }
      },
    );
  }
}
