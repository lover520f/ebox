import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../pages/home/home_page.dart';
import '../pages/server/server_list_page.dart';
import '../pages/server/server_add_page.dart';
import '../pages/library/library_page.dart';
import '../pages/media/media_detail_page.dart';
import '../pages/player/video_player_page.dart';

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
    GoRoute(
      path: '/library',
      builder: (context, state) => const LibraryPage(),
    ),
    GoRoute(
      path: '/media/:id',
      builder: (context, state) {
        final item = state.extra as Map<String, dynamic>;
        return MediaDetailPage(item: item);
      },
    ),
    GoRoute(
      path: '/player',
      builder: (context, state) {
        final args = state.extra as Map<String, dynamic>;
        return VideoPlayerPage(
          itemId: args['itemId'] as String,
          title: args['title'] as String,
        );
      },
    ),
  ],
);
