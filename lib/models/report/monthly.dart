import 'package:spo_balaesang/utils/app_const.dart';

class Monthly {
  const Monthly({this.lateCount, this.attendancePercentage});

  final double attendancePercentage;
  final int lateCount;

  factory Monthly.fromJson(Map<String, dynamic> json) => Monthly(
      attendancePercentage:
          double.parse(json[REPORT_ATTENDANCE_PERCENTAGE_FIELD].toString()),
      lateCount: json[REPORT_LATE_COUNT_FIELD] as int);
}
