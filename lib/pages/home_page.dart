import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:healthmate/components/my_drawer.dart';
import 'package:healthmate/components/my_list_tile.dart';
import 'package:healthmate/components/my_posts_button.dart';
import 'package:healthmate/components/my_textfield.dart';
import 'package:healthmate/database/firestore.dart';


class HomePage extends StatelessWidget {
  HomePage({super.key});
  // firestore access
  final FirestoreDatabase firestore = FirestoreDatabase();

  final TextEditingController postController = TextEditingController();
  // post message
  void postMessage() {
    // post only if the textfield is not empty
    if (postController.text.isNotEmpty) {
      String message = postController.text;
      firestore.addPost(message);
    }
    // clear the controller
    postController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        title: const Text('W A L L'),
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
        elevation: 0,
        // actions: [
        //   // log out button
        //   IconButton(
        //     onPressed: logOut,
        //     icon: const Icon(Icons.logout),
        //   )
        // ],
      ),
      drawer: MyDrawer(),
      body: Column(
        children: [
          // textfield for the user to type a post
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: Row(
              children: [
                // textfield
                Expanded(
                  child: MyTextField(
                      hintText: 'Say something...',
                      obscureText: false,
                      controller: postController),
                ),
                // post button
                PostButton(onTap: postMessage),
              ],
            ),
          ),
          // post list
          StreamBuilder(
              stream: firestore.getPostStream(),
              builder: (context, snapshot) {
                // show loading circle
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                // get all the posts
                final posts = snapshot.data!.docs;
                // no data?
                if (snapshot.data == null || posts.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(25.0),
                      child: Text('No posts... Post something!'),
                    ),
                  );
                }
                // return as a list
                return Expanded(
                  child: ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      // get individual post
                      final post = posts[index];
                      // get data from each post
                      String message = post['postMessage'];
                      String userEmail = post['userEmail'];
                      Timestamp timestamp = post['Timestamp'];
                      // return as a ListTile
                      return MyListTile(title: message, subtitle: userEmail);
                    },
                  ),
                );
              })
        ],
      ),
    );
  }
}
