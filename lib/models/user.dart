import 'package:spo_balaesang/models/presence.dart';

class User {
  const User(
      {this.id,
      this.nip,
      this.name,
      this.phone,
      this.gender,
      this.department,
      this.status,
      this.position,
      this.token,
      this.nextPresence,
      this.presences});

  final int id;
  final String nip;
  final String name;
  final String phone;
  final String gender;
  final String department;
  final String status;
  final String position;
  final String token;
  final Presence nextPresence;
  final List<Presence> presences;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        id: json['id'] as int,
        nip: json['nip'] as String,
        name: json['name'] as String,
        phone: json['phonr'] as String,
        gender: json['gender'] as String,
        department: json['department'] as String,
        status: json['status'] as String,
        position: json['position'] as String,
        token: json['token'] as String,
        nextPresence: json['next_presence'] != null ? Presence.fromJson(
            json['next_presence']['data'] as Map<String, dynamic>) : null,
        presences: (json['presence'] as List<dynamic>)
            .map((json) => Presence.fromJson(json))
            .toList());
  }
}
