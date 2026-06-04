import 'package:flutter/foundation.dart';
import '../models/media_library.dart';
import '../models/media_item.dart';
import '../services/emby_api_service.dart';
import '../providers/server_provider.dart';

class MediaProvider extends ChangeNotifier {
  List<MediaLibrary> _libraries = [];
  Map<String, List<MediaItem>> _itemsByLibrary = {};
  bool _isLoading = false;
  String? _error;
  EmbyApiClient? _apiClient;

  List<MediaLibrary> get libraries => _libraries;
  Map<String, List<MediaItem>> get itemsByLibrary => _itemsByLibrary;
  bool get isLoading => _isLoading;
  String? get error => _error;
  EmbyApiClient? get apiClient => _apiClient;

  MediaProvider();

  // 加载媒体库列表
  Future<void> loadLibraries() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final serverProvider = ServerProvider();
      _apiClient = serverProvider.apiClient;
      
      if (!serverProvider.isAuthenticated) {
        _error = '未连接到服务器';
        _isLoading = false;
        notifyListeners();
        return;
      }

      _libraries = await _apiClient!.getLibraries();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = '加载媒体库失败：$e';
      notifyListeners();
    }
  }

  // 加载指定媒体库的项目
  Future<void> loadItems(String libraryId) async {
    try {
      _isLoading = true;
      _error = null;

      final serverProvider = ServerProvider();
      final apiClient = serverProvider.apiClient;
      
      if (!serverProvider.isAuthenticated) {
        _error = '未连接到服务器';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final items = await apiClient.getItems(parentId: libraryId);
      _itemsByLibrary[libraryId] = items;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = '加载媒体项失败：$e';
      notifyListeners();
    }
  }

  // 搜索媒体
  Future<List<MediaItem>> search(String query) async {
    try {
      final serverProvider = ServerProvider();
      final apiClient = serverProvider.apiClient;
      
      if (!serverProvider.isAuthenticated) {
        throw Exception('未连接到服务器');
      }

      return await apiClient.search(query);
    } catch (e) {
      _error = '搜索失败：$e';
      notifyListeners();
      rethrow;
    }
  }

  // 清除错误
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
