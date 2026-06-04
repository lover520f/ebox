import 'package:flutter/foundation.dart';

extension EmbyApiClientExtension {
  // 这个方法用于 ServerProvider 中的测试连接功能
  static Future<bool> testPublicInfo(String url) async {
    try {
      final response = await Dio().get('$url/System/Info/Public');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
