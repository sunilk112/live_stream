import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../error/failures.dart';

/// Base contract for every use case (interactor) in the domain layer.
///
/// [T] is the success result, [P] are the input params. Use cases always
/// return `Either<Failure, T>` — left on error, right on success.
abstract class UseCase<T, P> {
  Future<Either<Failure, T>> call(P params);
}

/// Use this when a use case needs no parameters.
class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}
