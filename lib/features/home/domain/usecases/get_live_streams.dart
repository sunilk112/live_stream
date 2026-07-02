import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/live_stream_entity.dart';
import '../repositories/home_repository.dart';

/// Use case: fetch the list of live streams. Encapsulates a single unit of
/// business logic and delegates to the repository abstraction.
class GetLiveStreams implements UseCase<List<LiveStreamEntity>, NoParams> {
  final HomeRepository repository;

  GetLiveStreams(this.repository);

  @override
  Future<Either<Failure, List<LiveStreamEntity>>> call(NoParams params) {
    return repository.getLiveStreams();
  }
}
