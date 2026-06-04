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

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
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
}
