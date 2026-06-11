import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}
class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) context.go('/login');
    });
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6C5CE7), Color(0xFF00CEC9)],
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.movie_outlined, size: 100, color: Colors.white),
            SizedBox(height: 32),
            Text('E 宝盒', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white)),
            SizedBox(height: 16),
            Text('ebox', style: TextStyle(fontSize: 24, color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}
