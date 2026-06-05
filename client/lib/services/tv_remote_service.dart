import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Android TV 遥控器服务
/// 处理 DPad 导航和遥控器按键
class TvRemoteService {
  static void install(GlobalKey<NavigatorState> navigatorKey) {
    RawKeyboard.instance.addListener((event) {
      if (event is! RawKeyDownEvent) return;

      final logicalKey = event.logicalKey;

      // ESC/返回键
      if (logicalKey == LogicalKeyboardKey.escape ||
          logicalKey == LogicalKeyboardKey.back) {
        if (navigatorKey.currentState?.canPop() == true) {
          navigatorKey.currentState?.pop();
        }
        return;
      }

      // 播放/暂停
      if (logicalKey == LogicalKeyboardKey.mediaPlayPause ||
          logicalKey == LogicalKeyboardKey.space) {
        // TODO: 如果在播放页面，切换播放状态
        return;
      }

      // 快进
      if (logicalKey == LogicalKeyboardKey.mediaFastForward ||
          logicalKey == LogicalKeyboardKey.arrowRight) {
        // TODO: 快进
        return;
      }

      // 快退
      if (logicalKey == LogicalKeyboardKey.mediaRewind ||
          logicalKey == LogicalKeyboardKey.arrowLeft) {
        // TODO: 快退
        return;
      }

      // 确定/选择
      if (logicalKey == LogicalKeyboardKey.enter ||
          logicalKey == LogicalKeyboardKey.gameButtonA) {
        // TODO: 触发当前焦点元素
        return;
      }
    });
  }

  /// 检查是否在 TV 设备
  static bool isTv(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // 大屏通常是 TV
    return size.width >= 1280;
  }

  /// 获取 TV 优化的网格列数
  static int getTvGridColumns(int baseColumns) {
    return baseColumns + 2; // TV 端显示更多列
  }
}
