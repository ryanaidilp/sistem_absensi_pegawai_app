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
        id: json[absentPermissionIdField] as int,
        title: json[absentPermissionTitleField] as String,
        description: json[absentPermissionDescriptionField] as String,
        isApproved: json[absentPermissionIsApprovedField] as bool,
        photo: json[absentPermissionPhotoField] as String,
        approvalStatus: json[approvalStatusField] as String,
        dueDate: DateTime.parse(json[absentPermissionDueDateField].toString()),
        startDate:
            DateTime.parse(json[absentPermissionStartDateField].toString()),
        user: json[absentPermissionUserField] != null
            ? User.fromJson(
                json[absentPermissionUserField] as Map<String, dynamic>)
            : null);
  }
}
