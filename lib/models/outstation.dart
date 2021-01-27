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
        id: json[outstationIdField] as int,
        title: json[outstationTitleField] as String,
        description: json[outstationDescriptionField] as String,
        isApproved: json[outstationIsApprovedField] as bool,
        photo: json[outstationPhotoField] as String,
        approvalStatus: json[approvalStatusField] as String,
        dueDate: DateTime.parse(json[outstationDueDateField].toString()),
        startDate: DateTime.parse(json[outstationStartDateField].toString()),
        user: json[outstationUserField] != null
            ? User.fromJson(json[outstationUserField] as Map<String, dynamic>)
            : null);
  }
}
