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
        id: json[NOTIFICATION_ID_FIELD] as String,
        notifiableId: json[NOTIFICATION_NOTIFIABLE_ID_FIELD] as int,
        notifiableType: json[NOTIFICATION_NOTIFIABLE_TYPE_FIELD] as String,
        data: json[JSON_DATA_FIELD] as Map<String, dynamic>,
        isRead: json[NOTIFICATION_IS_READ_FIELD] as bool);
  }
}
