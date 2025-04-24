// // test/widget/profile_page_test.dart

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:healthmate/widgets/edit_profile.dart';
// import 'package:mockito/mockito.dart';
// import 'package:mockito/annotations.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:healthmate/widgets/edit_profile.dart';
// import 'package:mockito/mockito.dart';
// import 'package:mockito/annotations.dart';
// import 'package:healthmate/pages/profile_page.dart';
// import '../helpers/firebase_mocks.dart';

// // Define type aliases to make the code cleaner
// typedef DocumentSnapshotMap = DocumentSnapshot<Map<String, dynamic>>;
// typedef CollectionReferenceMap = CollectionReference<Map<String, dynamic>>;
// typedef DocumentReferenceMap = DocumentReference<Map<String, dynamic>>;

// @GenerateMocks([
//   FirebaseAuth, 
//   FirebaseFirestore, 
//   User, 
//   DocumentReferenceMap, 
//   CollectionReferenceMap,
//   DocumentSnapshotMap,
// ])

// import 'profile_page_test.mocks.dart';  
// void main() {
//   late MockFirebaseAuth mockFirebaseAuth;
//   late MockUser mockUser;
//   late MockFirebaseFirestore mockFirestore;
//   late MockDocumentReferenceMap mockDocRef;
//   late MockCollectionReferenceMap mockCollectionRef;
//   late MockDocumentSnapshotMap mockDocSnapshot;

//   setUp(() async {
//     // Setup Firebase mocks
//     await setupFirebaseCoreMocks();
    
//     mockFirebaseAuth = MockFirebaseAuth();
//     mockUser = MockUser();
//     mockFirestore = MockFirebaseFirestore();
//     mockDocRef = MockDocumentReferenceMap();
//     mockCollectionRef = MockCollectionReferenceMap();
//     mockDocSnapshot = MockDocumentSnapshotMap();

//     // Set up mock behavior
//     when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
//     when(mockUser.uid).thenReturn('test-user-id');
//     when(mockFirestore.collection('users')).thenReturn(mockCollectionRef);
//     when(mockCollectionRef.doc('test-user-id')).thenReturn(mockDocRef);
//     when(mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);
//   });

//   testWidgets('ProfilePage displays user health metrics correctly', (WidgetTester tester) async {
//     // Mock data to return for the user
//     final userData = {
//       'username': 'TestUser',
//       'email': 'test@example.com',
//       'fullName': 'Test User',
//       'dob': '1990-01-01',
//       'gender': 'Male',
//       'location': 'Test City',
//       'phoneNumber': '1234567890',
//       'height': '175',
//       'weight': '70',
//     };
    
//     when(mockDocSnapshot.data()).thenReturn(userData);
//     when(mockDocSnapshot.exists).thenReturn(true);

//     // Build the ProfilePage widget
//     await tester.pumpWidget(
//       MaterialApp(
//         home: ProfilePage(),
//       ),
//     );

//     // Wait for FutureBuilder to complete
//     await tester.pumpAndSettle();

//     // Verify profile information is displayed
//     expect(find.text('TestUser'), findsOneWidget);
//     expect(find.text('test@example.com'), findsOneWidget);

//     // Verify health metrics are displayed correctly
//     expect(find.text('HEIGHT'), findsOneWidget);
//     expect(find.text('175 cm'), findsOneWidget);
//     expect(find.text('WEIGHT'), findsOneWidget);
//     expect(find.text('70 kg'), findsOneWidget);
//     expect(find.text('BMI'), findsOneWidget);
//     expect(find.text('22.9'), findsOneWidget); // 70 / (1.75 * 1.75) ≈ 22.9
//   });

//   // Rest of the test code remains unchanged...
  
//   testWidgets('BMI calculation shows placeholder when data is missing', (WidgetTester tester) async {
//     // Mock data with missing height and weight
//     final userData = {
//       'username': 'TestUser',
//       'email': 'test@example.com',
//     };
    
//     when(mockDocSnapshot.data()).thenReturn(userData);
//     when(mockDocSnapshot.exists).thenReturn(true);

//     await tester.pumpWidget(
//       MaterialApp(
//         home: ProfilePage(),
//       ),
//     );

//     await tester.pumpAndSettle();

//     expect(find.text('HEIGHT'), findsOneWidget);
//     expect(find.text('-- cm'), findsOneWidget);
//     expect(find.text('WEIGHT'), findsOneWidget);
//     expect(find.text('-- kg'), findsOneWidget);
//     expect(find.text('BMI'), findsOneWidget);
//     expect(find.text('--'), findsOneWidget);
//   });

//   testWidgets('Edit profile button navigates to edit profile page', (WidgetTester tester) async {
//     final userData = {
//       'username': 'TestUser',
//       'email': 'test@example.com',
//     };
    
//     when(mockDocSnapshot.data()).thenReturn(userData);
//     when(mockDocSnapshot.exists).thenReturn(true);

//     await tester.pumpWidget(
//       MaterialApp(
//         home: ProfilePage(),
//         routes: {
//           '/edit_profile': (context) => const EditProfilePage(),
//         },
//       ),
//     );

//     await tester.pumpAndSettle();

//     final editButton = find.byIcon(Icons.edit);
//     expect(editButton, findsOneWidget);
//     await tester.tap(editButton);
//     await tester.pumpAndSettle();

//     expect(find.byType(EditProfilePage), findsOneWidget);
//   });

//   testWidgets('ProfilePage shows loading indicator when loading data', (WidgetTester tester) async {
//     when(mockDocRef.get()).thenAnswer((_) => Future.delayed(
//       const Duration(days: 1),
//       () => mockDocSnapshot,
//     ));

//     await tester.pumpWidget(
//       MaterialApp(
//         home: ProfilePage(),
//       ),
//     );

//     expect(find.byType(CircularProgressIndicator), findsOneWidget);
//   });

//   testWidgets('ProfilePage shows error message when data loading fails', (WidgetTester tester) async {
//     when(mockDocRef.get()).thenAnswer((_) => Future.error('Test error'));

//     await tester.pumpWidget(
//       MaterialApp(
//         home: ProfilePage(),
//       ),
//     );

//     await tester.pumpAndSettle();

//     expect(find.textContaining('Error loading profile'), findsOneWidget);
//   });
// }