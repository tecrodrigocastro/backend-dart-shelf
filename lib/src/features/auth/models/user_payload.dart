import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class UserPayload {
  final String role;
  final int id;
  UserPayload({
    required this.role,
    required this.id,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'role': role,
      'id': id,
    };
  }

  factory UserPayload.fromMap(Map<String, dynamic> map) {
    return UserPayload(
      role: map['role'] as String,
      id: map['id'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserPayload.fromJson(String source) =>
      UserPayload.fromMap(json.decode(source) as Map<String, dynamic>);
}
