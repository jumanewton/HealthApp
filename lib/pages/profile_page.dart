import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:healthmate/components/my_back_button.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});
  // current logged in user
  final User? currentUser = FirebaseAuth.instance.currentUser;

  // future to fetch the user data
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDetails() async {
    // get the user document
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.email)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Profile'),
      //   backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      //   elevation: 0,
      //   centerTitle: true,
      // ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: getUserDetails(),
        builder: (context, snapshot) {
          // loading circle
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          // error
          else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          // data
          else if (snapshot.hasData) {
            // user data
            Map<String, dynamic> user = snapshot.data!.data()!;
            return Center(
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 50.0, left: 25),
                    child: Row(
                      children: [
                        MyBackButton(),
                      ],
                    ),
                  ),
                  SizedBox(height: 25),
                  // profile picture
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.all(25),
                    child: const Icon(
                      Icons.person,
                      size: 64,
                      // color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 25),
                  // user email
                  Text(
                    user['email'],
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600]),
                  ),
                  SizedBox(height: 10),
                  // user username
                  Text(
                    user['username'],
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  // ListTile(
                  //   leading: const Icon(Icons.email),
                  //   title: Text(user['email']),
                  // ),
                  // // user username
                  // ListTile(
                  //   leading: const Icon(Icons.person),
                  //   title: Text(user['username']),
                  // ),
                ],
              ),
            );
          } else {
            return Text('No data');
          }
        },
      ),
    );
  }
}
