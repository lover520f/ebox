import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'providers/server_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() => runApp(const EBoxApp());

class EBoxApp extends StatelessWidget {
  const EBoxApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => ServerProvider())],
      child: MaterialApp.router(
        title: 'E 宝盒',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        ),
        routerConfig: GoRouter(
          initialLocation: '/splash',
          routes: [
            GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
            GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
            GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
          ],
        ),
      ),
    );
  }
}
