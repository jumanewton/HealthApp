import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:healthmate/components/my_drawer.dart';
import 'package:healthmate/components/my_loading_indicator.dart';
import 'package:healthmate/pages/home_content.dart'; // Import the HomeContent widget
import 'package:healthmate/pages/calendar_page.dart';
import 'package:healthmate/pages/chat_page.dart';
// import 'package:healthmate/pages/notifications_page.dart';
import 'package:healthmate/screens/medication_page.dart';
import 'package:healthmate/screens/notifications_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final ValueNotifier<String> fullNameNotifier =
      ValueNotifier<String>("Loading..."); // Use ValueNotifier for fullName
  bool isLoading = true; // To track loading state
  final User? currentUser = FirebaseAuth.instance.currentUser;

  final List<Widget> _pages = [
    // Placeholder, will be updated dynamically
    const SizedBox.shrink(),
    const MedicationsPage(),
    const CalendarPage(),
    const ChatPage(),
  ];

  @override
  void initState() {
    super.initState();
    _fetchFullName();
  }

  Future<void> _fetchFullName() async {
    if (currentUser == null) return;

    try {
      // Fetch the full name from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .get();

      if (userDoc.exists) {
        String fullName =
            userDoc['fullName'] ?? "User"; // Get fullName or default to "User"
        fullNameNotifier.value = fullName; // Update ValueNotifier
        setState(() {
          isLoading = false;
        });
      } else {
        fullNameNotifier.value =
            "User"; // Default value if fullName is not found
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      fullNameNotifier.value = "User"; // Fallback value in case of an error
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to fetch full name: $e")),
      );
    }
  }

  void _onItemTapped(int index) {
    if (index < 0 || index >= _pages.length) return;
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        title: const Text('HealthMate'),
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsPage(),
                ),
              );
            },
          ),
        ],
      ),
      drawer: const MyDrawer(),
      body: isLoading
          ? const MyLoadingIndicator()
          : IndexedStack(
              index: _selectedIndex,
              children: [
                // Use ValueListenableBuilder to dynamically update HomeContent
                ValueListenableBuilder<String>(
                  valueListenable: fullNameNotifier,
                  builder: (context, fullName, child) {
                    return HomeContent(
                        fullName: fullName); // Pass fullName to HomeContent
                  },
                ),
                ..._pages.sublist(1), // Include other pages
              ],
            ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services),
            label: 'Medication',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.secondary,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
