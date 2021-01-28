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
      this.presences,
      this.rank,
      this.group});

  final String nip;
  final String name;
  final String phone;
  final String gender;
  final String department;
  final String status;
  final String position;
  final String rank;
  final String group;
  final List<Presence> presences;

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
        nip: json[userNipField] as String,
        name: json[userNameField] as String,
        phone: json[userPhoneField] as String,
        gender: json[userGenderField] as String,
        department: json[userDepartmentField] as String,
        rank: json[userRankField] as String,
        group: json[userGroupField] as String,
        status: json[userStatusField] as String,
        position: json[userPositionField] as String,
        presences: json[userPresencesField] != null
            ? (json[userPresencesField] as List<dynamic>)
                .map((json) => Presence.fromJson(json as Map<String, dynamic>))
                .toList()
            : null);
  }
}
