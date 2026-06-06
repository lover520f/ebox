import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../config/flavors/app_flavor.dart';
import '../config/theme.dart';
import '../config/routes.dart';
import '../providers/server_provider.dart';
import '../providers/media_provider.dart';
import '../providers/player_provider.dart';
import '../services/video_player_service.dart';
import '../services/emby_api_client.dart';
import '../services/tv_remote_service.dart';
import '../widgets/tv_navigation_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  FlavorConfig.init(flavorAndroidTV);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
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
        title: flavorAndroidTV.title,
        theme: AppTheme.darkTheme,
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          return TVFocusScope(child: child!);
        },
      ),
    );
  }
}

class TVFocusScope extends StatefulWidget {
  final Widget child;
  
  const TVFocusScope({Key? key, required this.child}) : super(key: key);

  @override
  State<TVFocusScope> createState() => _TVFocusScopeState();
}

class _TVFocusScopeState extends State<TVFocusScope> {
  late TvRemoteService _remoteService;

  @override
  void initState() {
    super.initState();
    _remoteService = TvRemoteService();
    _remoteService.initialize();
  }

  @override
  void dispose() {
    _remoteService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
