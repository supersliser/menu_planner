import 'package:flutter/material.dart';
import 'package:menu_planner/UI/CreateNewMeal.dart';
import 'package:menu_planner/UI/EditAttributeWants.dart';
import 'package:menu_planner/UI/CreateNewUser.dart';
import 'package:menu_planner/UI/MealsList.dart';
import 'package:menu_planner/UI/Navbar.dart';
import 'package:menu_planner/UI/ProfilePage.dart';
import 'package:menu_planner/UI/TodaysMeal.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  Widget item(BuildContext context, String text, IconData icon, Widget link) {
    return SizedBox(
      width: 200,
      height: 200,
      child: GestureDetector(
        onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (context) => link)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card.filled(
            color: Theme.of(context).colorScheme.tertiaryContainer,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(text),
                Icon(icon, size: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget itemHolder(List<Widget> items) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (int i = 0; i < items.length; i += 2)
            Wrap(
              alignment: WrapAlignment.center,
              children: [
                items[i],
                items.length.isOdd && i == items.length - 1
                    ? Container()
                    : items[i + 1],
              ],
            )
        ]);
  }

  @override
  Widget build(BuildContext context) {
    if (Supabase.instance.client.auth.currentUser == null) {
      return CreateNewUser();
    }
    List<Widget> items = List.empty(growable: true);
    items.add(item(context, "Today's meal", Icons.fastfood, TodaysMeal()));
    items.add(item(context, "Create new meal", Icons.add, const CreateNewMeal()));
    items.add(item(context, "Add a meal to your list", Icons.list, const MealsList()));
    items.add(item(context, "Profile", Icons.account_circle, const ProfilePage()));
    items.add(item(context, "Amount of attributes per week", Icons.list_alt, EditAttributeWantsPage()));
    return Scaffold(
      appBar: AppBar(title: const Text("Home")),
      bottomNavigationBar: const Navbar(currentPageIndex: 0),
      body: SingleChildScrollView(
        child: Center(
          child: itemHolder(items),
        ),
      ),
    );
  }
}
