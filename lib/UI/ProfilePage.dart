import 'package:flutter/material.dart';
import 'package:menu_planner/UI/Navbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({Key? key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  var usernameController = TextEditingController();

  bool saving = false;
  bool passwordChange = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Profile")),
        bottomNavigationBar: const Navbar(currentPageIndex: 4),
        body: SizedBox(
            width: 400,
            child: Card.filled(
              color: Theme.of(context).colorScheme.tertiaryContainer,
              child: Column(
                children: [
                  Text("Profile"),
                  Card.filled(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    child: TextField(
                      autocorrect: false,
                      controller: usernameController,
                      decoration: const InputDecoration(labelText: "Username"),
                    ),
                  ),
                  Card.filled(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    child: Wrap(
                      children: [SaveButton(), SignOutButton(), ChangePasswordButton(), DeleteAccountButton()],
                    ),
                  )
                ],
              ),
            )));
  }

  ElevatedButton DeleteAccountButton() {
    return ElevatedButton(
      child: const Text("Delete Account"),
      onPressed: () async {
        await Supabase.instance.client.from("Users").delete().eq("UUID", Supabase.instance.client.auth.currentUser!.id);
        await Supabase.instance.client.auth.admin.deleteUser(Supabase.instance.client.auth.currentUser!.id);
        Navigator.pop(context);
      },
    );
  }

  ElevatedButton SignOutButton() {
    return ElevatedButton(
      child: const Text("Sign Out"),
      onPressed: () async {
        await Supabase.instance.client.auth.signOut();
      },
    );
  }

  Column ChangePasswordButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ElevatedButton(
          child: const Text("Change Password"),
          onPressed: () async {
            await Supabase.instance.client.auth.resetPasswordForEmail(Supabase.instance.client.auth.currentUser!.email!);
          },
        ),
        passwordChange ? const Text("You should have just recieved an email which will change your password") : Container()
      ],
    );
  }

  ElevatedButton SaveButton() {
    return ElevatedButton(
      child: Row(children: [
        Text("Save"),
        saving ? const CircularProgressIndicator() : Container()
      ]),
      onPressed: () async {
        setState(() {
          saving = true;
        });
        await Supabase.instance.client
            .from("Users")
            .update({"Username": usernameController.text}).eq(
                "UUID", Supabase.instance.client.auth.currentUser!.id);
        setState(() {
          saving = false;
        });
      },
    );
  }
}
