import 'package:flutter/material.dart';
class ServerProvider extends ChangeNotifier {
  String _serverUrl = '';
  String _apiKey = '';
  String? _userId;
  String get serverUrl => _serverUrl;
  String get apiKey => _apiKey;
  String? get userId => _userId;
  bool get isConnected => _serverUrl.isNotEmpty && _apiKey.isNotEmpty;
  void setServer(String url, String apiKey, String userId) {
    _serverUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
    _apiKey = apiKey;
    _userId = userId;
    notifyListeners();
  }
  void clear() {
    _serverUrl = ''; _apiKey = ''; _userId = null;
    notifyListeners();
  }
}
