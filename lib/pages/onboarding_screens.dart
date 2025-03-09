import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // List of onboarding pages
  final List<Widget> _pages = [
    const OnboardingPage(
      title: "Welcome to HealthMate!",
      description: "Your personal health companion for a better lifestyle.",
      imagePath: "assests/images/welcome0.png", // Add your image path
    ),
    const OnboardingPage(
      title: "Track Your Fitness",
      description: "Monitor your steps, heart rate, and activity with ease.",
      imagePath: "assests/images/track.png", // Add your image path
    ),
    const OnboardingPage(
      title: "Personalized Health Goals",
      description: "Set goals and get tailored recommendations.",
      imagePath: "assests/images/hgoals.jpg", // Add your image path
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // PageView for onboarding screens
          PageView(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            children: _pages,
          ),

          // SmoothPageIndicator
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Center(
              child: SmoothPageIndicator(
                controller: _pageController,
                count: _pages.length,
                effect: const WormEffect(
                  activeDotColor: Colors.blue,
                  dotColor: Colors.grey,
                  dotHeight: 10,
                  dotWidth: 10,
                ),
              ),
            ),
          ),

          // Next Button
          Positioned(
            bottom: 40,
            right: 20,
            child: _currentPage == _pages.length - 1
                ? ElevatedButton(
                    onPressed: () {
                      // Navigate to the main app screen
                      Navigator.pushReplacementNamed(
                          context, '/login_register_page');
                    },
                    child: const Text("Get Started"),
                  )
                : ElevatedButton(
                    onPressed: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      );
                    },
                    child: const Text("Next"),
                  ),
          ),
        ],
      ),
    );
  }
}

// Onboarding Page Widget
class OnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;

  const OnboardingPage({
    super.key,
    required this.title,
    required this.description,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(imagePath, height: 200), // Add your image
          const SizedBox(height: 40),
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            description,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
