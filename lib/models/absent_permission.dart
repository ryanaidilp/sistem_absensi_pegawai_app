class AbsentPermission {
  const AbsentPermission(
      {this.title,
      this.dueDate,
      this.startDate,
      this.description,
      this.photo,
      this.isApproved});

  final String title;
  final String description;
  final bool isApproved;
  final String photo;
  final DateTime dueDate;
  final DateTime startDate;

  factory AbsentPermission.fromJson(Map<String, dynamic> json) {
    return AbsentPermission(
      title: json['title'] as String,
      description: json['description'] as String,
      isApproved: json['is_approved'] as bool,
      photo: json['photo'] as String,
      dueDate: DateTime.parse(json['due_date']),
      startDate: DateTime.parse(json['start_date']),
    );
  }
}
