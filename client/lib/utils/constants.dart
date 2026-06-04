class AppConstants {
  // 应用信息
  static const String appName = 'E 宝盒';
  static const String appVersion = '1.0.0';
  static const String deviceId = 'ebox-windows-client';
  static const String deviceName = 'EBox Windows';
  
  // Emby API 配置
  static const String embyClient = 'EBox';
  static const String embyVersion = '1.0.0';
  
  // API 端点
  static const List<String> defaultApiEndpoints = [
    '/System/Info/Public',
    '/Users/AuthenticateByName',
    '/Users/{userId}/Views',
    '/Users/{userId}/Items',
    '/Items/{itemId}',
    '/Items/{itemId}/Downloading',
  ];
  
  // 媒体类型
  static const String mediaTypeMovie = 'Movie';
  static const String mediaTypeSeries = 'Series';
  static const String mediaTypeEpisode = 'Episode';
  static const String mediaTypeSeason = 'Season';
  static const String mediaTypeAudio = 'Audio';
  static const String mediaTypeBook = 'Book';
  static const String mediaTypeComic = 'Comic';
  
  // 媒体库类型
  static const String collectionTypeMovies = 'movies';
  static const String collectionTypeTvShows = 'tvshows';
  static const String collectionTypeMusic = 'music';
  static const String collectionTypeBooks = 'books';
  
  // 画质选项
  static const List<String> qualityOptions = [
    'Original',
    '4K',
    '1080p',
    '720p',
    '480p',
  ];
  
  // 播放速度选项
  static const List<double> playbackSpeedOptions = [
    0.5,
    0.75,
    1.0,
    1.25,
    1.5,
    1.75,
    2.0,
  ];
  
  // 存储键名
  static const String storageServersKey = 'servers';
  static const String storageActiveServerKey = 'active_server';
  static const String storageUserKey = 'current_user';
  static const String storagePlaybackProgressKey = 'playback_progress';
  static const String storageRecentlyPlayedKey = 'recently_played';
  static const String storageSettingsKey = 'settings';
  
  // 设置项
  static const String settingAutoConnect = 'auto_connect';
  static const String settingDefaultQuality = 'default_quality';
  static const String settingEnableAnimations = 'enable_animations';
  static const String settingGridViewCount = 'grid_view_count';
  
  // URL 参数
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
  };
  
  // 超时设置
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // 重试配置
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 2);
}
