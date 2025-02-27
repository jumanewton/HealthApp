import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:healthmate/components/my_drawer.dart';
import 'package:healthmate/pages/medication_page.dart';
import 'package:healthmate/pages/calendar_page.dart';
import 'package:healthmate/pages/chat_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // Default to Home Page
  String username = "Newton"; // Replace with dynamic user fetching if needed

  // Function to determine the greeting based on system time
  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return "Good Morning, $username";
    } else if (hour < 18) {
      return "Good Afternoon, $username";
    } else {
      return "Good Evening, $username";
    }
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const HomePage()));
        break;
      case 1:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const MedicationPage()));
        break;
      case 2:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const MyCalendar()));
        break;
      case 3:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const ChatPage()));
        break;
    }
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
      ),
      drawer: const MyDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            getGreeting(), // Display dynamic greeting
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            "Here are some health tips for you today:",
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              leading: const Icon(Icons.health_and_safety, color: Colors.blue),
              title: const Text('5 Tips for a Healthy Lifestyle'),
              subtitle: const Text('Stay hydrated, eat well, and get enough sleep.'),
            ),
          ),
          Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              leading: const Icon(Icons.vaccines, color: Colors.green),
              title: const Text('Flu Season Alert!'),
              subtitle: const Text('Don’t forget to get your flu shot this year.'),
            ),
          ),
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
        onTap: _onItemTapped,
      ),
    );
  }
}
