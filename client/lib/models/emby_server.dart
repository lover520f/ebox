import 'package:hive/hive.dart';

part 'emby_server.g.dart';

@HiveType(typeId: 0)
class EmbyServer {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String url;
  
  @HiveField(3)
  final String? apiKey;
  
  @HiveField(4)
  final String? username;
  
  @HiveField(5)
  final String? password;
  
  @HiveField(6)
  final DateTime lastConnected;
  
  @HiveField(7)
  final bool isActive;

  EmbyServer({
    required this.id,
    required this.name,
    required this.url,
    this.apiKey,
    this.username,
    this.password,
    DateTime? lastConnected,
    this.isActive = false,
  }) : lastConnected = lastConnected ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'apiKey': apiKey,
      'username': username,
      'password': password,
      'lastConnected': lastConnected.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory EmbyServer.fromJson(Map<String, dynamic> json) {
    return EmbyServer(
      id: json['id'] as String,
      name: json['name'] as String,
      url: json['url'] as String,
      apiKey: json['apiKey'] as String?,
      username: json['username'] as String?,
      password: json['password'] as String?,
      lastConnected: json['lastConnected'] != null 
          ? DateTime.parse(json['lastConnected'] as String) 
          : null,
      isActive: json['isActive'] as bool? ?? false,
    );
  }
}
