import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF6C5CE7), Color(0xFF00CEC9)]),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(Icons.play_arrow, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 32),
            const Text('E 宝盒', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.push('/home'),
              child: const Text('开始'),
            ),
          ],
        ),
      ),
    );
  }
}
