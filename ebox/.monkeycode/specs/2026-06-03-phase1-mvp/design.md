# E 宝盒 (ebox) - 第一阶段 MVP 技术设计文档

## 1. 技术架构

### 1.1 整体架构

```
┌─────────────────────────────────────────────────────────┐
│                      E 宝盒 客户端                        │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐       │
│  │  Windows    │  │   Android   │  │     iOS     │       │
│  │   Desktop   │  │    Mobile   │  │   Mobile    │       │
│  └─────────────┘  └─────────────┘  └─────────────┘       │
│              Flutter (Dart) 跨平台 UI 框架                 │
└─────────────────────────────────────────────────────────┘
                            │
                            │ REST API / HTTP
                            ▼
┌─────────────────────────────────────────────────────────┐
│                  Emby 媒体服务器                         │
│  ┌──────────────────────────────────────────────────┐   │
│  │  媒体库管理 / 元数据 / 转码 / 用户认证             │   │
│  └──────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│                  E 宝盒 本地服务端 (可选)                  │
│  ┌──────────────────────────────────────────────────┐   │
│  │  Go 语言实现 / 本地媒体扫描 / 元数据管理           │   │
│  └──────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

### 1.2 客户端技术栈

| 组件 | 技术选型 | 说明 |
|------|---------|------|
| **UI 框架** | Flutter 3.x | Google 跨平台 UI 框架 |
| **状态管理** | Provider | 轻量级响应式状态管理 |
| **HTTP 客户端** | Dio | 高性能 HTTP 请求库 |
| **视频播放** | video_player + chewie | Flutter 官方播放器 + UI 封装 |
| **音频播放** | just_audio | 专业音频播放库 |
| **本地存储** | Hive | 轻量级 NoSQL 数据库 |
| **路由** | go_router | 声明式路由管理 |
| **图片缓存** | cached_network_image | 网络图片缓存 |

### 1.3 服务端技术栈（阶段 4 启用）

| 组件 | 技术选型 | 说明 |
|------|---------|------|
| **Web 框架** | Gin | 高性能 Go Web 框架 |
| **数据库** | SQLite | 轻量级嵌入式数据库 |
| **ORM** | GORM | Go 语言 ORM 库 |
| **日志** | Logrus | 结构化日志库 |

## 2. 目录结构

### 2.1 客户端目录结构

```
client/
├── lib/
│   ├── main.dart                 # 应用入口
│   ├── app.dart                  # 应用配置
│   │
│   ├── config/                   # 配置相关
│   │   ├── routes.dart           # 路由配置
│   │   └── theme.dart            # 主题配置
│   │
│   ├── models/                   # 数据模型
│   │   ├── emby_server.dart      # Emby 服务器配置
│   │   ├── media_item.dart       # 媒体项模型
│   │   ├── user.dart             # 用户模型
│   │   └── playback_state.dart   # 播放状态模型
│   │
│   ├── services/                 # 服务层
│   │   ├── emby_api.dart         # Emby API 客户端
│   │   ├── local_media.dart      # 本地媒体服务
│   │   ├── playback_service.dart # 播放服务
│   │   └── storage_service.dart  # 本地存储服务
│   │
│   ├── providers/                # 状态管理
│   │   ├── server_provider.dart  # 服务器状态
│   │   ├── media_provider.dart   # 媒体库状态
│   │   └── player_provider.dart  # 播放器状态
│   │
│   ├── pages/                    # 页面
│   │   ├── welcome/              # 欢迎页
│   │   ├── home/                 # 主页
│   │   ├── server/               # 服务器管理
│   │   ├── library/              # 媒体库
│   │   ├── detail/               # 媒体详情
│   │   ├── player/               # 播放器
│   │   └── settings/             # 设置
│   │
│   ├── widgets/                  # 可复用组件
│   │   ├── media_card.dart       # 媒体卡片
│   │   ├── poster_grid.dart      # 海报网格
│   │   ├── player_controls.dart  # 播放控制
│   │   └── loading.dart          # 加载动画
│   │
│   └── utils/                    # 工具类
│       ├── constants.dart        # 常量定义
│       ├── helpers.dart          # 辅助函数
│       └── extensions.dart       # 扩展方法
│
├── assets/                       # 资源文件
│   ├── images/                   # 图片资源
│   └── fonts/                    # 字体资源
│
├── test/                         # 测试文件
│
└── pubspec.yaml                  # 依赖配置
```

### 2.2 服务端目录结构（阶段 4 启用）

```
server/
├── cmd/
│   └── main.go                   # 程序入口
├── internal/
│   ├── api/                      # API 层
│   │   ├── handlers.go           # HTTP 处理器
│   │   └── routes.go             # 路由配置
│   ├── service/                  # 业务逻辑
│   │   ├── media_service.go      # 媒体服务
│   │   └── metadata_service.go   # 元数据服务
│   ├── model/                    # 数据模型
│   │   └── media.go              # 媒体模型
│   └── config/                   # 配置
│       └── config.go             # 配置加载
├── pkg/                          # 公共包
├── assets/                       # 资源文件
└── go.mod                        # Go 模块配置
```

## 3. 核心模块设计

### 3.1 Emby API 客户端

```dart
// lib/services/emby_api.dart
class EmbyApiClient {
  final Dio _dio;
  
  // 认证
  Future<User> authenticate(String serverUrl, String username, String password);
  
  // 获取媒体库
  Future<List<MediaLibrary>> getLibraries(String userId);
  
  // 获取媒体项列表
  Future<PagedResponse<MediaItem>> getItems(String parentId, {Map<String, dynamic>? filters});
  
  // 获取媒体详情
  Future<MediaDetail> getItemDetail(String itemId);
  
  // 获取播放链接
  Future<String> getPlaybackUrl(String itemId, {PlaybackOptions? options});
  
  // 搜索
  Future<List<MediaItem>> search(String query, {String? parentId});
  
  // 上报播放进度
  Future<void> reportPlaybackProgress(String itemId, Duration position);
}
```

### 3.2 数据模型

```dart
// lib/models/media_item.dart
class MediaItem {
  final String id;
  final String name;
  final String type; // Movie, Series, Episode, etc.
  final String? imageUrl;
  final int? productionYear;
  final double? communityRating;
  final String? overview;
  final DateTime? dateCreated;
  
  // 视频特有
  final int? runtimeTicks;
  final String? mediaSourceId;
  
  // 电视剧特有
  final int? seasonNumber;
  final int? episodeNumber;
  final String? seriesName;
}

// lib/models/emby_server.dart
class EmbyServer {
  final String id;
  final String name;
  final String url;
  final String? apiKey;
  final String? username;
  final String? password;
  final DateTime lastConnected;
  final bool isActive;
}

// lib/models/playback_state.dart
class PlaybackState {
  final String itemId;
  final Duration position;
  final DateTime lastUpdated;
  final String serverId;
}
```

### 3.3 状态管理

```dart
// lib/providers/server_provider.dart
class ServerProvider extends ChangeNotifier {
  List<EmbyServer> _servers = [];
  EmbyServer? _activeServer;
  User? _currentUser;
  
  List<EmbyServer> get servers => _servers;
  EmbyServer? get activeServer => _activeServer;
  bool get isAuthenticated => _currentUser != null;
  
  Future<void> addServer(EmbyServer server);
  Future<void> removeServer(String id);
  Future<void> connectToServer(String serverId);
  Future<void> disconnect();
}

// lib/providers/media_provider.dart
class MediaProvider extends ChangeNotifier {
  Map<String, List<MediaItem>> _libraries = {};
  bool _isLoading = false;
  String? _error;
  
  Future<void> loadLibraries();
  Future<void> loadItems(String parentId);
  Future<List<MediaItem>> search(String query);
}
```

## 4. 页面流程图

### 4.1 应用启动流程

```
┌─────────────┐
│  应用启动   │
└──────┬──────┘
       │
       ▼
┌─────────────┐      否       ┌─────────────┐
│ 有服务器配置？│────────────▶│  欢迎页     │
└──────┬──────┘               │ (添加服务器)│
       │ 是                   └─────────────┘
       ▼
┌─────────────┐
│  主页       │
│ (媒体库列表)│
└─────────────┘
```

### 4.2 媒体浏览流程

```
┌─────────────┐
│    主页     │
└──────┬──────┘
       │ 选择媒体库
       ▼
┌─────────────┐
│  媒体库页   │──────┐
│  (海报墙)   │      │ 点击媒体
└──────┬──────┘      │
       │ 搜索        ▼
       │        ┌─────────────┐
       │        │  媒体详情页  │
       │        └──────┬──────┘
       │               │ 点击播放
       │               ▼
       │        ┌─────────────┐
       └───────▶│  播放器页    │
                └─────────────┘
```

## 5. API 接口设计

### 5.1 Emby API 端点

| 端点 | 方法 | 说明 |
|------|------|------|
| `/Users/AuthenticateByName` | POST | 用户认证 |
| `/Users/{userId}/Views` | GET | 获取媒体库 |
| `/Users/{userId}/Items` | GET | 获取媒体项列表 |
| `/Items/{itemId}` | GET | 获取媒体详情 |
| `/Items/{itemId}/Download` | GET | 获取播放链接 |
| `/Items/RemoteSearch` | GET | 远程搜索 |
| `/Sessions/Playing/Progress` | POST | 上报播放进度 |

### 5.2 请求示例

```http
GET /Users/{userId}/Items?parentId={libraryId}&includeItemTypes=Movie&sortBy=SortName&sortOrder=Ascending
Authorization: MediaBrowser Client="EBox", Device="Windows", Version="1.0.0", DeviceId="xxx"
X-Emby-Authorization: MediaBrowser Client="EBox", Device="Windows", Version="1.0.0", DeviceId="xxx", Token="xxx"
```

### 5.3 响应示例

```json
{
  "Items": [
    {
      "Id": "abc123",
      "Name": "肖申克的救赎",
      "Type": "Movie",
      "ImageUrl": "/Items/abc123/Images/Primary",
      "ProductionYear": 1994,
      "CommunityRating": 9.3,
      "Overview": "希望让人自由...",
      "RunTimeTicks": 8520000000
    }
  ],
  "TotalRecordCount": 100
}
```

## 6. UI 设计规范

### 6.1 色彩方案

```dart
// 主色调
const primaryColor = Color(0xFF6366F1);    // 靛蓝色
const primaryVariant = Color(0xFF4F46E5);  // 深靛蓝

// 渐变色
const gradientColors = [
  Color(0xFF6366F1),  // 靛蓝
  Color(0xFF8B5CF6),  // 紫色
];

// 背景色（深色主题）
const backgroundColor = Color(0xFF0F172A);     // 深蓝黑
const surfaceColor = Color(0xFF1E293B);        // 卡片背景
const cardColor = Color(0xFF334155);           // 次级卡片

// 文字颜色
const textPrimary = Color(0xFFF8FAFC);         // 主文字
const textSecondary = Color(0xFF94A3B8);       // 次要文字
```

### 6.2 圆角规范

```dart
const smallRadius = 8.0;     // 小按钮、标签
const mediumRadius = 12.0;   // 卡片、输入框
const largeRadius = 16.0;    // 大卡片、对话框
const xLargeRadius = 24.0;   // 特殊容器
```

### 6.3 间距规范

```dart
const spacingXS = 4.0;
const spacingS = 8.0;
const spacingM = 16.0;
const spacingL = 24.0;
const spacingXL = 32.0;
```

### 6.4 字体规范

```dart
// 字号
const fontSizeXS = 12.0;
const fontSizeS = 14.0;
const fontSizeM = 16.0;
const fontSizeL = 20.0;
const fontSizeXL = 24.0;
const fontSizeXXL = 32.0;

// 字重
const fontWeightNormal = FontWeight.w400;
const fontWeightMedium = FontWeight.w500;
const fontWeightSemiBold = FontWeight.w600;
const fontWeightBold = FontWeight.w700;
```

## 7. 播放器设计

### 7.1 播放器 UI 组件

```
┌────────────────────────────────────────────────────┐
│  ← 返回                            ⚙️ 设置         │
│                                                    │
│                                                    │
│                    [视频画面]                       │
│                                                    │
│                                                    │
│  ───────────────────────────────────────────       │
│  │ 进度条 [━━━━━━━━━━━━━━━○━━━━━━━━━━]  │
│  ───────────────────────────────────────────       │
│                                                    │
│  ◀◀    ▶/⏸    ▶▶           💬字幕    ⚡画质        │
│                                                    │
└────────────────────────────────────────────────────┘
```

### 7.2 播放控制逻辑

```dart
class PlayerController {
  // 基础控制
  Future<void> play();
  Future<void> pause();
  Future<void> seekTo(Duration position);
  Future<void> setSpeed(double speed);
  
  // 字幕
  Future<void> loadSubtitle(String path);
  Future<void> switchSubtitleTrack(int index);
  
  // 画质
  Future<void> switchQuality(String quality);
  
  // 进度记忆
  void saveProgress();
  Future<Duration?> loadProgress(String itemId);
}
```

## 8. 本地存储设计

### 8.1 Hive 数据框设计

```dart
// 服务器配置
@HiveType(typeId: 0)
class EmbyServerBox {
  @HiveField(0) String id;
  @HiveField(1) String name;
  @HiveField(2) String url;
  @HiveField(3) String? apiKey;
  @HiveField(4) String? username;
  @HiveField(5) String? password;
}

// 播放进度
@HiveType(typeId: 1)
class PlaybackProgressBox {
  @HiveField(0) String itemId;
  @HiveField(1) String serverId;
  @HiveField(2) int positionTicks;
  @HiveField(3) DateTime lastUpdated;
}

// 最近播放
@HiveType(typeId: 2)
class RecentlyPlayedBox {
  @HiveField(0) String itemId;
  @HiveField(1) String serverId;
  @HiveField(2) String title;
  @HiveField(3) String imageUrl;
  @HiveField(4) DateTime playedAt;
}
```

## 9. 错误处理

### 9.1 错误类型

```dart
enum AppErrorType {
  networkError,          // 网络错误
  authenticationError,   // 认证失败
  notFoundError,         // 资源不存在
  serverError,           // 服务端错误
  parseError,           // 解析错误
  permissionDenied,     // 权限不足
  unknown,              // 未知错误
}

class AppException implements Exception {
  final AppErrorType type;
  final String message;
  final dynamic originalError;
}
```

### 9.2 错误处理策略

```dart
// 网络错误：重试机制（最多 3 次，指数退避）
// 认证错误：清除本地缓存，跳转登录页
// 服务器错误：友好提示，记录日志
// 解析错误：降级处理，展示可用数据
```

## 10. 性能优化

### 10.1 图片加载优化

```dart
// 使用 cached_network_image
CachedNetworkImage(
  imageUrl: imageUrl,
  placeholder: (context, url) => ShimmerPlaceholder(),
  errorWidget: (context, url, error) => ErrorPlaceholder(),
  fit: BoxFit.cover,
  memCacheWidth: 400,  // 限制内存缓存尺寸
);
```

### 10.2 列表渲染优化

```dart
// 使用 ListView.builder 延迟加载
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => MediaCard(items[index]),
  addAutomaticKeepAlives: true,
  cacheExtent: 500,  // 预加载范围
);
```

### 10.3 状态更新优化

```dart
// 避免不必要的 rebuild
Selector<MediaProvider, List<MediaItem>>(
  selector: (context, provider) => provider.items,
  builder: (context, items, child) => MediaGrid(items),
);
```

## 11. 安全考虑

### 11.1 凭证存储

```dart
// 密码使用简单加密存储（Windows 使用 DPAPI）
String encryptPassword(String password) {
  // Windows: 调用 Windows DPAPI
  // 其他平台：使用 flutter_secure_storage
}
```

### 11.2 API Key 保护

```dart
// API Key 不在日志中打印
// 请求头中动态添加
 dio.options.headers['X-Emby-Authorization'] = buildAuthHeader(apiKey);
```

## 12. 测试策略

### 12.1 单元测试

- Service 层逻辑测试
- Model 序列化测试
- Provider 状态管理测试

### 12.2 组件测试

- Widget 渲染测试
- 用户交互测试
- 主题切换测试

### 12.3 集成测试

- Emby API 连接测试
- 播放器完整流程测试
- 本地媒体扫描测试

---

**文档版本**: 1.0  
**创建日期**: 2026-06-03  
**最后更新**: 2026-06-03
