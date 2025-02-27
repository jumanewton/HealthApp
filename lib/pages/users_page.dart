import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:healthmate/components/my_back_button.dart';
import 'package:healthmate/components/my_list_tile.dart';
import 'package:healthmate/helper/helper_functions.dart';


class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Users'),
      //   backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      //   elevation: 0,
      //   centerTitle: true,
      // ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          // Handle errors
          if (snapshot.hasError) {
            // display error message to the user
            displayError(context, "Something went wrong");
            // return const Center(
            //   child: Text(
            //     "Something went wrong",
            //     style: TextStyle(color: Colors.red),
            //   ),
            // );
          }

          // Show a loading indicator while fetching data
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Handle empty data case
          if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No users found'),
            );
          }

          // Display users
          final users = snapshot.data!.docs;
          return Column(
            children: [
              // back button
              Padding(
                padding: const EdgeInsets.only(top: 50.0, left: 25),
                child: Row(
                  children: [
                    MyBackButton(),
                  ],
                ),
              ),
              // SizedBox(height: 25),
              Expanded(
                child: ListView.builder(
                  itemCount: users.length,
                  padding: EdgeInsets.all(0),
                  itemBuilder: (context, index) {
                    final user = users[index];
                    // get the data from each user
                    String username = user['username'];
                    String email = user['email'];
                    return MyListTile(title: username, subtitle: email);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
