import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:healthmate/components/my_drawer.dart';
import 'package:healthmate/pages/medication_page.dart';
import 'package:healthmate/pages/calendar_page.dart';
import 'package:healthmate/pages/chat_page.dart';
import 'package:healthmate/pages/emergency_contact_page.dart'; // Add this
import 'package:healthmate/pages/symptom_checker_page.dart'; // Add this
import 'package:healthmate/pages/health_records_page.dart'; // Add this
import 'package:healthmate/pages/health_insights_page.dart'; // Add this
import 'package:healthmate/pages/notifications_page.dart'; // Add this


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String username = "Loading..."; // Default value while fetching data
  final User? currentUser = FirebaseAuth.instance.currentUser;

  final List<Widget> _pages = [
    const HomeContent(),
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
      DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(currentUser!.email)
          .get();

      if (userDoc.exists) {
        setState(() {
          username = userDoc.data()!['username']; // Update username
        });
      }
    } catch (e) {
      setState(() {
        username = "Error fetching username"; // Handle errors
      });
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
              // Navigate to Notifications Page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsPage(), // Add this page
                ),
              );
            },
          ),
        ],
      ),
      drawer: const MyDrawer(),
      body: IndexedStack(
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

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return "Good Morning";
    } else if (hour < 18) {
      return "Good Afternoon";
    } else {
      return "Good Evening";
    }
  }

  @override
  Widget build(BuildContext context) {
    final _HomePageState homePageState =
        context.findAncestorStateOfType<_HomePageState>()!;

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Welcome Message & Profile Overview
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${getGreeting()}, ${homePageState.username}!",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Last seen: 2 hours ago",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
          ],
        ),

        // Quick Access Tiles
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: [
            _buildQuickAccessTile(
              icon: Icons.medical_services,
              title: "Medication Tracker",
              subtitle: "Next: Paracetamol at 2:00 PM",
              color: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MedicationPage(),
                  ),
                );
              },
            ),
            _buildQuickAccessTile(
              icon: Icons.emergency,
              title: "Emergency Contact",
              subtitle: "Call Dr. Smith",
              color: Colors.red,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EmergencyContactPage(),
                  ),
                );
              },
            ),
            _buildQuickAccessTile(
              icon: Icons.health_and_safety,
              title: "Symptom Checker",
              subtitle: "Check your symptoms",
              color: Colors.green,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SymptomCheckerPage(),
                  ),
                );
              },
            ),
            _buildQuickAccessTile(
              icon: Icons.folder,
              title: "Health Records",
              subtitle: "Last Upload: Jan 2024",
              color: Colors.orange,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HealthRecordsPage(),
                  ),
                );
              },
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Health Insights & Reminders
        const Text(
          "Health Insights & Reminders",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Card(
          child: ListTile(
            leading: const Icon(Icons.health_and_safety, color: Colors.blue),
            title: const Text("Ongoing Treatment: Diabetes Management"),
            subtitle: const Text("Next checkup: Feb 15, 2024"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HealthInsightsPage(),
                ),
              );
            },
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.water_drop, color: Colors.blue),
            title: const Text("Hydration Reminder"),
            subtitle: const Text("Drink 8 glasses of water today!"),
          ),
        ),

        const SizedBox(height: 20),

        // Notification Center
        const Text(
          "Notifications",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Card(
          child: ListTile(
            leading: const Icon(Icons.notifications, color: Colors.red),
            title: const Text("Missed Medication"),
            subtitle: const Text("Paracetamol at 10:00 AM"),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.calendar_today, color: Colors.green),
            title: const Text("Upcoming Appointment"),
            subtitle: const Text("Dr. Smith at 3:00 PM"),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAccessTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}