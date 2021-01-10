import 'package:spo_balaesang/models/user.dart';
import 'package:spo_balaesang/utils/app_const.dart';

class PaidLeave {
  const PaidLeave(
      {this.title,
      this.id,
      this.category,
      this.photo,
      this.description,
      this.startDate,
      this.dueDate,
      this.isApproved,
      this.user});

  final int id;
  final String title;
  final String category;
  final String description;
  final bool isApproved;
  final DateTime startDate;
  final DateTime dueDate;
  final String photo;
  final User user;

  factory PaidLeave.fromJson(Map<String, dynamic> json) => PaidLeave(
      id: json[PAID_LEAVE_ID_FIELD] as int,
      title: json[PAID_LEAVE_TITLE_FIELD] as String,
      category: json[PAID_LEAVE_CATEGORY_FIELD] as String,
      description: json[PAID_LEAVE_DESCRIPTION_FIELD] as String,
      isApproved: json[PAID_LEAVE_IS_APPROVED_FIELD] as bool,
      startDate: DateTime.parse(json[PAID_LEAVE_START_DATE_FIELD]),
      dueDate: DateTime.parse(json[PAID_LEAVE_DUE_DATE_FIELD]),
      photo: json[PAID_LEAVE_PHOTO_FIELD] as String,
      user: json[PAID_LEAVE_USER_FIELD] != null
          ? User.fromJson(json[PAID_LEAVE_USER_FIELD])
          : null);
}
