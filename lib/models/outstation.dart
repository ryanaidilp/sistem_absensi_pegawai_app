import 'package:spo_balaesang/models/user.dart';

class Outstation {
  const Outstation(
      {this.id,
      this.title,
      this.description,
      this.isApproved,
      this.photo,
      this.dueDate,
      this.startDate,
      this.user});

  final int id;
  final String title;
  final String description;
  final bool isApproved;
  final String photo;
  final DateTime dueDate;
  final DateTime startDate;
  final User user;

  factory Outstation.fromJson(Map<String, dynamic> json) {
    return Outstation(
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
