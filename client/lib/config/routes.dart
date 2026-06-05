import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../pages/welcome/welcome_page.dart';
import '../pages/home/home_page.dart';
import '../pages/server/server_list_page.dart';
import '../pages/server/server_add_page.dart';
import '../pages/library/library_page.dart';
import '../pages/detail/media_detail_page.dart';
import '../pages/playback/video_player_page.dart';
import '../pages/settings/settings_page.dart';
import '../pages/local/local_media_page.dart';
import '../pages/history/watch_history_page.dart';
import '../pages/search/search_page.dart';
import '../pages/series/season_episode_page.dart';
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
        name: 'add-server',
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
        pageBuilder: (context, state) => CustomTransitionPage(
          child: LibraryPage(libraryId: state.pathParameters['libraryId']!),
          transitionsBuilder: SmoothPageTransitions.buildPageTransition,
          transitionDuration: const Duration(milliseconds: 280),
          reverseTransitionDuration: const Duration(milliseconds: 250),
        ),
      ),
      GoRoute(
        path: '/season/:seriesId/:seasonId',
        name: 'season',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: SeasonEpisodePage(
            seriesId: state.pathParameters['seriesId']!,
            seasonId: state.pathParameters['seasonId']!,
            seasonName: state.uri.queryParameters['name'] ?? '季',
          ),
          transitionsBuilder: SmoothPageTransitions.buildPageTransition,
          transitionDuration: const Duration(milliseconds: 280),
          reverseTransitionDuration: const Duration(milliseconds: 250),
        ),
      ),
      GoRoute(
        path: '/detail/:itemId',
        name: 'detail',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return CustomTransitionPage(
            child: MediaDetailPage(
              itemId: state.pathParameters['itemId']!,
            ),
            transitionsBuilder: SmoothPageTransitions.buildPageTransition,
            transitionDuration: const Duration(milliseconds: 280),
            reverseTransitionDuration: const Duration(milliseconds: 250),
          );
        },
      ),
      GoRoute(
        path: '/player/:itemId',
        name: 'player',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return CustomTransitionPage(
            child: VideoPlayerPage(
              videoUrl: extra['videoUrl'] as String,
              itemId: state.pathParameters['itemId']!,
              title: extra['title'] as String? ?? '视频播放',
            ),
            transitionsBuilder: SmoothPageTransitions.buildPageTransition,
            transitionDuration: const Duration(milliseconds: 280),
            reverseTransitionDuration: const Duration(milliseconds: 250),
          );
        },
      ),
      GoRoute(
        path: '/search',
        name: 'search',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const SearchPage(),
          transitionsBuilder: SmoothPageTransitions.buildPageTransition,
          transitionDuration: const Duration(milliseconds: 280),
          reverseTransitionDuration: const Duration(milliseconds: 250),
        ),
      ),
      GoRoute(
        path: '/history',
        name: 'history',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const WatchHistoryPage(),
          transitionsBuilder: SmoothPageTransitions.buildPageTransition,
          transitionDuration: const Duration(milliseconds: 280),
          reverseTransitionDuration: const Duration(milliseconds: 250),
        ),
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
