import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:menu_planner/UI/EditAttributeWants.dart';
import 'package:menu_planner/UI/Home.dart';
import 'package:menu_planner/UI/MealsList.dart';
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

  Padding GoogleSignUpButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
          onPressed: () async {
            if (Platform.isAndroid || Platform.isIOS) {
            } else {
              Supabase.instance.client.auth.signInWithOAuth(
                OAuthProvider.google,
                redirectTo: 'supersliser.MenuPlanner://Home',
              );

              var temp = UserData(
                  Name: nameController.text,
                  Attributes: await AttributeWant.getDefault());
              await temp.pushToDatabase(
                  emailController.text, passwordController.text);
            }
          },
          child: const Text("Sign up with Google")),
    );
  }

  Padding GoogleSignInButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
          onPressed: () async {
            if (Platform.isAndroid || Platform.isIOS) {
              /// TODO: update the Web client ID with your own.
              ///
              /// Web Client ID that you registered with Google Cloud.
              const webClientId =
                  '552964403441-hvv45322bfsjp4vlohh7vqtq3hvj2ql9.apps.googleusercontent.com';

              /// TODO: update the iOS client ID with your own.
              ///
              /// iOS Client ID that you registered with Google Cloud.
              const androidClientId =
                  '552964403441-il9228059n20q0q4gk5r0rqkbapj1nnn.apps.googleusercontent.com';

              final GoogleSignIn googleSignIn = GoogleSignIn(
                clientId: androidClientId,
                serverClientId: webClientId,
              );
              final googleUser = await googleSignIn.signIn();
              if (googleUser == null) {
                return;
              }
              final googleAuth = await googleUser.authentication;
              final accessToken = googleAuth.accessToken;
              final idToken = googleAuth.idToken;

              if (accessToken == null) {
                throw 'No Access Token found.';
              }
              if (idToken == null) {
                throw 'No ID Token found.';
              }

              await Supabase.instance.client.auth.signInWithIdToken(
                provider: OAuthProvider.google,
                idToken: idToken,
                accessToken: accessToken,
              );

              var temp = UserData(
                  Name: nameController.text,
                  Attributes: await AttributeWant.getDefault());
              await temp.pushToDatabase(
                  emailController.text, passwordController.text);
            } else {
              await Supabase.instance.client.auth.signInWithOAuth(
                OAuthProvider.google,
                redirectTo: 'com.supersliser.menu_planner://SignInCallback',
              );
            }
          },
          child: const Text("Sign in with Google")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DefaultTabController(
          length: 2,
          child: Scaffold(
              appBar: const TabBar(
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
                            onSubmitted: (_) => createUser(),
                            decoration: InputDecoration(
                                labelText: "Username",
                                errorText:
                                    usernameError ? "Invalid Username" : null)),
                        TextField(
                            controller: emailController,
                            onSubmitted: (_) => createUser(),
                            decoration: InputDecoration(
                                labelText: "Email",
                                errorText:
                                    emailError ? "Invalid Email" : null)),
                        TextField(
                            controller: passwordController,
                            onSubmitted: (_) => createUser(),
                            obscureText: true,
                            decoration: InputDecoration(
                                labelText: "Password",
                                errorText:
                                    passwordError ? "Invalid Password" : null)),
                        GoogleSignInButton(),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                              onPressed: createUser,
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
                                errorText:
                                    emailError ? "Invalid Email" : null)),
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
              ))),
    );
  }

  Future<void> submitAnon() async {
    await Supabase.instance.client.auth
        .signInWithPassword(password: "anonpassword", email: "anon@gmail.com");
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const Home()));
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

    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const Home()));
  }

  Future<void> createUser() async {
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
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const SetupAttributeWantsPage()));
  }
}

class SetupAttributeWantsPage extends StatelessWidget {
  const SetupAttributeWantsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Amount of attributes per week")),
        body: const EditAttributeWants(),
        floatingActionButton: FloatingActionButton(child: Text("Done"), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MealsList())),),);
  }
}
