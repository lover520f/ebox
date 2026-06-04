import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import '../utils/constants.dart';
import '../models/user.dart';
import '../models/media_library.dart';
import '../models/media_item.dart';

// 添加 Dio 导入
final _testDio = Dio();

class EmbyApiClient {
  final Dio _dio;
  String? _accessToken;
  String? _userId;
  String? _serverUrl;
  
  static final _uuid = const Uuid();
  static String? _deviceId;
  
  static String get deviceId {
    _deviceId ??= _uuid.v4();
    return _deviceId!;
  }
  
  EmbyApiClient() : _dio = Dio() {
    _dio.options.connectTimeout = AppConstants.connectionTimeout;
    _dio.options.receiveTimeout = AppConstants.receiveTimeout;
  }
  
  // 构建认证头
  String _buildAuthHeader({String? token}) {
    final tokenPart = token != null ? ', Token="$token"' : '';
    return 'MediaBrowser Client="${AppConstants.embyClient}", Device="${AppConstants.deviceName}", Version="${AppConstants.embyVersion}", DeviceId="${deviceId}"$tokenPart';
  }
  
  // 添加认证头到请求
  void _addAuthHeaders(Map<String, String> headers) {
    headers['X-Emby-Authorization'] = _buildAuthHeader(token: _accessToken);
    if (_accessToken != null) {
      headers['Authorization'] = 'MediaBrowser Token="$_accessToken"';
    }
  }
  
  // 认证用户
  Future<User> authenticate(String serverUrl, String username, String password) async {
    _serverUrl = serverUrl;
    
    try {
      final response = await _dio.post(
        '$serverUrl/Users/AuthenticateByName',
        data: jsonEncode({
          'Username': username,
          'Pw': password,
        }),
        options: Options(
          headers: {
            'X-Emby-Authorization': _buildAuthHeader(),
          },
        ),
      );
      
      _accessToken = response.data['AccessToken'] as String;
      _userId = response.data['User']['Id'] as String;
      
      return User.fromJson(response.data['User']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('用户名或密码错误');
      } else if (e.type == DioExceptionType.connectionTimeout ||
                 e.type == DioExceptionType.receiveTimeout) {
        throw Exception('服务器连接超时');
      } else {
        throw Exception('认证失败：${e.message}');
      }
    }
  }
  
  // 获取媒体库列表
  Future<List<MediaLibrary>> getLibraries() async {
    if (_serverUrl == null || _userId == null) {
      throw Exception('未连接到服务器');
    }
    
    try {
      final headers = <String, String>{};
      _addAuthHeaders(headers);
      
      final response = await _dio.get(
        '$_serverUrl/Users/$_userId/Views',
        options: Options(headers: headers),
      );
      
      final items = response.data['Items'] as List;
      return items.map((item) => MediaLibrary.fromJson(item)).toList();
    } on DioException catch (e) {
      throw Exception('获取媒体库失败：${e.message}');
    }
  }
  
  // 获取媒体项列表
  Future<List<MediaItem>> getItems({
    String? parentId,
    List<String>? includeItemTypes,
    String? sortBy,
    String? sortOrder,
    int? startIndex,
    int? limit,
    bool? isFavorite,
    bool? isPlayed,
  }) async {
    if (_serverUrl == null || _userId == null) {
      throw Exception('未连接到服务器');
    }
    
    final queryParams = <String, dynamic>{
      'userId': _userId,
      'recursive': true,
      'sortOrder': sortOrder ?? 'Ascending',
    };
    
    if (parentId != null) queryParams['parentId'] = parentId;
    if (includeItemTypes != null) queryParams['includeItemTypes'] = includeItemTypes.join(',');
    if (sortBy != null) queryParams['sortBy'] = sortBy;
    if (startIndex != null) queryParams['startIndex'] = startIndex;
    if (limit != null) queryParams['limit'] = limit;
    if (isFavorite != null) queryParams['isFavorite'] = isFavorite;
    if (isPlayed != null) queryParams['isPlayed'] = isPlayed;
    
    try {
      final headers = <String, String>{};
      _addAuthHeaders(headers);
      
      final response = await _dio.get(
        '$_serverUrl/Users/$_userId/Items',
        queryParameters: queryParams,
        options: Options(headers: headers),
      );
      
      final items = response.data['Items'] as List;
      return items.map((item) => MediaItem.fromJson(item)).toList();
    } on DioException catch (e) {
      throw Exception('获取媒体项失败：${e.message}');
    }
  }
  
  // 获取媒体详情
  Future<MediaItem> getItemDetail(String itemId) async {
    if (_serverUrl == null) {
      throw Exception('未连接到服务器');
    }
    
    try {
      final headers = <String, String>{};
      _addAuthHeaders(headers);
      
      final response = await _dio.get(
        '$_serverUrl/Items/$itemId',
        options: Options(headers: headers),
      );
      
      return MediaItem.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('获取媒体详情失败：${e.message}');
    }
  }
  
  // 获取播放链接
  Future<String> getPlaybackUrl(String itemId, {String? mediaSourceId}) async {
    if (_serverUrl == null) {
      throw Exception('未连接到服务器');
    }
    
    return '$_serverUrl/Videos/$itemId/stream${mediaSourceId != null ? '?static=true&mediaSourceId=$mediaSourceId' : '?static=true'}';
  }
  
  // 获取图片 URL
  String getImageUrl(String itemId, String type, {int? width, int? height}) {
    if (_serverUrl == null) {
      return '';
    }
    
    final params = <String, String>{
      'itemId': itemId,
      'type': type,
    };
    
    if (width != null) params['width'] = width.toString();
    if (height != null) params['height'] = height.toString();
    
    final queryString = params.entries.map((e) => '${e.key}=${e.value}').join('&');
    return '$_serverUrl/Items/$itemId/Images/$type?$queryString';
  }
  
  // 搜索
  Future<List<MediaItem>> search(String query, {String? parentId, int limit = 20}) async {
    if (_serverUrl == null || _userId == null) {
      throw Exception('未连接到服务器');
    }
    
    try {
      final headers = <String, String>{};
      _addAuthHeaders(headers);
      
      final response = await _dio.get(
        '$_serverUrl/Users/$_userId/Items',
        queryParameters: {
          'searchTerm': query,
          'parentId': parentId,
          'limit': limit,
        },
        options: Options(headers: headers),
      );
      
      final items = response.data['Items'] as List;
      return items.map((item) => MediaItem.fromJson(item)).toList();
    } on DioException catch (e) {
      throw Exception('搜索失败：${e.message}');
    }
  }
  
  // 上报播放进度
  Future<void> reportPlaybackProgress(String itemId, Duration position) async {
    if (_serverUrl == null) {
      return;
    }
    
    try {
      final headers = <String, String>{};
      _addAuthHeaders(headers);
      
      await _dio.post(
        '$_serverUrl/Sessions/Playing/Progress',
        data: jsonEncode({
          'ItemId': itemId,
          'PositionTicks': position.inMicroseconds * 10,
        }),
        options: Options(headers: headers),
      );
    } catch (e) {
      // 忽略进度上报错误
    }
  }
  
  // 清空认证信息
  void clearAuth() {
    _accessToken = null;
    _userId = null;
    _serverUrl = null;
  }
  
  // 获取当前用户 ID
  String? get userId => _userId;
  
  // 获取当前服务器 URL
  String? get serverUrl => _serverUrl;
  
  // 获取访问令牌
  String? get accessToken => _accessToken;
  
  // 测试服务器连接
  Future<bool> testPublicInfo(String url) async {
    try {
      final response = await _testDio.get('$url/System/Info/Public');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
