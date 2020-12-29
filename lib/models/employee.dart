import 'package:spo_balaesang/models/presence.dart';
import 'package:spo_balaesang/utils/app_const.dart';

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
        nip: json[USER_NIP_FIELD] as String,
        name: json[USER_NAME_FIELD] as String,
        phone: json[USER_PHONE_FIELD] as String,
        gender: json[USER_GENDER_FIELD] as String,
        department: json[USER_DEPARTMENT_FIELD] as String,
        status: json[USER_STATUS_FIELD] as String,
        position: json[USER_POSITION_FIELD] as String,
        presences: json[USER_PRESENCES_FIELD] != null
            ? (json[USER_PRESENCES_FIELD] as List<dynamic>)
                .map((json) => Presence.fromJson(json))
                .toList()
            : null);
  }
}
