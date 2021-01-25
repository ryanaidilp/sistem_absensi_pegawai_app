import 'package:spo_balaesang/models/user.dart';
import 'package:spo_balaesang/utils/app_const.dart';

class AbsentPermission {
  const AbsentPermission(
      {this.id,
      this.title,
      this.dueDate,
      this.startDate,
      this.description,
      this.photo,
      this.approvalStatus,
      this.isApproved,
      this.user});

  final int id;
  final String title;
  final String description;
  final bool isApproved;
  final String photo;
  final String approvalStatus;
  final DateTime dueDate;
  final DateTime startDate;
  final User user;

  factory AbsentPermission.fromJson(Map<String, dynamic> json) {
    return AbsentPermission(
        id: json[ABSENT_PERMISSION_ID_FIELD] as int,
        title: json[ABSENT_PERMISSION_TITLE_FIELD] as String,
        description: json[ABSENT_PERMISSION_DESCRIPTION_FIELD] as String,
        isApproved: json[ABSENT_PERMISSION_IS_APPROVED_FIELD] as bool,
        photo: json[ABSENT_PERMISSION_PHOTO_FIELD] as String,
        approvalStatus: json[APPROVAL_STATUS_FIELD] as String,
        dueDate: DateTime.parse(json[ABSENT_PERMISSION_DUE_DATE_FIELD]),
        startDate: DateTime.parse(json[ABSENT_PERMISSION_START_DATE_FIELD]),
        user: json[ABSENT_PERMISSION_USER_FIELD] != null
            ? User.fromJson(json[ABSENT_PERMISSION_USER_FIELD])
            : null);
  }
}
