import 'package:flutter/foundation.dart';
import '../models/emby_server.dart';
import '../models/user.dart';
import '../services/emby_api_service.dart';
import 'storage_service.dart';

class ServerProvider extends ChangeNotifier {
  final EmbyApiClient _apiClient = EmbyApiClient();
  
  List<EmbyServer> _servers = [];
  EmbyServer? _activeServer;
  User? _currentUser;
  bool _isLoading = false;
  String? _error;
  
  List<EmbyServer> get servers => _servers;
  EmbyServer? get activeServer => _activeServer;
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null && _activeServer != null;
  EmbyApiClient get apiClient => _apiClient;
  
  ServerProvider() {
    _loadServers();
  }
  
  // 加载服务器列表
  Future<void> _loadServers() async {
    try {
      final serverConfigs = await StorageService.getServers();
      _servers = serverConfigs;
      
      if (_servers.isNotEmpty) {
        final activeServerId = await StorageService.getActiveServerId();
        if (activeServerId != null) {
          final activeServer = _servers.firstWhere(
            (s) => s.id == activeServerId,
            orElse: () => _servers.first,
          );
          _activeServer = activeServer;
        }
      }
      
      notifyListeners();
    } catch (e) {
      _error = '加载服务器配置失败：$e';
      notifyListeners();
    }
  }
  
  // 添加服务器
  Future<void> addServer(EmbyServer server) async {
    try {
      _servers.add(server);
      await StorageService.saveServers(_servers);
      notifyListeners();
    } catch (e) {
      _error = '添加服务器失败：$e';
      notifyListeners();
      rethrow;
    }
  }
  
  // 更新服务器
  Future<void> updateServer(EmbyServer server) async {
    try {
      final index = _servers.indexWhere((s) => s.id == server.id);
      if (index == -1) {
        throw Exception('服务器不存在');
      }
      
      _servers[index] = server;
      await StorageService.saveServers(_servers);
      
      if (_activeServer?.id == server.id) {
        _activeServer = server;
      }
      
      notifyListeners();
    } catch (e) {
      _error = '更新服务器失败：$e';
      notifyListeners();
      rethrow;
    }
  }
  
  // 删除服务器
  Future<void> removeServer(String serverId) async {
    try {
      _servers.removeWhere((s) => s.id == serverId);
      await StorageService.saveServers(_servers);
      
      if (_activeServer?.id == serverId) {
        _activeServer = null;
        _currentUser = null;
        _apiClient.clearAuth();
        await StorageService.clearActiveServer();
      }
      
      notifyListeners();
    } catch (e) {
      _error = '删除服务器失败：$e';
      notifyListeners();
      rethrow;
    }
  }
  
  // 连接到服务器
  Future<bool> connectToServer(String serverId, {String? username, String? password}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final server = _servers.firstWhere(
        (s) => s.id == serverId,
        orElse: () => throw Exception('服务器不存在'),
      );
      
      // 如果提供了用户名密码，进行认证
      if (username != null && password != null) {
        final user = await _apiClient.authenticate(
          server.url,
          username,
          password,
        );
        _currentUser = user;
      }
      
      _activeServer = server;
      await StorageService.setActiveServerId(serverId);
      
      _isLoading = false;
      notifyListeners();
      
      return true;
    } catch (e) {
      _isLoading = false;
      _error = '连接服务器失败：$e';
      notifyListeners();
      return false;
    }
  }
  
  // 断开连接
  Future<void> disconnect() async {
    _activeServer = null;
    _currentUser = null;
    _apiClient.clearAuth();
    await StorageService.clearActiveServer();
    notifyListeners();
  }
  
  // 测试服务器连接
  Future<bool> testConnection(String url) async {
    try {
      final response = await _apiClient.testPublicInfo(url);
      return response;
    } catch (e) {
      return false;
    }
  }
  
  // 清除错误
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
