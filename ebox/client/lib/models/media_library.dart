class MediaLibrary {
  final String id;
  final String name;
  final String type;
  final String? collectionType;
  final String? imageUrl;
  
  const MediaLibrary({
    required this.id,
    required this.name,
    required this.type,
    this.collectionType,
    this.imageUrl,
  });
  
  factory MediaLibrary.fromJson(Map<String, dynamic> json) {
    return MediaLibrary(
      id: json['Id'] as String,
      name: json['Name'] as String,
      type: json['Type'] as String,
      collectionType: json['CollectionType'] as String?,
      imageUrl: json['ImageTags']?['Primary'] != null 
          ? 'primary/${json['ImageTags']?['Primary']}' 
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'Name': name,
      'Type': type,
      'CollectionType': collectionType,
    };
  }
  
  String get displayType {
    switch (collectionType) {
      case 'movies':
        return '电影';
      case 'tvshows':
        return '电视剧';
      case 'music':
        return '音乐';
      case 'books':
        return '图书';
      case 'homevideos':
        return '家庭视频';
      case 'photos':
        return '照片';
      default:
        return '媒体库';
    }
  }
}
