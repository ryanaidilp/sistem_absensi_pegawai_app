import 'package:spo_balaesang/models/presence.dart';

class Employee {
  const Employee(
      {this.nip,
      this.name,
      this.phone,
      this.gender,
      this.department,
      this.status,
      this.position,
      this.presences});

  final String nip;
  final String name;
  final String phone;
  final String gender;
  final String department;
  final String status;
  final String position;
  final List<Presence> presences;

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
        nip: json['nip'] as String,
        name: json['name'] as String,
        phone: json['phone'] as String,
        gender: json['gender'] as String,
        department: json['department'] as String,
        status: json['status'] as String,
        position: json['position'] as String,
        presences: json['presence'] != null
            ? (json['presence'] as List<dynamic>)
                .map((json) => Presence.fromJson(json))
                .toList()
            : null);
  }
}
