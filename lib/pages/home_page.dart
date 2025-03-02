import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:healthmate/components/my_drawer.dart';
import 'package:healthmate/components/my_loading_indicator.dart';
import 'package:healthmate/pages/home_content.dart'; // Import the HomeContent widget
import 'package:healthmate/pages/medication_page.dart';
import 'package:healthmate/pages/calendar_page.dart';
import 'package:healthmate/pages/chat_page.dart';
import 'package:healthmate/pages/notifications_page.dart';
import 'package:healthmate/utility/firestore_utils.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String username = "Loading..."; // Default value while fetching data
  bool isLoading = true; // To track loading state
  final User? currentUser = FirebaseAuth.instance.currentUser;

  final List<Widget> _pages = [
    const HomeContent(username: "Loading..."), // Placeholder, will be updated
    const MedicationPage(),
    const CalendarPage(),
    const ChatPage(),
  ];

  @override
  void initState() {
    super.initState();
    _fetchUsername();
  }

  Future<void> _fetchUsername() async {
    if (currentUser == null) return;

    try {
      String? fetchedUsername = await FirestoreUtils.fetchUsername(currentUser!.email!);
      if (fetchedUsername != null) {
        setState(() {
          username = fetchedUsername;
          isLoading = false;
          _pages[0] = HomeContent(username: username); // Update HomeContent with fetched username
        });
      } else {
        setState(() {
          username = "User not found";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        username = "Error fetching username";
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to fetch username: $e")),
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
              children: _pages,
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