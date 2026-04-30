class Role {
  final String id;
  final String name;

  Role({required this.id, required this.name});

  factory Role.fromJson(Map<String, dynamic> json) =>
      Role(id: json['id'], name: json['name']);
}
