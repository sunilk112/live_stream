import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/live_stream_entity.dart';

/// DOMAIN-layer contract. The presentation layer depends on this abstraction,
/// never on the concrete data implementation (Dependency Inversion).
abstract class HomeRepository {
  Future<Either<Failure, List<LiveStreamEntity>>> getLiveStreams();
}
