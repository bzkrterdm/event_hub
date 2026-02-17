class User {
  const User({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
  });

  final String id;
  final String name;
  final String email;
  final String? avatarUrl;

  User copyWith({
    String? id,
    String? name,
    String? email,
    Object? avatarUrl = _sentinel,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl == _sentinel ? this.avatarUrl : avatarUrl as String?,
    );
  }

  static const _sentinel = Object();
}
