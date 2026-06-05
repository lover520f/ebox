import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/emby_server.dart';
import '../models/user.dart';
import '../models/media_library.dart';
import '../models/media_item.dart';

/// Emby API 客户端
/// 参考：https://github.com/MediaBrowser/Emby.Theater
class EmbyApiClient {
  final Dio _dio = Dio();
  String? _baseUrl;
  String? _accessToken;
  String? _userId;
  User? _currentUser;

  String? get baseUrl => _baseUrl;
  String? get accessToken => _accessToken;
  String? get userId => _userId;
  User? get currentUser => _currentUser;
  Dio get dio => _dio;

  /// 测试服务器连接
  Future<bool> testConnection(String url) async {
    try {
      final response = await _dio.get(
        '$url/System/Info/Public',
        options: Options(
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// 获取公开服务器信息
  Future<Map<String, dynamic>> getPublicInfo(String url) async {
    try {
      final response = await _dio.get('$url/System/Info/Public');
      return response.data;
    } catch (e) {
      throw Exception('无法获取服务器信息：$e');
    }
  }

  /// 用户认证
  Future<User> authenticate(String url, String username, String password) async {
    try {
      // Emby 认证 API
      final response = await _dio.post(
        '$url/Users/AuthenticateByName',
        data: jsonEncode({
          'Username': username,
          'Pw': password,
        }),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'X-Emby-Authorization': _buildAuthHeader(),
          },
        ),
      );

      final data = response.data;
      
      _baseUrl = url;
      _accessToken = data['AccessToken'];
      _userId = data['User']['Id'];
      
      _currentUser = User(
        id: _userId!,
        name: data['User']['Name'] ?? username,
        avatar: data['User']['PrimaryImageTag'] != null
            ? '$url/Users/${_userId}/Images/Primary?tag=${data['User']['PrimaryImageTag']}'
            : null,
        policy: data['User']['Policy'] != null
            ? UserPolicy.fromJson(data['User']['Policy'])
            : null,
      );

      return _currentUser!;
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 401) {
        throw Exception('用户名或密码错误');
      }
      throw Exception('认证失败：$e');
    }
  }

  /// 构建认证 Header
  String _buildAuthHeader() {
    // Emby 客户端认证头格式
    // https://github.com/MediaBrowser/Emby.Theater
    return 'MediaBrowser Client="E 宝盒", Device="Windows", '
        'DeviceId="ebox-windows-${DateTime.now().millisecondsSinceEpoch}", '
        'Version="2.0.0"';
  }

  /// 获取认证的 Dio 实例
  Dio _getAuthDio() {
    if (_baseUrl == null || _accessToken == null) {
      throw Exception('未连接到服务器');
    }

    final authenticatedDio = Dio(BaseOptions(
      baseUrl: _baseUrl!,
      sendTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'X-Emby-Token': _accessToken!,
        'X-Emby-Authorization': _buildAuthHeader(),
      },
    ));

    return authenticatedDio;
  }

  /// 获取媒体库列表
  Future<List<MediaLibrary>> getLibraries() async {
    try {
      final dio = _getAuthDio();
      final response = await dio.get(
        '/Users/$userId/Views',
      );

      final items = response.data['Items'] as List;
      return items.map((item) => MediaLibrary.fromJson(item)).toList();
    } catch (e) {
      throw Exception('获取媒体库失败：$e');
    }
  }

  /// 获取媒体项列表
  Future<List<MediaItem>> getItems({
    required String parentId,
    int startIndex = 0,
    int limit = 100,
    String? sortBy,
    bool ascending = true,
    List<String> includeItemTypes = const ['Movie', 'Series'],
  }) async {
    try {
      final dio = _getAuthDio();
      final response = await dio.get(
        '/Users/$userId/Items',
        queryParameters: {
          'ParentId': parentId,
          'StartIndex': startIndex,
          'Limit': limit,
          'IncludeItemTypes': includeItemTypes.join(','),
          'SortBy': sortBy ?? 'SortName',
          'SortOrder': ascending ? 'Ascending' : 'Descending',
          'Fields': 'PrimaryImageAspectRatio,SortName,SyncState,MediaSourceCount,UserData,ProductionYear',
          'ImageTypeLimit': 1,
          'EnableImageTypes': 'Primary,Backdrop,Thumb',
          'Recursive': true,
        },
      );

      final items = response.data['Items'] as List;
      return items.map((item) => MediaItem.fromJson(item)).toList();
    } catch (e) {
      throw Exception('获取媒体项失败：$e');
    }
  }

  /// 获取媒体项详情
  Future<MediaItem> getItemDetail(String itemId) async {
    try {
      final dio = _getAuthDio();
      final response = await dio.get(
        '/Users/$userId/Items/$itemId',
        queryParameters: {
          'Fields': 'Genres,Studios,MediaSources,People,Suggestions,Taglines,BirthLocation,ProductionLocations,Reviews',
        },
      );

      return MediaItem.fromJson(response.data);
    } catch (e) {
      throw Exception('获取媒体详情失败：$e');
    }
  }

  /// 获取季信息 (电视剧)
  Future<List<MediaItem>> getSeasons(String seriesId) async {
    try {
      final dio = _getAuthDio();
      final response = await dio.get(
        '/Shows/$seriesId/Seasons',
        queryParameters: {
          'userId': userId,
          'Fields': 'PrimaryImageAspectRatio,SortName,UserData,ProductionYear',
        },
      );

      final items = response.data['Items'] as List;
      return items.map((item) => MediaItem.fromJson(item)).toList();
    } catch (e) {
      throw Exception('获取季信息失败：$e');
    }
  }

  /// 获取集信息
  Future<List<MediaItem>> getEpisodes(String seriesId, String seasonId) async {
    try {
      final dio = _getAuthDio();
      final response = await dio.get(
        '/Shows/$seriesId/Episodes',
        queryParameters: {
          'SeasonId': seasonId,
          'userId': userId,
          'Fields': 'PrimaryImageAspectRatio,SortName,UserData,ProductionYear',
        },
      );

      final items = response.data['Items'] as List;
      return items.map((item) => MediaItem.fromJson(item)).toList();
    } catch (e) {
      throw Exception('获取集信息失败：$e');
    }
  }

  /// 获取播放 URL
  Future<String> getPlaybackUrl(String itemId, {
    bool isDirectPlay = false,
  }) async {
    try {
      final dio = _getAuthDio();
      
      // 获取媒体源信息
      final response = await dio.get(
        '/Items/$itemId/PlaybackInfo',
        queryParameters: {
          'userId': userId,
          'StartTimeTicks': 0,
          'IsPlayback': true,
          'AutoOpenLiveStream': isDirectPlay,
          'MaxStreamingBitrate': 42000000, // 42 Mbps
        },
      );

      final mediaSources = response.data['MediaSources'] as List;
      if (mediaSources.isEmpty) {
        throw Exception('没有可用的媒体源');
      }

      final mediaSource = mediaSources.first;
      final playSessionId = response.data['PlaySessionId'];

      // 构建播放 URL
      if (isDirectPlay) {
        final directPath = mediaSource['Path'];
        if (directPath != null && directPath.isNotEmpty) {
          return directPath;
        }
      }

      // 流式播放 URL
      final serverUrl = _baseUrl;
      final staticUrl = '$serverUrl/Videos/$itemId/main.m3u8'
          '?Static=true'
          '&mediaSourceId=${mediaSource['Id']}'
          '&deviceId=ebox-${DateTime.now().millisecondsSinceEpoch}'
          '&api_key=$accessToken';

      return staticUrl;
    } catch (e) {
      throw Exception('获取播放地址失败：$e');
    }
  }

  /// 报告播放开始
  Future<void> reportPlaybackStart(String itemId) async {
    try {
      final dio = _getAuthDio();
      await dio.post(
        '/Sessions/Playing',
        data: jsonEncode({
          'ItemId': itemId,
          'PlaySessionId': DateTime.now().millisecondsSinceEpoch.toString(),
        }),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
    } catch (e) {
      // 忽略报告错误
      print('报告播放开始失败：$e');
    }
  }

  /// 报告播放进度
  Future<void> reportPlaybackProgress(String itemId, Duration position) async {
    try {
      final dio = _getAuthDio();
      await dio.post(
        '/Sessions/Playing/Progress',
        data: jsonEncode({
          'ItemId': itemId,
          'PositionTicks': position.inMilliseconds * 10000,
        }),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
    } catch (e) {
      // 忽略报告错误
      print('报告播放进度失败：$e');
    }
  }

  /// 报告播放停止
  Future<void> reportPlaybackStopped(String itemId, Duration position) async {
    try {
      final dio = _getAuthDio();
      await dio.post(
        '/Sessions/Playing/Stopped',
        data: jsonEncode({
          'ItemId': itemId,
          'PositionTicks': position.inMilliseconds * 10000,
        }),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
    } catch (e) {
      // 忽略报告错误
      print('报告播放停止失败：$e');
    }
  }

  /// 标记为已播放
  Future<void> markPlayed(String itemId) async {
    try {
      final dio = _getAuthDio();
      await dio.post('/Users/$userId/PlayedItems/$itemId');
    } catch (e) {
      print('标记已播放失败：$e');
    }
  }

  /// 取消标记已播放
  Future<void> markUnplayed(String itemId) async {
    try {
      final dio = _getAuthDio();
      await dio.delete('/Users/$userId/PlayedItems/$itemId');
    } catch (e) {
      print('取消标记失败：$e');
    }
  }

  /// 搜索媒体
  Future<List<MediaItem>> search(String query, {
    int limit = 20,
    List<String> includeItemTypes = const ['Movie', 'Series', 'Episode'],
  }) async {
    try {
      final dio = _getAuthDio();
      final response = await dio.get(
        '/Users/$userId/Items',
        queryParameters: {
          'SearchTerm': query,
          'Limit': limit,
          'IncludeItemTypes': includeItemTypes.join(','),
          'Fields': 'PrimaryImageAspectRatio,SortName,UserData,ProductionYear',
        },
      );

      final items = response.data['Items'] as List;
      return items.map((item) => MediaItem.fromJson(item)).toList();
    } catch (e) {
      throw Exception('搜索失败：$e');
    }
  }

  /// 获取最近添加的媒体
  Future<List<MediaItem>> getRecentlyAdded({
    int limit = 20,
    String? parentId,
  }) async {
    try {
      final dio = _getAuthDio();
      final response = await dio.get(
        '/Users/$userId/Items/Latest',
        queryParameters: {
          'Limit': limit,
          'Fields': 'PrimaryImageAspectRatio,SortName,UserData,ProductionYear',
          if (parentId != null) 'ParentId': parentId,
        },
      );

      final items = response.data as List;
      return items.map((item) => MediaItem.fromJson(item)).toList();
    } catch (e) {
      throw Exception('获取最近添加失败：$e');
    }
  }

  /// 获取正在播放的媒体
  Future<List<MediaItem>> getResumeItems({
    int limit = 20,
  }) async {
    try {
      final dio = _getAuthDio();
      final response = await dio.get(
        '/Users/$userId/Items/Resume',
        queryParameters: {
          'Limit': limit,
          'Recursive': true,
          'ImageTypeLimit': 1,
          'ImageTypes': 'Primary,Backdrop,Thumb',
          'EnableImageTypes': 'Primary,Backdrop,Thumb',
          'Fields': 'PrimaryImageAspectRatio,SortName,SyncState,MediaSourceCount,UserData,ProductionYear',
        },
      );

      final items = response.data['Items'] as List;
      return items.map((item) => MediaItem.fromJson(item)).toList();
    } catch (e) {
      throw Exception('获取续播项目失败：$e');
    }
  }

  /// 清除认证信息
  void clearAuth() {
    _baseUrl = null;
    _accessToken = null;
    _userId = null;
    _currentUser = null;
  }
}
