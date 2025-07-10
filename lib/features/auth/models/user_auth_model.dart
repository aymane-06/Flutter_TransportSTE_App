import 'package:equatable/equatable.dart';

class UserAuthModel extends Equatable {
  final String email;
  final String password;

  const UserAuthModel({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];

  factory UserAuthModel.fromJson(Map<String, dynamic> json) {
    return UserAuthModel(
      email: json['email'] as String,
      password: json['password'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }

  UserAuthModel copyWith({
    String? email,
    String? password,
  }) {
    return UserAuthModel(
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }
}
