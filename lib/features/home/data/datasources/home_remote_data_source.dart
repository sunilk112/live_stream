import '../../../../core/error/exceptions.dart';
import '../models/live_stream_model.dart';

/// Contract for the remote source of live streams.
abstract class HomeRemoteDataSource {
  Future<List<LiveStreamModel>> getLiveStreams();
}

/// Concrete implementation.
///
/// Currently returns mock data so the app runs end-to-end out of the box.
/// The thumbnails use the free Picsum placeholder service (seeded so each card
/// stays stable). Replace with real stream thumbnails from your API — inject
/// [DioClient] and swap the body of [getLiveStreams]:
///
/// ```dart
/// final res = await client.get<List<dynamic>>('/streams');
/// return res.data!.map((e) => LiveStreamModel.fromJson(e)).toList();
/// ```
class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  // final DioClient client;
  // HomeRemoteDataSourceImpl(this.client);

  @override
  Future<List<LiveStreamModel>> getLiveStreams() async {
    try {
      // Simulate network latency.
      await Future.delayed(const Duration(milliseconds: 600));

      return List.generate(8, (i) {
        return LiveStreamModel.fromJson({
          'id': '${i + 1}',
          'title': 'Live now',
          'host_name': 'Sofia Chen',
          'thumbnail_url': 'https://picsum.photos/seed/alive$i/400/560',
          'avatar_url': '', // design shows an empty avatar ring; supply a URL to fill it
          'viewer_count': 8200,
          'country_flag': '🇵🇭',
          'is_live': true,
          'is_followed': false,
        });
      });
    } catch (_) {
      throw const ServerException('Failed to load live streams.');
    }
  }
}
