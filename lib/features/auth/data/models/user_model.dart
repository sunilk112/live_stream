import '../../domain/entities/user_entity.dart';

/// DATA-layer model: serialization on top of [UserEntity].
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    super.photoUrl,
    required super.accessToken,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      photoUrl: json['photo_url'] as String? ?? '',
      accessToken: json['access_token'] as String? ?? '',
    );
  }

  /// Builds a model from a Firebase user + Google ID token.
  factory UserModel.fromFirebase({
    required String uid,
    String? name,
    String? email,
    String? photoUrl,
    String? token,
  }) {
    return UserModel(
      id: uid,
      name: name ?? '',
      email: email ?? '',
      photoUrl: photoUrl ?? '',
      accessToken: token ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'photo_url': photoUrl,
      'access_token': accessToken,
    };
  }
}
