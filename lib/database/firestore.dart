import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/** 
 this database stores posts that users have published in the app
 It is stored in a collection called 'posts' in Firestore

 Each post has the following fields:
  - 'content': the text content of the post
  - 'email': the email of the user who published the post
  - 'timestamp': the time the post was published
 */
class FirestoreDatabase {
  // current logged in user
  final User? user = FirebaseAuth.instance.currentUser;
  // get collection of posts from firebase
  final CollectionReference posts =
      FirebaseFirestore.instance.collection('Posts');
  // post a message
  Future<void> addPost(String message) {
    // add the post to the database
    return posts.add({
      'userEmail': user!.email,
      'postMessage': message,
      'Timestamp': Timestamp.now(),
    });
  }

  // read posts from the database
  Stream<QuerySnapshot> getPostStream() {
    final postStream = FirebaseFirestore.instance
        .collection('Posts')
        .orderBy('Timestamp', descending: true)
        .snapshots();
    return postStream;
    // return posts.orderBy('Timestamp', descending: true).snapshots();
  }
}
