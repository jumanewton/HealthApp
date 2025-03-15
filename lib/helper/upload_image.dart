// import 'package:firebase_storage/firebase_storage.dart';

// Future<String?> uploadImage(File imageFile) async {
//   try {
//     String fileName = "profile_pictures/${DateTime.now().millisecondsSinceEpoch}.jpg";
//     Reference ref = FirebaseStorage.instance.ref().child(fileName);
//     UploadTask uploadTask = ref.putFile(imageFile);

//     TaskSnapshot snapshot = await uploadTask;
//     String downloadUrl = await snapshot.ref.getDownloadURL();
//     return downloadUrl; // Save this URL in Firestore or Realtime Database
//   } catch (e) {
//     print("Error uploading image: $e");
//     return null;
//   }
// }
