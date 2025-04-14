// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart'; // For Firestore

// class MultiStepForm extends StatefulWidget {
//   final String userId;

//   const MultiStepForm({super.key, required this.userId});

//   @override
//   _MultiStepFormState createState() => _MultiStepFormState();
// }

// class _MultiStepFormState extends State<MultiStepForm> {
//   int _currentStep = 0;
//   final PageController _pageController = PageController();

//   // Form Data
//   String _name = '';
//   int _age = 0;
//   String _gender = '';
//   String _medication = '';
//   String _emergencyContact = '';
//   String _healthRecords = '';

//   // Form Key for validation
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Complete Your Profile"),
//       ),
//       body: Form(
//         key: _formKey,
//         child: PageView(
//           controller: _pageController,
//           physics: const NeverScrollableScrollPhysics(), // Disable swipe
//           children: [
//             // Step 1: Personal Details
//             _buildPersonalDetailsStep(),

//             // Step 2: Medication Details
//             _buildMedicationDetailsStep(),

//             // Step 3: Emergency Contact
//             _buildEmergencyContactStep(),

//             // Step 4: Health Records
//             _buildHealthRecordsStep(),
//           ],
//         ),
//       ),
//       bottomNavigationBar: BottomAppBar(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               if (_currentStep > 0)
//                 ElevatedButton(
//                   onPressed: () {
//                     _pageController.previousPage(
//                       duration: const Duration(milliseconds: 300),
//                       curve: Curves.easeIn,
//                     );
//                     setState(() {
//                       _currentStep--;
//                     });
//                   },
//                   child: const Text("Back"),
//                 ),
//               ElevatedButton(
//                 onPressed: () {
//                   if (_currentStep < 3) {
//                     if (_formKey.currentState!.validate()) {
//                       _pageController.nextPage(
//                         duration: const Duration(milliseconds: 300),
//                         curve: Curves.easeIn,
//                       );
//                       setState(() {
//                         _currentStep++;
//                       });
//                     }
//                   } else {
//                     if (_formKey.currentState!.validate()) {
//                       _submitForm();
//                     }
//                   }
//                 },
//                 child: Text(_currentStep == 3 ? "Submit" : "Next"),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // Step 1: Personal Details
//   Widget _buildPersonalDetailsStep() {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         children: [
//           TextFormField(
//             decoration: const InputDecoration(labelText: "Name"),
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return "Please enter your name";
//               }
//               return null;
//             },
//             onChanged: (value) {
//               setState(() {
//                 _name = value;
//               });
//             },
//           ),
//           TextFormField(
//             decoration: const InputDecoration(labelText: "Age"),
//             keyboardType: TextInputType.number,
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return "Please enter your age";
//               }
//               if (int.tryParse(value) == null) {
//                 return "Please enter a valid age";
//               }
//               return null;
//             },
//             onChanged: (value) {
//               setState(() {
//                 _age = int.tryParse(value) ?? 0;
//               });
//             },
//           ),
//           DropdownButtonFormField<String>(
//             decoration: const InputDecoration(labelText: "Gender"),
//             items: ["Male", "Female", "Other"].map((String value) {
//               return DropdownMenuItem<String>(
//                 value: value,
//                 child: Text(value),
//               );
//             }).toList(),
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return "Please select your gender";
//               }
//               return null;
//             },
//             onChanged: (value) {
//               setState(() {
//                 _gender = value ?? '';
//               });
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   // Step 2: Medication Details
//   Widget _buildMedicationDetailsStep() {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         children: [
//           TextFormField(
//             decoration: const InputDecoration(labelText: "Medication"),
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return "Please enter your medication";
//               }
//               return null;
//             },
//             onChanged: (value) {
//               setState(() {
//                 _medication = value;
//               });
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   // Step 3: Emergency Contact
//   Widget _buildEmergencyContactStep() {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         children: [
//           TextFormField(
//             decoration: const InputDecoration(labelText: "Emergency Contact"),
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return "Please enter an emergency contact";
//               }
//               return null;
//             },
//             onChanged: (value) {
//               setState(() {
//                 _emergencyContact = value;
//               });
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   // Step 4: Health Records
//   Widget _buildHealthRecordsStep() {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         children: [
//           TextFormField(
//             decoration: const InputDecoration(labelText: "Health Records"),
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return "Please enter your health records";
//               }
//               return null;
//             },
//             onChanged: (value) {
//               setState(() {
//                 _healthRecords = value;
//               });
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   // Submit Form to Firestore
//   void _submitForm() async {
//     if (_formKey.currentState!.validate()) {
//       final userData = {
//         'name': _name,
//         'age': _age,
//         'gender': _gender,
//         'medication': _medication,
//         'emergencyContact': _emergencyContact,
//         'healthRecords': _healthRecords,
//         'updatedAt': FieldValue.serverTimestamp(), // Add a timestamp
//       };

//       try {
//         // Update the existing user document
//         await FirebaseFirestore.instance
//             .collection('users')
//             .doc(widget.userId)
//             .update(userData);

//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Profile updated successfully!")),
//         );

//         // Redirect to home page
//         Navigator.pushReplacementNamed(context, '/home_page');
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Error: $e")),
//         );
//       }
//     }
//   }
// }