import 'package:flutter/material.dart';
import 'package:menu_planner/UI/CreateNewMeal.dart';
import 'package:menu_planner/UI/EditAttributeWants.dart';
import 'package:menu_planner/UI/Home.dart';
import 'package:menu_planner/UI/MealsList.dart';
import 'package:menu_planner/UI/ProfilePage.dart';
import 'package:menu_planner/UI/TodaysMeal.dart';

class Navbar extends StatelessWidget {
  const Navbar({super.key, required this.currentPageIndex});

  final int currentPageIndex;

  @override
  Widget build(BuildContext context) {
    int barRequirement = 700;
    return LayoutBuilder(
      builder: (context, constraints) {return NavigationBar(
        destinations: [
          NavigationDestination(icon: Icon(Icons.home), label: constraints.maxWidth < barRequirement ? "" : "Home"),
          NavigationDestination(
              icon: Icon(Icons.fastfood), label: constraints.maxWidth < barRequirement ? "" : "Today's meal"),
          NavigationDestination(icon: Icon(Icons.add), label: constraints.maxWidth < barRequirement ? "" : "Create new meal"),
          NavigationDestination(
              icon: Icon(Icons.list), label: constraints.maxWidth < barRequirement ? "" : "Add a meal to your list"),
              NavigationDestination(icon: Icon(Icons.list_alt), label: constraints.maxWidth < barRequirement ? "" : "Amount of attributes per week"),
              NavigationDestination(icon: Icon(Icons.account_circle), label: constraints.maxWidth < barRequirement ? "" : "Profile"),
        ],
        selectedIndex: currentPageIndex,
        onDestinationSelected: (value) {
          switch (value) {
            case 0:
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home()));
              break;
            case 1:
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => TodaysMeal()));
              break;
            case 2:
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const CreateNewMeal()));
              break;
            case 3: Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MealsList()));
            case 4: Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const EditAttributeWantsPage()));
            case 5: Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ProfilePage()));
          }
        },
      );}
    );
  }
}
