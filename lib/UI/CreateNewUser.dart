import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:menu_planner/UI/Home.dart';
import 'package:menu_planner/UI/TodaysMeal.dart';
import 'package:menu_planner/User.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  Padding GoogleSignInButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
          onPressed: () async {
            
              await Supabase.instance.client.auth
                  .signInWithOAuth(OAuthProvider.google, redirectTo: "my-scheme://my-host/Home");
            
            // Navigator.push(
            //     context, MaterialPageRoute(builder: (context) => Home()));
          },
          child: const Text("Sign up with Google")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
            appBar: TabBar(
              tabs: [
                Tab(text: "Create New User"),
                Tab(text: "Sign In"),
              ],
            ),
            body: TabBarView(
              children: [
                Center(
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
                              errorText:
                                  usernameError ? "Invalid Username" : null)),
                      TextField(
                          controller: emailController,
                          onSubmitted: (_) => submit(),
                          decoration: InputDecoration(
                              labelText: "Email",
                              errorText: emailError ? "Invalid Email" : null)),
                      TextField(
                          controller: passwordController,
                          onSubmitted: (_) => submit(),
                          obscureText: true,
                          decoration: InputDecoration(
                              labelText: "Password",
                              errorText:
                                  passwordError ? "Invalid Password" : null)),
                      GoogleSignInButton(),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                            onPressed: submit,
                            child: const Text("Create User")),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                            onPressed: submitAnon,
                            child: const Text("Anonymous Sign In")),
                      ),
                    ],
                  ),
                )),
                Center(
                    child: SizedBox(
                  width: 300,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text("Sign In"),
                      TextField(
                          controller: emailController,
                          onSubmitted: (_) => login(),
                          decoration: InputDecoration(
                              labelText: "Email",
                              errorText: emailError ? "Invalid Email" : null)),
                      TextField(
                          controller: passwordController,
                          obscureText: true,
                          onSubmitted: (_) => login(),
                          decoration: InputDecoration(
                              labelText: "Password",
                              errorText:
                                  passwordError ? "Invalid Password" : null)),
                      GoogleSignInButton(),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                            onPressed: login, child: const Text("Sign In")),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                            onPressed: submitAnon,
                            child: const Text("Anonymous Sign In")),
                      ),
                    ],
                  ),
                )),
              ],
            )));
  }

  Future<void> submitAnon() async {
    await Supabase.instance.client.auth
        .signInWithPassword(password: "anonpassword", email: "anon@gmail.com");
    Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
  }

  Future<void> login() async {
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

    try {
      await Supabase.instance.client.auth.signInWithPassword(
          password: passwordController.text, email: emailController.text);
    } catch (e) {
      setState(() {
        emailError = true;
        passwordError = true;
      });
      return;
    }

    Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
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
    Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
  }
}
