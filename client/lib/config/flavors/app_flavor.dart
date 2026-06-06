enum AppFlavor {
  windows,
  androidMobile,
  androidTV,
}

class FlavorConfig {
  final AppFlavor flavor;
  final String name;
  final String title;
  final bool isTV;
  final bool isMobile;

  const FlavorConfig({
    required this.flavor,
    required this.name,
    required this.title,
    required this.isTV,
    required this.isMobile,
  });

  static FlavorConfig? _instance;

  static FlavorConfig get instance {
    if (_instance == null) {
      throw Exception('FlavorConfig 未初始化，请先调用 init()');
    }
    return _instance!;
  }

  static void init(FlavorConfig config) {
    _instance = config;
  }

  static bool get isTV => instance.isTV;
  static bool get isMobile => instance.isMobile;
  static bool get isWindows => instance.flavor == AppFlavor.windows;
}

// Windows 版本
const flavorWindows = FlavorConfig(
  flavor: AppFlavor.windows,
  name: 'windows',
  title: 'E 宝盒',
  isTV: false,
  isMobile: false,
);

// Android Mobile 版本
const flavorAndroidMobile = FlavorConfig(
  flavor: AppFlavor.androidMobile,
  name: 'android-mobile',
  title: 'E 宝盒',
  isTV: false,
  isMobile: true,
);

// Android TV 版本
const flavorAndroidTV = FlavorConfig(
  flavor: AppFlavor.androidTV,
  name: 'android-tv',
  title: 'E 宝盒 TV',
  isTV: true,
  isMobile: false,
);
