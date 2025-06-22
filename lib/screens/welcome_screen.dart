import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tradika/providers/app_settings_provider.dart';
import 'package:tradika/screens/history_screen.dart';
import 'package:tradika/screens/settings_screen.dart';
import '../constants.dart';

class WelcomeScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const WelcomeScreen({super.key, required this.onComplete});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> onboardingPages = [
    {
      'title': 'Bienvenue sur Tradika',
      'description': 'Votre traducteur instantané entre le français et le bassa',
      'icon': '🌍',
    },
    {
      'title': 'Traductions de qualité',
      'description': 'Trois niveaux de qualité pour répondre à tous vos besoins',
      'icon': '✨',
    },
    {
      'title': 'Contribuez à améliorer',
      'description': 'Soumettez vos corrections pour améliorer les traductions',
      'icon': '🤝',
    }
  ];

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tradika'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HistoryScreen()),
            ),
            tooltip: 'Historique',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            ),
            tooltip: 'Paramètres',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              settings.currentTheme.primaryColor,
              settings.currentTheme.primaryColor.withOpacity(0.8),
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: onboardingPages.length,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemBuilder: (context, index) {
                  return OnboardingPage(
                    title: onboardingPages[index]['title']!,
                    description: onboardingPages[index]['description']!,
                    icon: onboardingPages[index]['icon']!,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.largePadding,
                vertical: AppConstants.largePadding,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      onboardingPages.length,
                          (index) => buildDot(index: index),
                    ),
                  ),
                  const SizedBox(height: AppConstants.largePadding),
                  ElevatedButton(
                    onPressed: () {
                      if (_currentPage == onboardingPages.length - 1) {
                        widget.onComplete();
                      } else {
                        _pageController.nextPage(
                          duration: AppConstants.animationDurationMedium,
                          curve: Curves.easeIn,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: settings.currentTheme.primaryColor,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
                      ),
                    ),
                    child: Text(
                      _currentPage == onboardingPages.length - 1 ? 'Commencer' : 'Continuer',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDot({required int index}) {
    return AnimatedContainer(
      duration: AppConstants.animationDurationShort,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? Colors.white : Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  final String icon;

  const OnboardingPage({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.extraLargePadding,
        vertical: AppConstants.largePadding,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Center(
              child: Text(
                icon,
                style: const TextStyle(fontSize: 60),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.extraLargePadding),
          Text(
            title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.mediumPadding),
          Text(
            description,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}