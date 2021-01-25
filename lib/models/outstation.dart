import 'package:spo_balaesang/models/user.dart';
import 'package:spo_balaesang/utils/app_const.dart';

class Outstation {
  const Outstation(
      {this.id,
      this.title,
      this.description,
      this.isApproved,
      this.photo,
      this.approvalStatus,
      this.dueDate,
      this.startDate,
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

  factory Outstation.fromJson(Map<String, dynamic> json) {
    return Outstation(
        id: json[OUTSTATION_ID_FIELD] as int,
        title: json[OUTSTATION_TITLE_FIELD] as String,
        description: json[OUTSTATION_DESCRIPTION_FIELD] as String,
        isApproved: json[OUTSTATION_IS_APPROVED_FIELD] as bool,
        photo: json[OUTSTATION_PHOTO_FIELD] as String,
        approvalStatus: json[APPROVAL_STATUS_FIELD] as String,
        dueDate: DateTime.parse(json[OUTSTATION_DUE_DATE_FIELD]),
        startDate: DateTime.parse(json[OUTSTATION_START_DATE_FIELD]),
        user: json[OUTSTATION_USER_FIELD] != null
            ? User.fromJson(json[OUTSTATION_USER_FIELD])
            : null);
  }
}
