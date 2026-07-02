import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/number_formatter.dart';
import '../../domain/entities/live_stream_entity.dart';

/// A single live-stream tile in the home grid: a portrait thumbnail with a
/// viewer-count badge (top-left) and an overlaid footer (avatar, host name +
/// flag, and a "+ Follow" pill).
class StreamGridCard extends StatelessWidget {
  final LiveStreamEntity stream;
  final VoidCallback? onTap;
  final VoidCallback? onFollowTap;

  const StreamGridCard({
    super.key,
    required this.stream,
    this.onTap,
    this.onFollowTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: AspectRatio(
          aspectRatio: 0.74,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _Thumbnail(url: stream.thumbnailUrl),
              // Bottom scrim for legibility of the footer content.
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.center,
                    colors: [Color(0xB3000000), Color(0x00000000)],
                  ),
                ),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: _ViewerBadge(count: stream.viewerCount),
              ),
              Positioned(
                left: 10,
                right: 10,
                bottom: 10,
                child: _Footer(
                  name: stream.hostName,
                  flag: stream.countryFlag,
                  avatarUrl: stream.avatarUrl,
                  isFollowed: stream.isFollowed,
                  onFollowTap: onFollowTap,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  final String url;

  const _Thumbnail({required this.url});

  @override
  Widget build(BuildContext context) {
    const placeholder = ColoredBox(
      color: Color(0xFFDDE1E6),
      child: Center(
        child: Icon(Icons.person, size: 48, color: Color(0xFFB4BAC2)),
      ),
    );

    if (url.isEmpty) return placeholder;

    return Image.network(
      url,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const ColoredBox(
          color: Color(0xFFE6E9ED),
          child: Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => placeholder,
    );
  }
}

class _ViewerBadge extends StatelessWidget {
  final int count;

  const _ViewerBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.remove_red_eye, size: 10, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            formatCompactCount(count),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  final String name;
  final String flag;
  final String avatarUrl;
  final bool isFollowed;
  final VoidCallback? onFollowTap;

  const _Footer({
    required this.name,
    required this.flag,
    required this.avatarUrl,
    required this.isFollowed,
    this.onFollowTap,
  });

  @override
  Widget build(BuildContext context) {
    // Name spans the full width (above the avatar) so it isn't squeezed by the
    // avatar + follow button, which lets "Sofia Chen" show in full.
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  shadows: [Shadow(blurRadius: 4, color: Color(0x99000000))],
                ),
              ),
              const SizedBox(height: 5),
              // scaleDown keeps the avatar + flag from ever overflowing a very
              // narrow card.
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _Avatar(url: avatarUrl, size: 24),
                    const SizedBox(width: 6),
                    Text(flag, style: const TextStyle(fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        // Cap the button width so it can never crowd out the name; it sizes to
        // "+ Follow" on normal screens.
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 92),
          child: _FollowButton(isFollowed: isFollowed, onTap: onFollowTap),
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  final String url;
  final double size;

  const _Avatar({required this.url, this.size = 30});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.12),
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: url.isEmpty
          ? null
          : Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const SizedBox(),
            ),
    );
  }
}

class _FollowButton extends StatelessWidget {
  final bool isFollowed;
  final VoidCallback? onTap;

  const _FollowButton({required this.isFollowed, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(
          color: isFollowed ? Colors.white : AppColors.follow,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          isFollowed ? 'Following' : '+ Follow',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
