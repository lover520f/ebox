import 'dart:convert';
import 'package:http/http.dart' as http;

class EmbyApiService {
  final String baseUrl;
  final String? apiKey;
  final String? userId;

  EmbyApiService({
    required this.baseUrl,
    this.apiKey,
    this.userId,
  });

  String get _authHeader => 'MediaBrowser Client="E 宝盒", Token="$apiKey"';

  /// 获取用户视图（媒体库列表）
  Future<List<Map<String, dynamic>>> getUserViews() async {
    try {
      final url = Uri.parse('$baseUrl/Users/$userId/Views?api_key=$apiKey');
      final response = await http.get(url, headers: {
        'X-Emby-Authorization': _authHeader,
      }).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['Items'] as List? ?? [];
        return items.map((item) => item as Map<String, dynamic>).toList();
      }
      return [];
    } catch (e) {
      print('获取用户视图失败：$e');
      return [];
    }
  }

  /// 获取媒体库项目
  Future<List<Map<String, dynamic>>> getLibraryItems({
    String? parentId,
    String includeItemTypes = 'Movie,Series',
    int limit = 50,
  }) async {
    try {
      final queryParams = <String, String>{
        'api_key': apiKey ?? '',
        'ParentId': parentId ?? '',
        'IncludeItemTypes': includeItemTypes,
        'Recursive': 'true',
        'Limit': limit.toString(),
        'SortBy': 'SortName',
        'SortOrder': 'Ascending',
        'ImageTypeLimit': '1',
        'EnableImageTypes': 'Primary,Backdrop',
      };

      final uri = Uri.parse('$baseUrl/Items').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: {
        'X-Emby-Authorization': _authHeader,
      }).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['Items'] as List? ?? [];
        return items.map((item) => item as Map<String, dynamic>).toList();
      }
      return [];
    } catch (e) {
      print('获取媒体库失败：$e');
      return [];
    }
  }

  /// 获取继续观看
  Future<List<Map<String, dynamic>>> getResumeItems({int limit = 20}) async {
    try {
      final queryParams = <String, String>{
        'api_key': apiKey ?? '',
        'Limit': limit.toString(),
        'SortBy': 'DatePlayed',
        'SortOrder': 'Descending',
        'IncludeItemTypes': 'Movie,Episode',
        'Recursive': 'true',
        'IsPlayed': 'false',
        'ImageTypeLimit': '1',
      };

      final uri = Uri.parse('$baseUrl/Users/$userId/Items/Resume').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: {
        'X-Emby-Authorization': _authHeader,
      }).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['Items'] as List? ?? [];
        return items.map((item) => item as Map<String, dynamic>).toList();
      }
      return [];
    } catch (e) {
      print('获取续播失败：$e');
      return [];
    }
  }

  /// 获取最近添加
  Future<List<Map<String, dynamic>>> getRecentlyAdded({int limit = 20}) async {
    try {
      final queryParams = <String, String>{
        'api_key': apiKey ?? '',
        'Limit': limit.toString(),
        'SortBy': 'DateCreated,SortName',
        'SortOrder': 'Descending',
        'IncludeItemTypes': 'Movie,Series,Episode',
        'Recursive': 'true',
        'ImageTypeLimit': '1',
      };

      final uri = Uri.parse('$baseUrl/Users/$userId/Items/Latest').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: {
        'X-Emby-Authorization': _authHeader,
      }).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['Items'] as List? ?? [];
        return items.map((item) => item as Map<String, dynamic>).toList();
      }
      return [];
    } catch (e) {
      print('获取最近添加失败：$e');
      return [];
    }
  }

  /// 获取项目详情
  Future<Map<String, dynamic>?> getItem(String itemId) async {
    try {
      final url = Uri.parse('$baseUrl/Items/$itemId?api_key=$apiKey');
      final response = await http.get(url, headers: {
        'X-Emby-Authorization': _authHeader,
      }).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('获取详情失败：$e');
      return null;
    }
  }

  /// 搜索
  Future<List<Map<String, dynamic>>> search({
    String? query,
    String includeItemTypes = 'Movie,Series,Episode',
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, String>{
        'api_key': apiKey ?? '',
        'Query': query ?? '',
        'Limit': limit.toString(),
        'IncludeItemTypes': includeItemTypes,
      };

      final uri = Uri.parse('$baseUrl/Items').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: {
        'X-Emby-Authorization': _authHeader,
      }).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['Items'] as List? ?? [];
        return items.map((item) => item as Map<String, dynamic>).toList();
      }
      return [];
    } catch (e) {
      print('搜索失败：$e');
      return [];
    }
  }

  /// 获取播放信息
  Future<Map<String, dynamic>?> getPlaybackInfo(String itemId) async {
    try {
      final queryParams = <String, String>{
        'api_key': apiKey ?? '',
        'StartTimeTicks': '0',
        'UserId': userId ?? '',
        'AutoOpenLiveStream': 'true',
      };

      final uri = Uri.parse('$baseUrl/Items/$itemId/PlaybackInfo').replace(queryParameters: queryParams);
      final response = await http.post(uri, headers: {
        'X-Emby-Authorization': _authHeader,
        'Content-Type': 'application/json',
      }).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('获取播放信息失败：$e');
      return null;
    }
  }

  /// 更新播放进度
  Future<void> updatePlayState(String itemId, {
    int positionTicks = 0,
    bool isPaused = false,
  }) async {
    try {
      final queryParams = <String, String>{
        'api_key': apiKey ?? '',
        'PositionTicks': positionTicks.toString(),
      };

      String endpoint = isPaused ? 'Paused' : 'Progress';
      final uri = Uri.parse('$baseUrl/Sessions/Playing/$endpoint').replace(queryParameters: queryParams);
      
      await http.post(uri, headers: {
        'X-Emby-Authorization': _authHeader,
      }).timeout(const Duration(seconds: 5));
    } catch (e) {
      print('更新播放状态失败：$e');
    }
  }

  /// 标记已播放
  Future<void> markPlayed(String itemId) async {
    try {
      final url = Uri.parse('$baseUrl/Users/$userId/PlayedItems/$itemId?api_key=$apiKey');
      await http.post(url, headers: {
        'X-Emby-Authorization': _authHeader,
      });
    } catch (e) {
      print('标记已播放失败：$e');
    }
  }
}
