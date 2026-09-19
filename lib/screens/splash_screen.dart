import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'welcome_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _controller;

  // Staggered Animations
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<Offset> _titleSlide;
  late Animation<double> _titleFade;
  late Animation<double> _taglineFade;

  final double _logoSize = 160.0;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    // Register lifecycle observer to listen for app background/foreground events
    WidgetsBinding.instance.addObserver(this);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    // 1. Logo Animation (0.0 - 0.6)
    _logoScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    // 2. Title Animation (0.4 - 0.8)
    _titleSlide = Tween<Offset>(
      begin: const Offset(0.0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.8, curve: Curves.easeOutCubic),
      ),
    );
    _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.7, curve: Curves.easeIn),
      ),
    );

    // 3. Tagline Animation (0.6 - 1.0)
    _taglineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
      ),
    );

    _startAnimationAndNavigate();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Re-play animation and reset timer whenever the user re-opens/resumes the app
    if (state == AppLifecycleState.resumed) {
      _startAnimationAndNavigate();
    }
  }

  void _startAnimationAndNavigate() {
    // Reset controller to start frame and play forward
    _controller.reset();
    _controller.forward();

    // Cancel existing timer if any
    _navigationTimer?.cancel();

    // Auto-navigate after animation completes based on auth/login preferences
    _navigationTimer = Timer(const Duration(milliseconds: 3800), () async {
      if (mounted) {
        final prefs = await SharedPreferences.getInstance();
        final bool isLoggedIn = prefs.getBool('is_logged_in') ?? false;
        final currentUser = FirebaseAuth.instance.currentUser;

        Widget targetScreen = (isLoggedIn && currentUser != null)
            ? const HomeScreen()
            : const WelcomeScreen();

        if (mounted) {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => targetScreen,
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              transitionDuration: const Duration(milliseconds: 600),
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _navigationTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 3),

              // Animated Direct Logo Image
              FadeTransition(
                opacity: _logoFade,
                child: ScaleTransition(
                  scale: _logoScale,
                  child: Image.asset(
                    'assets/images/kshetraiq_logo.png',
                    width: _logoSize,
                    height: _logoSize,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.eco_rounded,
                        size: _logoSize,
                        color: const Color(0xFF1E3F20),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Animated App Title
              FadeTransition(
                opacity: _titleFade,
                child: SlideTransition(
                  position: _titleSlide,
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                      children: [
                        TextSpan(
                          text: 'Kshetra',
                          style: TextStyle(color: Color(0xFF1E3F20)),
                        ),
                        TextSpan(
                          text: 'IQ',
                          style: TextStyle(color: Color(0xFF4A2C1B)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Animated Tagline
              FadeTransition(
                opacity: _taglineFade,
                child: const Text(
                  'Agricultural Intelligence, Simplified',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4A2C1B),
                    letterSpacing: 0.5,
                  ),
                ),
              ),

              const Spacer(flex: 2),

              // Dotted Loading Indicator
              const DottedLoadingIndicator(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class DottedLoadingIndicator extends StatefulWidget {
  const DottedLoadingIndicator({super.key});

  @override
  State<DottedLoadingIndicator> createState() => _DottedLoadingIndicatorState();
}

class _DottedLoadingIndicatorState extends State<DottedLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            double opacity =
            ((_controller.value * 3 - index) % 3).clamp(0.2, 1.0);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1E3F20).withOpacity(opacity),
              ),
            );
          }),
        );
      },
    );
  }
}