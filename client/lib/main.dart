import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app.dart';
import 'providers/server_provider.dart';
import 'providers/media_provider.dart';
import 'providers/player_provider.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await StorageService.init();
  
  runApp(const EBoxApp());
}
