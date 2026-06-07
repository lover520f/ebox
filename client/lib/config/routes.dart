import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../pages/welcome/welcome_page.dart';
import '../pages/home/home_page.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (c, s) => const WelcomePage()),
    GoRoute(path: '/home', builder: (c, s) => const HomePage()),
  ],
);
