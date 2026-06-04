class MediaItem {
  final String id;
  final String name;
  final String type;
  final String? overview;
  final int? productionYear;
  final double? communityRating;
  final int? runTimeTicks;
  final Map<String, String>? imageTags;
  final String? seriesName;
  final int? seasonNumber;
  final int? episodeNumber;
  final String? mediaSourceId;
  final List<MediaSource>? mediaSources;
  final List<People>? people;
  final List<String>? genres;
  final String? officialRating;
  
  const MediaItem({
    required this.id,
    required this.name,
    required this.type,
    this.overview,
    this.productionYear,
    this.communityRating,
    this.runTimeTicks,
    this.imageTags,
    this.seriesName,
    this.seasonNumber,
    this.episodeNumber,
    this.mediaSourceId,
    this.mediaSources,
    this.people,
    this.genres,
    this.officialRating,
  });
  
  factory MediaItem.fromJson(Map<String, dynamic> json) {
    return MediaItem(
      id: json['Id'] as String,
      name: json['Name'] as String,
      type: json['Type'] as String,
      overview: json['Overview'] as String?,
      productionYear: json['ProductionYear'] as int?,
      communityRating: (json['CommunityRating'] as num?)?.toDouble(),
      runTimeTicks: json['RunTimeTicks'] as int?,
      imageTags: json['ImageTags'] != null 
          ? Map<String, String>.from(json['ImageTags']) 
          : null,
      seriesName: json['SeriesName'] as String?,
      seasonNumber: json['ParentIndexNumber'] as int?,
      episodeNumber: json['IndexNumber'] as int?,
      mediaSourceId: json['MediaSourceId'] as String?,
      mediaSources: json['MediaSources'] != null
          ? (json['MediaSources'] as List).map((s) => MediaSource.fromJson(s)).toList()
          : null,
      people: json['People'] != null
          ? (json['People'] as List).map((p) => People.fromJson(p)).toList()
          : null,
      genres: json['Genres'] != null
          ? (json['Genres'] as List).cast<String>()
          : null,
      officialRating: json['OfficialRating'] as String?,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'Name': name,
      'Type': type,
      'Overview': overview,
      'ProductionYear': productionYear,
      'CommunityRating': communityRating,
      'RunTimeTicks': runTimeTicks,
    };
  }
  
  Duration get duration {
    if (runTimeTicks == null) return Duration.zero;
    return Duration(microseconds: runTimeTicks! ~/ 10);
  }
  
  String get displayDuration {
    final duration = this.duration;
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    if (hours > 0) {
      return '${hours}小时${minutes}分钟';
    } else {
      return '${minutes}分钟';
    }
  }
  
  String get displayRating {
    switch (officialRating) {
      case 'G':
        return 'G';
      case 'PG':
        return 'PG';
      case 'PG-13':
        return 'PG-13';
      case 'R':
        return 'R';
      case 'NC-17':
        return 'NC-17';
      default:
        return officialRating ?? '';
    }
  }
  
  bool get isMovie => type == 'Movie';
  bool get isSeries => type == 'Series';
  bool get isEpisode => type == 'Episode';
}

class MediaSource {
  final String id;
  final String path;
  final int? size;
  final String? container;
  final int? bitRate;
  
  const MediaSource({
    required this.id,
    required this.path,
    this.size,
    this.container,
    this.bitRate,
  });
  
  factory MediaSource.fromJson(Map<String, dynamic> json) {
    return MediaSource(
      id: json['Id'] as String,
      path: json['Path'] as String,
      size: json['Size'] as int?,
      container: json['Container'] as String?,
      bitRate: json['BitRate'] as int?,
    );
  }
}

class People {
  final String id;
  final String name;
  final String role;
  final String type;
  
  const People({
    required this.id,
    required this.name,
    required this.role,
    required this.type,
  });
  
  factory People.fromJson(Map<String, dynamic> json) {
    return People(
      id: json['Id'] as String,
      name: json['Name'] as String,
      role: json['Role'] as String?,
      type: json['Type'] as String,
    );
  }
}
