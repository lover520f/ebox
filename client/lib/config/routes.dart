import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../pages/welcome/welcome_page.dart';
import '../pages/home/home_page.dart';
import '../pages/server/server_list_page.dart';
import '../pages/server/server_add_page.dart';
import '../pages/library/library_page.dart';
import '../pages/detail/media_detail_page.dart';
import '../pages/player/video_player_page.dart';
import '../pages/settings/settings_page.dart';
import '../pages/local/local_media_page.dart';
import 'page_transitions.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: '/',
        name: 'welcome',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const WelcomePage(),
          transitionsBuilder: SmoothPageTransitions.buildPageTransition,
          transitionDuration: const Duration(milliseconds: 280),
          reverseTransitionDuration: const Duration(milliseconds: 250),
        ),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const HomePage(),
          transitionsBuilder: SmoothPageTransitions.buildPageTransition,
          transitionDuration: const Duration(milliseconds: 280),
          reverseTransitionDuration: const Duration(milliseconds: 250),
        ),
      ),
      GoRoute(
        path: '/servers',
        name: 'servers',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const ServerListPage(),
          transitionsBuilder: SmoothPageTransitions.buildPageTransition,
          transitionDuration: const Duration(milliseconds: 280),
          reverseTransitionDuration: const Duration(milliseconds: 250),
        ),
      ),
      GoRoute(
        path: '/servers/add',
        name: 'server-add',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const ServerAddPage(),
          transitionsBuilder: SmoothPageTransitions.buildPageTransition,
          transitionDuration: const Duration(milliseconds: 280),
          reverseTransitionDuration: const Duration(milliseconds: 250),
        ),
      ),
      GoRoute(
        path: '/library/:libraryId',
        name: 'library',
        pageBuilder: (context, state) {
          final libraryId = state.pathParameters['libraryId']!;
          return CustomTransitionPage(
            child: LibraryPage(libraryId: libraryId),
            transitionsBuilder: SmoothPageTransitions.buildPageTransition,
            transitionDuration: const Duration(milliseconds: 280),
            reverseTransitionDuration: const Duration(milliseconds: 250),
          );
        },
      ),
      GoRoute(
        path: '/detail/:mediaId',
        name: 'detail',
        pageBuilder: (context, state) {
          final mediaId = state.pathParameters['mediaId']!;
          return CustomTransitionPage(
            child: MediaDetailPage(mediaId: mediaId),
            transitionsBuilder: SmoothPageTransitions.buildPageTransition,
            transitionDuration: const Duration(milliseconds: 280),
            reverseTransitionDuration: const Duration(milliseconds: 250),
          );
        },
      ),
      GoRoute(
        path: '/player',
        name: 'player',
        pageBuilder: (context, state) {
          final itemId = state.uri.queryParameters['itemId'];
          final serverId = state.uri.queryParameters['serverId'];
          return CustomTransitionPage(
            child: VideoPlayerPage(itemId: itemId!, serverId: serverId!),
            transitionsBuilder: SmoothPageTransitions.buildPageTransition,
            transitionDuration: const Duration(milliseconds: 280),
            reverseTransitionDuration: const Duration(milliseconds: 250),
          );
        },
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const SettingsPage(),
          transitionsBuilder: SmoothPageTransitions.buildPageTransition,
          transitionDuration: const Duration(milliseconds: 280),
          reverseTransitionDuration: const Duration(milliseconds: 250),
        ),
      ),
      GoRoute(
        path: '/local',
        name: 'local',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const LocalMediaPage(),
          transitionsBuilder: SmoothPageTransitions.buildPageTransition,
          transitionDuration: const Duration(milliseconds: 280),
          reverseTransitionDuration: const Duration(milliseconds: 250),
        ),
      ),
    ],
  );
}
