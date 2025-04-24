// // test/health_metrics_widget_test.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';


// void main() {
//   testWidgets('HealthMetricsCard displays correct data', (WidgetTester tester) async {
//     // Build the widget
//     await tester.pumpWidget(MaterialApp(
//       home: HealthMetricsCard(
//         title: 'Blood Pressure',
//         value: '120/80',
//         unit: 'mmHg',
//       ),
//     ));

//     // Verify text appears correctly
//     expect(find.text('Blood Pressure'), findsOneWidget);
//     expect(find.text('120/80'), findsOneWidget);
//     expect(find.text('mmHg'), findsOneWidget);
//   });
// }