import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});
  void logOut() {
    // log out the user
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween, // Space between elements
        children: [
          // Upper section of the drawer
          Column(
            children: [
              // Drawer header
              DrawerHeader(
                child: Icon(
                  Icons.favorite,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
              const SizedBox(height: 25),

              // Home tile
              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text('H O M E'),
                  onTap: () {
                    Navigator.pop(context);
                    // navigate to the home page
                    Navigator.pushNamed(context, '/home_page');
                  },
                ),
              ),
              const SizedBox(height: 25),

              // Profile tile
              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('P R O F I L E'),
                  onTap: () {
                    Navigator.pop(context);
                    // navigate to the profile page
                    Navigator.pushNamed(context, '/profile_page');
                  },
                ),
              ),
              const SizedBox(height: 25),

              // Users tile
              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('S E T T I N G S'),
                  onTap: () {
                    Navigator.pop(context);
                    // navigate to the users page
                    Navigator.pushNamed(context, '/settings_page');
                  },
                ),
              ),
            ],
          ),

          // Logout button at the bottom
          Padding(
            padding: const EdgeInsets.only(left: 25.0, bottom: 25.0),
            child: ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('L O G  O U T'),
              onTap: () {
                Navigator.pop(context);
                // log out the user
                logOut();
              },
            ),
          ),
        ],
      ),
    );
  }
}
