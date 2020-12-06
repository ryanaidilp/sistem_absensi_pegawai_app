import 'package:spo_balaesang/models/user.dart';

class AbsentPermission {
  const AbsentPermission(
      {this.id,
      this.title,
      this.dueDate,
      this.startDate,
      this.description,
      this.photo,
      this.isApproved,
      this.user});

  final int id;
  final String title;
  final String description;
  final bool isApproved;
  final String photo;
  final DateTime dueDate;
  final DateTime startDate;
  final User user;

  factory AbsentPermission.fromJson(Map<String, dynamic> json) {
    return AbsentPermission(
        id: json['id'] as int,
        title: json['title'] as String,
        description: json['description'] as String,
        isApproved: json['is_approved'] as bool,
        photo: json['photo'] as String,
        dueDate: DateTime.parse(json['due_date']),
        startDate: DateTime.parse(json['start_date']),
        user: json['user'] != null ? User.fromJson(json['user']) : null);
  }
}
