import 'package:flutter/foundation.dart';

class PlayerProvider extends ChangeNotifier {
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  double _speed = 1.0;
  bool _isMuted = false;
  double _volume = 1.0;

  bool get isPlaying => _isPlaying;
  Duration get position => _position;
  Duration get duration => _duration;
  double get speed => _speed;
  bool get isMuted => _isMuted;
  double get volume => _volume;

  void updatePosition(Duration position) {
    _position = position;
    notifyListeners();
  }

  void updateDuration(Duration duration) {
    _duration = duration;
    notifyListeners();
  }

  void setPlaying(bool playing) {
    _isPlaying = playing;
    notifyListeners();
  }

  void setSpeed(double speed) {
    _speed = speed;
    notifyListeners();
  }

  void setVolume(double volume) {
    _volume = volume;
    notifyListeners();
  }

  void setMuted(bool muted) {
    _isMuted = muted;
    notifyListeners();
  }

  void reset() {
    _isPlaying = false;
    _position = Duration.zero;
    _duration = Duration.zero;
    _speed = 1.0;
    _isMuted = false;
    _volume = 1.0;
    notifyListeners();
  }
}
