import 'package:hive/hive.dart';

part 'playback_state.g.dart';

@HiveType(typeId: 1)
class PlaybackState {
  @HiveField(0)
  final String itemId;
  
  @HiveField(1)
  final String serverId;
  
  @HiveField(2)
  final int positionTicks;
  
  @HiveField(3)
  final DateTime lastUpdated;
  
  @HiveField(4)
  final int durationTicks;

  PlaybackState({
    required this.itemId,
    required this.serverId,
    required this.positionTicks,
    required this.lastUpdated,
    required this.durationTicks,
  });

  Duration get position {
    return Duration(microseconds: positionTicks ~/ 10);
  }

  Duration get duration {
    return Duration(microseconds: durationTicks ~/ 10);
  }

  double get progress {
    if (durationTicks == 0) return 0;
    return positionTicks / durationTicks;
  }

  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'serverId': serverId,
      'positionTicks': positionTicks,
      'durationTicks': durationTicks,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory PlaybackState.fromJson(Map<String, dynamic> json) {
    return PlaybackState(
      itemId: json['itemId'] as String,
      serverId: json['serverId'] as String,
      positionTicks: json['positionTicks'] as int,
      durationTicks: json['durationTicks'] as int,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }
}
