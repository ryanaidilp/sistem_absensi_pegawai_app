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
      this.unreadNotification,
      this.token,
      this.nextPresence,
      this.presences,
      this.holiday,
      this.isWeekend});

  final int id;
  final String nip;
  final String name;
  final String phone;
  final String gender;
  final String department;
  final String status;
  final String position;
  final int unreadNotification;
  final String token;
  final Presence nextPresence;
  final List<Presence> presences;
  final Map<String, dynamic> holiday;
  final bool isWeekend;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        id: json['id'] as int,
        nip: json['nip'] as String,
        name: json['name'] as String,
        phone: json['phone'] as String,
        gender: json['gender'] as String,
        department: json['department'] as String,
        status: json['status'] as String,
        position: json['position'] as String,
        unreadNotification: json['unread_notifications'] as int,
        holiday: json['holiday'] as Map<String, dynamic>,
        isWeekend: json['is_weekend'] as bool,
        token: json['token'] as String,
        nextPresence: json['next_presence'] != null
            ? Presence.fromJson(
                json['next_presence']['data'] as Map<String, dynamic>)
            : null,
        presences: ((json['presence'] != null) ||
                (json['presence'] as List<dynamic>).isNotEmpty)
            ? (json['presence'] as List<dynamic>)
                .map((json) => Presence.fromJson(json))
                .toList()
            : []);
  }
}
