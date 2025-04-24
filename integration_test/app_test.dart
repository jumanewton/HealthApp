// // integration_test/profile_test.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:integration_test/integration_test.dart';
// import 'package:healthmate/main.dart' as app;

// void main() {
//   IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
//   group('Profile page integration tests', () {
//     testWidgets('Profile page loads and displays health metrics', (WidgetTester tester) async {
//       // Start the app
//       app.main();
//       await tester.pumpAndSettle();
      
//       // First, we need to open the drawer
//       // Find the drawer menu button (hamburger icon)
//       final drawerButton = find.byIcon(Icons.menu);
//       // If there's no menu icon, you might need to look for a different way to open the drawer
//       // like find.byTooltip('Open navigation menu') or another specific finder
//       await tester.tap(drawerButton);
//       await tester.pumpAndSettle(); // Wait for drawer animation to complete
      
//       // Now that the drawer is open, find and tap the profile option
//       final profileTile = find.text('P R O F I L E');
//       expect(profileTile, findsOneWidget, reason: 'Profile option in drawer not found');
//       await tester.tap(profileTile);
//       await tester.pumpAndSettle(); // Wait for navigation to complete
      
//       // Verify profile page content appears
//       expect(find.text('My Profile'), findsOneWidget);
      
//       // Check if health stats section appears
//       expect(find.text('HEALTH STATS'), findsOneWidget);
      
//       // Verify the health metrics cards are visible
//       expect(find.text('HEIGHT'), findsOneWidget);
//       expect(find.text('WEIGHT'), findsOneWidget);
//       expect(find.text('BMI'), findsOneWidget);
      
//       // Test the edit profile functionality
//       final editButton = find.byIcon(Icons.edit);
//       expect(editButton, findsOneWidget);
//       await tester.tap(editButton);
//       await tester.pumpAndSettle();
      
//       // Verify we navigated to edit profile
//       expect(find.text('Edit Profile'), findsOneWidget);
//     });
    
//     // You could also add a test for the drawer navigation itself
//     testWidgets('Drawer opens and contains correct navigation options', (WidgetTester tester) async {
//       // Start the app
//       app.main();
//       await tester.pumpAndSettle();
      
//       // Open the drawer
//       final drawerButton = find.byIcon(Icons.menu);
//       await tester.tap(drawerButton);
//       await tester.pumpAndSettle();
      
//       // Verify drawer contents
//       expect(find.text('H O M E'), findsOneWidget);
//       expect(find.text('P R O F I L E'), findsOneWidget);
//       expect(find.text('S E T T I N G S'), findsOneWidget);
//       expect(find.text('L O G  O U T'), findsOneWidget);
      
//       // Verify drawer icons
//       expect(find.byIcon(Icons.home), findsOneWidget);
//       expect(find.byIcon(Icons.person), findsOneWidget);
//       expect(find.byIcon(Icons.settings), findsOneWidget);
//       expect(find.byIcon(Icons.logout), findsOneWidget);
//       expect(find.byIcon(Icons.favorite), findsOneWidget); // Drawer header icon
//     });
//   });
// }