import 'package:flutter/material.dart';
import 'package:menu_planner/UI/Home.dart';
import 'package:menu_planner/User.dart';

class SignInCallback extends StatelessWidget {
  const SignInCallback({super.key});

  Future<void> finishSignIn() async {
    var temp = UserData(Name: "", Attributes: await AttributeWant.getDefault());
    await temp.pushToDatabase("", "");
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: finishSignIn(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return Column(
            children: [
              Center(
                child: Text("Sign in complete"),
              ),
              TextButton(
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const Home())),
                  child: Text("Go to app")),
            ],
          );
        });
  }
}
