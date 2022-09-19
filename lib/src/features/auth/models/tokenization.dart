import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class Tokenization {
  final String accessToken;
  final String refreshToken;
  Tokenization({
    required this.accessToken,
    required this.refreshToken,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'access_token': accessToken,
      'refresh_token': refreshToken,
    };
  }

  factory Tokenization.fromMap(Map<String, dynamic> map) {
    return Tokenization(
      accessToken: map['access_token'] as String,
      refreshToken: map['refresh_token'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Tokenization.fromJson(String source) =>
      Tokenization.fromMap(json.decode(source) as Map<String, dynamic>);
}
