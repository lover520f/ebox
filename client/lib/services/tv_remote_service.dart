import 'package:flutter/services.dart';

enum TvRemoteKey {
  up,
  down,
  left,
  right,
  ok,
  back,
  play,
  pause,
  playPause,
  stop,
  rewind,
  forward,
  menu,
  home,
  settings,
  info,
  colorRed,
  colorGreen,
  colorYellow,
  colorBlue,
  number0,
  number1,
  number2,
  number3,
  number4,
  number5,
  number6,
  number7,
  number8,
  number9,
}

typedef RemoteKeyListener = void Function(TvRemoteKey key);

class TvRemoteService {
  static final TvRemoteService _instance = TvRemoteService._internal();
  factory TvRemoteService() => _instance;
  TvRemoteService._internal();

  RemoteKeyListener? _keyListener;
  bool _isEnabled = false;

  bool get isEnabled => _isEnabled;

  void initialize() {
    if (_isEnabled) return;
    
    HardwareKeyboard.instance.addHandler(_handleKeyEvent);
    _isEnabled = true;
  }

  void dispose() {
    if (!_isEnabled) return;
    
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    _isEnabled = false;
  }

  void setKeyListener(RemoteKeyListener listener) {
    _keyListener = listener;
  }

  bool _handleKeyEvent(KeyEvent event) {
    if (_keyListener == null) return false;
    if (event is! KeyDownEvent) return false;

    final key = _mapAndroidRemoteKey(event.logicalKey);
    if (key != null) {
      _keyListener!(key);
      return true;
    }

    return false;
  }

  TvRemoteKey? _mapAndroidRemoteKey(LogicalKeyboardKey key) {
    // Android TV 遥控器按键映射
    if (key == LogicalKeyboardKey.arrowUp) return TvRemoteKey.up;
    if (key == LogicalKeyboardKey.arrowDown) return TvRemoteKey.down;
    if (key == LogicalKeyboardKey.arrowLeft) return TvRemoteKey.left;
    if (key == LogicalKeyboardKey.arrowRight) return TvRemoteKey.right;
    if (key == LogicalKeyboardKey.select || key == LogicalKeyboardKey.enter) return TvRemoteKey.ok;
    if (key == LogicalKeyboardKey.back || key == LogicalKeyboardKey.escape) return TvRemoteKey.back;
    if (key == LogicalKeyboardKey.mediaPlay) return TvRemoteKey.play;
    if (key == LogicalKeyboardKey.mediaPause) return TvRemoteKey.pause;
    if (key == LogicalKeyboardKey.mediaPlayPause) return TvRemoteKey.playPause;
    if (key == LogicalKeyboardKey.mediaStop) return TvRemoteKey.stop;
    if (key == LogicalKeyboardKey.mediaTrackPrevious) return TvRemoteKey.rewind;
    if (key == LogicalKeyboardKey.mediaTrackNext) return TvRemoteKey.forward;
    if (key == LogicalKeyboardKey.contextMenu || key == LogicalKeyboardKey.menu) return TvRemoteKey.menu;
    if (key == LogicalKeyboardKey.homePage) return TvRemoteKey.home;
    if (key == LogicalKeyboardKey.settings) return TvRemoteKey.settings;
    if (key == LogicalKeyboardKey.help) return TvRemoteKey.info;
    
    // 数字键
    if (key == LogicalKeyboardKey.digit0) return TvRemoteKey.number0;
    if (key == LogicalKeyboardKey.digit1) return TvRemoteKey.number1;
    if (key == LogicalKeyboardKey.digit2) return TvRemoteKey.number2;
    if (key == LogicalKeyboardKey.digit3) return TvRemoteKey.number3;
    if (key == LogicalKeyboardKey.digit4) return TvRemoteKey.number4;
    if (key == LogicalKeyboardKey.digit5) return TvRemoteKey.number5;
    if (key == LogicalKeyboardKey.digit6) return TvRemoteKey.number6;
    if (key == LogicalKeyboardKey.digit7) return TvRemoteKey.number7;
    if (key == LogicalKeyboardKey.digit8) return TvRemoteKey.number8;
    if (key == LogicalKeyboardKey.digit9) return TvRemoteKey.number9;

    return null;
  }
}

// TV 焦点管理器
class TvFocusManager {
  final FocusNode _rootFocusNode = FocusNode();
  FocusNode? _currentFocusNode;
  final List<FocusNode> _focusableNodes = [];

  FocusNode get rootFocusNode => _rootFocusNode;

  void initialize() {
    TvRemoteService().initialize();
    TvRemoteService().setKeyListener(_handleRemoteKey);
  }

  void registerFocusNode(FocusNode node) {
    if (!_focusableNodes.contains(node)) {
      _focusableNodes.add(node);
    }
  }

  void unregisterFocusNode(FocusNode node) {
    _focusableNodes.remove(node);
  }

  void _handleRemoteKey(TvRemoteKey key) {
    switch (key) {
      case TvRemoteKey.up:
        _moveFocus(-1);
        break;
      case TvRemoteKey.down:
        _moveFocus(1);
        break;
      case TvRemoteKey.left:
        _moveFocus(-1);
        break;
      case TvRemoteKey.right:
        _moveFocus(1);
        break;
      case TvRemoteKey.ok:
        _currentFocusNode?.requestFocus();
        break;
      case TvRemoteKey.back:
        // 返回处理
        break;
      case TvRemoteKey.play:
      case TvRemoteKey.pause:
      case TvRemoteKey.playPause:
        // 播放控制
        break;
      default:
        break;
    }
  }

  void _moveFocus(int direction) {
    if (_focusableNodes.isEmpty) return;

    final currentIndex = _focusableNodes.indexOf(_currentFocusNode);
    int newIndex = currentIndex + direction;

    if (newIndex < 0) newIndex = _focusableNodes.length - 1;
    if (newIndex >= _focusableNodes.length) newIndex = 0;

    _currentFocusNode = _focusableNodes[newIndex];
    _currentFocusNode?.requestFocus();
  }

  void dispose() {
    TvRemoteService().dispose();
    _rootFocusNode.dispose();
    for (var node in _focusableNodes) {
      node.dispose();
    }
    _focusableNodes.clear();
  }
}
