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
        id: json['id'] as String,
        notifiableId: json['notifiable_id'] as int,
        notifiableType: json['notifiable_type'] as String,
        data: json['data'] as Map<String, dynamic>,
        isRead: json['is_read'] as bool);
  }
}
