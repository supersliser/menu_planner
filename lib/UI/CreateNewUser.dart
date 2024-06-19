import 'package:flutter/material.dart';
import 'package:menu_planner/UI/TodaysMeal.dart';
import 'package:menu_planner/User.dart';

class CreateNewUser extends StatefulWidget {
  const CreateNewUser({super.key});

  @override
  State<CreateNewUser> createState() => _CreateNewUserState();
}

class _CreateNewUserState extends State<CreateNewUser> {
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var nameController = TextEditingController();

  bool usernameError = false;
  bool emailError = false;
  bool passwordError = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: SizedBox(
        width: 300,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text("Create New User"),
            TextField(
                controller: nameController,
                onSubmitted: (_) => submit(),
                decoration: InputDecoration(
                    labelText: "Username",
                    errorText: usernameError ? "Invalid Username" : null)),
            TextField(
                controller: emailController,
                onSubmitted: (_) => submit(),
                decoration: InputDecoration(
                    labelText: "Email",
                    errorText: emailError ? "Invalid Email" : null)),
            TextField(
                controller: passwordController,
                obscureText: true,
                onSubmitted: (_) => submit(),
                decoration: InputDecoration(
                    labelText: "Password",
                    errorText: passwordError ? "Invalid Password" : null)),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                  onPressed: submit, child: const Text("Create User")),
            ),
          ],
        ),
      )),
    );
  }

  Future<void> submit() async {
    if (nameController.text == "") {
      setState(() {
        usernameError = true;
      });
      return;
    }
    if (emailController.text == "") {
      setState(() {
        emailError = true;
      });
      return;
    }
    if (passwordController.text == "") {
      setState(() {
        passwordError = true;
      });
      return;
    }

    var temp = UserData(
        Name: nameController.text,
        Attributes: await AttributeWant.getDefault());
    await temp.pushToDatabase(emailController.text, passwordController.text);
    Navigator.push(context, MaterialPageRoute(builder: (context) => TodaysMeal()));
  }
}
