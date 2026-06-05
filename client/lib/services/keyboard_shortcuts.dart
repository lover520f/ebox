import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 全局键盘快捷键服务
/// 支持 Windows/Linux 桌面端
class KeyboardShortcuts {
  static void install(GlobalKey<NavigatorState> navigatorKey) {
    RawKeyboard.instance.addListener((RawKeyEvent event) {
      if (event is! RawKeyDownEvent) return;
      
      // Ctrl+F - 全屏
      if (event.isControlPressed && 
          event.logicalKey == LogicalKeyboardKey.keyF) {
        // TODO: 切换全屏
        return;
      }
      
      // Space - 播放/暂停（如果在播放页面）
      if (event.logicalKey == LogicalKeyboardKey.space) {
        // TODO: 如果当前是播放页面，切换播放状态
        return;
      }
      
      // ESC - 返回
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        if (navigatorKey.currentState?.canPop() == true) {
          navigatorKey.currentState?.pop();
          return;
        }
      }
      
      // F5 - 刷新
      if (event.logicalKey == LogicalKeyboardKey.f5) {
        // TODO: 刷新当前页面
        return;
      }
      
      // Ctrl+R - 重新加载
      if (event.isControlPressed && 
          event.logicalKey == LogicalKeyboardKey.keyR) {
        // TODO: 重新加载
        return;
      }
    });
  }
}
