import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/theme.dart';
import 'config/routes.dart';
import 'providers/server_provider.dart';
import 'providers/media_provider.dart';
import 'providers/player_provider.dart';
import 'services/video_player_service.dart';
import 'services/emby_api_client.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const EBoxApp());
}

class EBoxApp extends StatelessWidget {
  const EBoxApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ServerProvider()),
        ChangeNotifierProvider(create: (_) => MediaProvider()),
        ChangeNotifierProvider(create: (_) => PlayerProvider()),
        Provider(create: (_) => VideoPlayerService()),
        Provider(create: (_) => EmbyApiClient(baseUrl: '', apiKey: '')),
      ],
      child: MaterialApp.router(
        title: 'E 宝盒',
        theme: AppTheme.darkTheme,
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
