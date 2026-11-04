class UserAccount {
  const UserAccount({
    required this.id,
    required this.fullName,
    required this.email,
    required this.createdAt,
  });

  final int id;
  final String fullName;
  final String email;
  final DateTime createdAt;

  factory UserAccount.fromMap(Map<String, Object?> map) {
    return UserAccount(
      id: map['id'] as int,
      fullName: map['full_name'] as String,
      email: map['email'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
