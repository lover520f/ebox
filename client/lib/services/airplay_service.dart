import 'package:flutter/foundation.dart';

/// AirPlay 和画中画服务（iOS）
/// 注：需要原生平台实现，此处为接口定义
class AirplayService extends ChangeNotifier {
  bool _isAirplayAvailable = false;
  bool _isPictureInPictureAvailable = false;
  bool _isAirplayActive = false;
  bool _isPictureInPictureActive = false;

  bool get isAirplayAvailable => _isAirplayAvailable;
  bool get isPictureInPictureAvailable => _isPictureInPictureAvailable;
  bool get isAirplayActive => _isAirplayActive;
  bool get isPictureInPictureActive => _isPictureInPictureActive;

  /// 初始化服务
  Future<void> initialize() async {
    // TODO: 调用 platform channel 检测设备能力
    // PlatformChannel.invokeMethod('checkAirplaySupport')
    // PlatformChannel.invokeMethod('checkPictureInPictureSupport')
    
    _isAirplayAvailable = true; // 暂时假设支持
    _isPictureInPictureAvailable = true;
    notifyListeners();
  }

  /// 开始 AirPlay 投屏
  Future<void> startAirplay() async {
    // TODO: 实现 AirPlay
    // PlatformChannel.invokeMethod('startAirplay')
  }

  /// 停止 AirPlay
  Future<void> stopAirplay() async {
    // TODO: 实现
  }

  /// 开启画中画
  Future<void> startPictureInPicture() async {
    // TODO: 实现画中画
    // PlatformChannel.invokeMethod('startPictureInPicture')
  }

  /// 关闭画中画
  Future<void> stopPictureInPicture() async {
    // TODO: 实现
  }

  /// 切换画中画
  Future<void> togglePictureInPicture() async {
    if (_isPictureInPictureActive) {
      await stopPictureInPicture();
    } else {
      await startPictureInPicture();
    }
  }
}
