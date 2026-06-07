import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/server_provider.dart';
import 'providers/media_provider.dart';
import 'pages/home/home_page.dart';

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
      ],
      child: MaterialApp(
        title: 'E 宝盒',
        theme: ThemeData.dark(useMaterial3: true),
        color: const Color(0xFF0A0A0A),
        home: const HomePage(),
      ),
    );
  }
}
