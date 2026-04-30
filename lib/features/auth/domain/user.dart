class User {
  final String id;
  final String authId;
  final String fullName;
  final bool isActive;

  User({
    required this.id,
    required this.authId,
    required this.fullName,
    required this.isActive,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    authId: json['authId'],
    fullName: json['fullName'],
    isActive: json['isActive'],
  );
}
