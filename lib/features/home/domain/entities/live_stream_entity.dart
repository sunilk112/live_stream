import 'package:equatable/equatable.dart';

/// Pure domain entity — no JSON, no Flutter, no framework. Represents a single
/// live stream within the app's business rules.
class LiveStreamEntity extends Equatable {
  final String id;
  final String title;
  final String hostName;
  final String thumbnailUrl;
  final String avatarUrl;
  final int viewerCount;
  final String countryFlag; // emoji flag, e.g. 🇵🇭
  final bool isLive;
  final bool isFollowed;

  const LiveStreamEntity({
    required this.id,
    required this.title,
    required this.hostName,
    required this.thumbnailUrl,
    required this.avatarUrl,
    required this.viewerCount,
    required this.countryFlag,
    required this.isLive,
    this.isFollowed = false,
  });

  LiveStreamEntity copyWith({bool? isFollowed}) {
    return LiveStreamEntity(
      id: id,
      title: title,
      hostName: hostName,
      thumbnailUrl: thumbnailUrl,
      avatarUrl: avatarUrl,
      viewerCount: viewerCount,
      countryFlag: countryFlag,
      isLive: isLive,
      isFollowed: isFollowed ?? this.isFollowed,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        hostName,
        thumbnailUrl,
        avatarUrl,
        viewerCount,
        countryFlag,
        isLive,
        isFollowed,
      ];
}
