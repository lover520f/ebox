import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/emby_server.dart';
import '../models/playback_state.dart';
import 'constants.dart';

class StorageService {
  static late Box<EmbyServer> _serversBox;
  static late Box<PlaybackState> _progressBox;
  static late Box<dynamic> _settingsBox;
  
  static Future<void> init() async {
    await Hive.initFlutter();
    
    // 注册适配器
    Hive.registerAdapter(EmbyServerAdapter());
    Hive.registerAdapter(PlaybackStateAdapter());
    
    // 打开数据库
    _serversBox = await Hive.openBox<EmbyServer>(AppConstants.storageServersKey);
    _progressBox = await Hive.openBox<PlaybackState>(AppConstants.storagePlaybackProgressKey);
    _settingsBox = await Hive.openBox(AppConstants.storageSettingsKey);
  }
  
  // 服务器管理
  static Future<List<EmbyServer>> getServers() async {
    return _serversBox.values.toList();
  }
  
  static Future<void> saveServers(List<EmbyServer> servers) async {
    await _serversBox.clear();
    for (var server in servers) {
      await _serversBox.put(server.id, server);
    }
  }
  
  static Future<String?> getActiveServerId() async {
    return _settingsBox.get(AppConstants.storageActiveServerKey);
  }
  
  static Future<void> setActiveServerId(String serverId) async {
    await _settingsBox.put(AppConstants.storageActiveServerKey, serverId);
  }
  
  static Future<void> clearActiveServer() async {
    await _settingsBox.delete(AppConstants.storageActiveServerKey);
  }
  
  // 播放进度
  static Future<void> savePlaybackProgress(PlaybackState progress) async {
    await _progressBox.put(progress.itemId, progress);
  }
  
  static Future<PlaybackState?> getPlaybackProgress(String itemId) async {
    return _progressBox.get(itemId);
  }
  
  static Future<void> clearPlaybackProgress(String itemId) async {
    await _progressBox.delete(itemId);
  }
  
  // 通用设置
  static Future<void> setSetting(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }
  
  static Future<dynamic> getSetting(String key, {dynamic defaultValue}) async {
    return _settingsBox.get(key, defaultValue: defaultValue);
  }
  
  // 清除所有数据
  static Future<void> clearAll() async {
    await _serversBox.clear();
    await _progressBox.clear();
    await _settingsBox.clear();
  }
}
