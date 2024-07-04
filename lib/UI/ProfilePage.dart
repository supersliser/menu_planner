import 'package:flutter/material.dart';
import 'package:menu_planner/UI/Navbar.dart';
import 'package:menu_planner/User.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

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
        bottomNavigationBar: const Navbar(currentPageIndex: 5),
        body: Center(
          child: SizedBox(
              width: 400,
              child: Card.filled(
                color: Theme.of(context).colorScheme.tertiaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text("Profile"),
                      Card.filled(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        child: FutureBuilder(
                            future: UserData.getByID(
                                Supabase.instance.client.auth.currentUser!.id),
                            builder: (context, snapshot) {
                              usernameController.text =
                                  snapshot.data?.Name ?? "";
                              return Column(
                                children: [
                                  TextField(
                                    autocorrect: false,
                                    controller: usernameController,
                                    decoration: const InputDecoration(
                                        labelText: "Username"),
                                  ),
                                ],
                              );
                            }),
                      ),
                      Card.filled(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            children: [
                              SaveButton(),
                              SignOutButton(),
                              ChangePasswordButton(),
                              DeleteAccountButton()
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              )),
        ));
  }

  Padding DeleteAccountButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        child: const Text("Delete Account"),
        onPressed: () async {
          await Supabase.instance.client
              .from("Users")
              .delete()
              .eq("UUID", Supabase.instance.client.auth.currentUser!.id);
          await Supabase.instance.client.auth.admin
              .deleteUser(Supabase.instance.client.auth.currentUser!.id);
          Navigator.pop(context);
          setState(() {});
        },
      ),
    );
  }

  Padding SignOutButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        child: const Text("Sign Out"),
        onPressed: () async {
          await Supabase.instance.client.auth.signOut();
          Navigator.pop(context);
          setState(() {});
        },
      ),
    );
  }

  Padding ChangePasswordButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ElevatedButton(
            child: const Text("Change Password"),
            onPressed: () async {
              await Supabase.instance.client.auth.resetPasswordForEmail(
                  Supabase.instance.client.auth.currentUser!.email!);
            },
          ),
          passwordChange
              ? const Text(
                  "You should have just recieved an email which will change your password")
              : Container()
        ],
      ),
    );
  }

  Padding SaveButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: saving ? 120 : 80,
        child: ElevatedButton(
          child: Row(children: [
            const Text("Save"),
            saving
                ? const CircularProgressIndicator()
                : const Padding(
                    padding: EdgeInsets.all(0),
                  )
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
        ),
      ),
    );
  }
}
