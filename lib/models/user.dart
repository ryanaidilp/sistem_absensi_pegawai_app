import 'package:spo_balaesang/models/holiday.dart';
import 'package:spo_balaesang/models/presence.dart';
import 'package:spo_balaesang/utils/app_const.dart';

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
      this.isWeekend,
      this.rank,
      this.group});

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
  final Holiday holiday;
  final bool isWeekend;
  final String rank;
  final String group;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        id: json[userIdField] as int,
        nip: json[userNipField] as String,
        name: json[userNameField] as String,
        phone: json[userPhoneField] as String,
        gender: json[userGenderField] as String,
        department: json[userDepartmentField] as String,
        status: json[userStatusField] as String,
        position: json[userPositionField] as String,
        unreadNotification: json[userUnreadNotificationsCountField] as int,
        holiday: json[userIsHolidayField] == null
            ? null
            : Holiday.fromJson(
                json[userIsHolidayField] as Map<String, dynamic>),
        isWeekend: json[userIsWeekendField] as bool,
        token: json[userTokenField] as String,
        nextPresence: json[userNextPresenceField] != null
            ? Presence.fromJson(json[userNextPresenceField][jsonDataField]
                as Map<String, dynamic>)
            : null,
        presences: ((json[userPresencesField] != null) &&
                (json[userPresencesField] as List<dynamic>).isNotEmpty)
            ? (json[userPresencesField] as List<dynamic>)
                .map((json) => Presence.fromJson(json as Map<String, dynamic>))
                .toList()
            : [],
        rank: json[userRankField] as String,
        group: json[userGroupField] as String);
  }
}
