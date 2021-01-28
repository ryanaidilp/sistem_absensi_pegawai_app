import 'package:spo_balaesang/utils/app_const.dart';

class UserNotification {
  const UserNotification(
      {this.id,
      this.notifiableId,
      this.notifiableType,
      this.data,
      this.isRead});

  final String id;
  final int notifiableId;
  final String notifiableType;
  final Map<String, dynamic> data;
  final bool isRead;

  factory UserNotification.fromJson(Map<String, dynamic> json) {
    return UserNotification(
        id: json[notificationIdField] as String,
        notifiableId: json[notificationNotifiableIdField] as int,
        notifiableType: json[notificationNotifiableTypeField] as String,
        data: json[jsonDataField] as Map<String, dynamic>,
        isRead: json[notificationIsReadField] as bool);
  }
}
