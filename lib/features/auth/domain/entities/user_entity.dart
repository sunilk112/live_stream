import 'package:equatable/equatable.dart';

/// Pure domain entity representing an authenticated user.
class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String photoUrl;
  final String accessToken;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl = '',
    required this.accessToken,
  });

  @override
  List<Object?> get props => [id, name, email, photoUrl, accessToken];
}
