import 'package:flutter/foundation.dart';

class ServerInfo {
  final String id;
  final String name;
  final String url;
  final String? username;
  final String? apiKey;
  final bool isActive;

  ServerInfo({
    required this.id,
    required this.name,
    required this.url,
    this.username,
    this.apiKey,
    this.isActive = true,
  });
}

class ServerProvider extends ChangeNotifier {
  final List<ServerInfo> _servers = [];
  ServerInfo? _activeServer;

  List<ServerInfo> get servers => List.unmodifiable(_servers);
  ServerInfo? get activeServer => _activeServer;

  void addServer(ServerInfo server) {
    _servers.add(server);
    if (_activeServer == null) {
      _activeServer = server;
    }
    notifyListeners();
  }

  void removeServer(String id) {
    _servers.removeWhere((s) => s.id == id);
    if (_activeServer?.id == id) {
      _activeServer = _servers.isNotEmpty ? _servers.first : null;
    }
    notifyListeners();
  }

  void setActiveServer(String id) {
    _activeServer = _servers.firstWhere((s) => s.id == id);
    notifyListeners();
  }
}
