import '../../domain/entities/live_stream_entity.dart';

/// DATA-layer model. Extends the domain entity and adds serialization. The rest
/// of the app only ever sees [LiveStreamEntity]; JSON details stay here.
class LiveStreamModel extends LiveStreamEntity {
  const LiveStreamModel({
    required super.id,
    required super.title,
    required super.hostName,
    required super.thumbnailUrl,
    required super.avatarUrl,
    required super.viewerCount,
    required super.countryFlag,
    required super.isLive,
    super.isFollowed,
  });

  factory LiveStreamModel.fromJson(Map<String, dynamic> json) {
    return LiveStreamModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? 'Untitled',
      hostName: json['host_name'] as String? ?? 'Unknown',
      thumbnailUrl: json['thumbnail_url'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String? ?? '',
      viewerCount: (json['viewer_count'] as num?)?.toInt() ?? 0,
      countryFlag: json['country_flag'] as String? ?? '🌐',
      isLive: json['is_live'] as bool? ?? false,
      isFollowed: json['is_followed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'host_name': hostName,
      'thumbnail_url': thumbnailUrl,
      'avatar_url': avatarUrl,
      'viewer_count': viewerCount,
      'country_flag': countryFlag,
      'is_live': isLive,
      'is_followed': isFollowed,
    };
  }
}
