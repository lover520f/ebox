import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../pages/home/home_page.dart';
import '../pages/server/server_list_page.dart';
import '../pages/server/server_add_page.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/servers',
      builder: (context, state) => const ServerListPage(),
    ),
    GoRoute(
      path: '/servers/add',
      builder: (context, state) => const ServerAddPage(),
    ),
  ],
);
