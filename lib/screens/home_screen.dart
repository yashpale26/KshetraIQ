import 'package:flutter/material.dart';
import 'home_tab_screen.dart';
import 'farms_screen.dart';
import 'ai_screen.dart';
import 'planner_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeTabScreen(),
    FarmsScreen(),
    AiScreen(),
    // PlannerScreen(),
    ProfileScreen(),
  ];

  final List<String> _titles = const [
    'Kshetra Dashboard',
    'My Farms',
    'Kshetra AI',
    // 'Farm Planner',
    'Profile',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFA2E1BA),
            Color(0xFFFCF3CF),
            Color(0xFFEADBC8),
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Scaffold(
        backgroundColor: Color(0xFFA2E1BA),
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            _titles[_currentIndex],
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: const Color(0xFF1E3F20),
        ),
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeIn,
          switchOutCurve: Curves.easeOut,
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.98, end: 1.0).animate(animation),
                child: child,
              ),
            );
          },
          child: KeyedSubtree(
            key: ValueKey<int>(_currentIndex),
            child: _screens[_currentIndex],
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (int index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: const Color(0xFFF9F6F0).withOpacity(0.9),
          indicatorColor: const Color(0xFFA2E1BA),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home, color: Color(0xFF1E3F20)),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.landscape_outlined),
              selectedIcon: Icon(Icons.landscape, color: Color(0xFF1E3F20)),
              label: 'Farms',
            ),
            NavigationDestination(
              icon: Icon(Icons.psychology_outlined),
              selectedIcon: Icon(Icons.psychology, color: Color(0xFF1E3F20)),
              label: 'AI',
            ),
            // NavigationDestination(
            //   icon: Icon(Icons.calendar_month_outlined),
            //   selectedIcon: Icon(Icons.calendar_month, color: Color(0xFF1E3F20)),
            //   label: 'Planner',
            // ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person, color: Color(0xFF1E3F20)),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}