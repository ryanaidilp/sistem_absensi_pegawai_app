import 'package:spo_balaesang/utils/app_const.dart';

class Holiday {
  const Holiday({this.date, this.name, this.description});

  final DateTime date;
  final String name;
  final String description;

  factory Holiday.fromJson(Map<String, dynamic> json) => Holiday(
      date: json == null
          ? DateTime.now()
          : DateTime.parse(json[HOLIDAY_DATE_FIELD].toString()),
      name: json[HOLIDAY_NAME_FIELD] as String,
      description: json[HOLIDAY_DESCRIPTION_FIELD] as String);
}
