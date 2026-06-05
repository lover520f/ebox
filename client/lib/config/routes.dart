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
    debugLogDiagnostics: false, // 关闭日志提升性能
    pageBuilder: (context, state) {
      // 应用流畅的页面过渡动画
      return CustomTransitionPage(
        key: state.pageKey,
        child: _buildPage(state),
        transitionsBuilder: SmoothPageTransitions.buildPageTransition,
        transitionDuration: const Duration(milliseconds: 280),
        reverseTransitionDuration: const Duration(milliseconds: 250),
      );
    },
    routes: [
      GoRoute(
        path: '/',
        name: 'welcome',
        builder: (context, state) => const WelcomePage(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/servers',
        name: 'servers',
        builder: (context, state) => const ServerListPage(),
      ),
      GoRoute(
        path: '/servers/add',
        name: 'server-add',
        builder: (context, state) => const ServerAddPage(),
      ),
      GoRoute(
        path: '/library/:libraryId',
        name: 'library',
        builder: (context, state) {
          final libraryId = state.pathParameters['libraryId']!;
          return LibraryPage(libraryId: libraryId);
        },
      ),
      GoRoute(
        path: '/detail/:mediaId',
        name: 'detail',
        builder: (context, state) {
          final mediaId = state.pathParameters['mediaId']!;
          return MediaDetailPage(mediaId: mediaId);
        },
      ),
      GoRoute(
        path: '/player',
        name: 'player',
        builder: (context, state) {
          final itemId = state.uri.queryParameters['itemId'];
          final serverId = state.uri.queryParameters['serverId'];
          return VideoPlayerPage(
            itemId: itemId!,
            serverId: serverId!,
          );
        },
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: '/local',
        name: 'local',
        builder: (context, state) => const LocalMediaPage(),
      ),
    ],
  );

  static Widget _buildPage(GoRouterState state) {
    final route = router.routeInformationProvider.value.uri.path;
    
    if (route == '/') return const WelcomePage();
    if (route == '/home') return const HomePage();
    if (route == '/servers') return const ServerListPage();
    if (route == '/servers/add') return const ServerAddPage();
    if (route.startsWith('/library/')) {
      final libraryId = state.pathParameters['libraryId']!;
      return LibraryPage(libraryId: libraryId);
    }
    if (route.startsWith('/detail/')) {
      final mediaId = state.pathParameters['mediaId']!;
      return MediaDetailPage(mediaId: mediaId);
    }
    if (route == '/player') {
      final itemId = state.uri.queryParameters['itemId'];
      final serverId = state.uri.queryParameters['serverId'];
      return VideoPlayerPage(itemId: itemId!, serverId: serverId!);
    }
    if (route == '/settings') return const SettingsPage();
    if (route == '/local') return const LocalMediaPage();
    
    return const WelcomePage();
  }
}
