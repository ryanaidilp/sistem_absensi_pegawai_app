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
        id: json[USER_ID_FIELD] as int,
        nip: json[USER_NIP_FIELD] as String,
        name: json[USER_NAME_FIELD] as String,
        phone: json[USER_PHONE_FIELD] as String,
        gender: json[USER_GENDER_FIELD] as String,
        department: json[USER_DEPARTMENT_FIELD] as String,
        status: json[USER_STATUS_FIELD] as String,
        position: json[USER_POSITION_FIELD] as String,
        unreadNotification: json[USER_UNREAD_NOTIFICATION_COUNT_FIELD] as int,
        holiday: json[USER_HOLIDAY_FIELD] as Map<String, dynamic>,
        isWeekend: json[USER_IS_WEEKEND_FIELD] as bool,
        token: json[USER_TOKEN_FIELD] as String,
        nextPresence: json[USER_NEXT_PRESENCE_FIELD] != null
            ? Presence.fromJson(json[USER_NEXT_PRESENCE_FIELD][JSON_DATA_FIELD]
                as Map<String, dynamic>)
            : null,
        presences: ((json[USER_PRESENCES_FIELD] != null) &&
                (json[USER_PRESENCES_FIELD] as List<dynamic>).isNotEmpty)
            ? (json[USER_PRESENCES_FIELD] as List<dynamic>)
                .map((json) => Presence.fromJson(json))
                .toList()
            : []);
  }
}
