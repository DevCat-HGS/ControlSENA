import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Control de Acceso SENA',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Montserrat',
      ),
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  String _displayText = '';
  final String _fullText = 'Seguridad SENA';
  late AnimationController _controller;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _startTypingAnimation();
  }

  void _startTypingAnimation() {
    Future.delayed(const Duration(milliseconds: 500), () {
      _typeNextCharacter();
    });
  }

  void _typeNextCharacter() {
    if (_currentIndex < _fullText.length) {
      setState(() {
        _displayText = _fullText.substring(0, _currentIndex + 1);
        _currentIndex++;
      });
      Future.delayed(const Duration(milliseconds: 200), _typeNextCharacter);
    } else {
      // When animation completes, navigate to login screen after a short delay
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Logo positioned at center (0,0)
                Image.asset(
                  'lib/img/logo.png',
                  height: 150,
                  width: 150,
                ),
                // Text positioned below the logo
                Positioned(
                  top: 200, // Maximum offset to create significant space between logo and text
                  child: Text(
                    _displayText,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                      fontFamily: 'Montserrat',
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Keep the loading indicator at the bottom
          const Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            ),
          ),
          ],
        ),
      );
  }
}
