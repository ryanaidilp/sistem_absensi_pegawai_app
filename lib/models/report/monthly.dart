import 'package:spo_balaesang/utils/app_const.dart';

class Monthly {
  const Monthly(
      {this.lateCount,
      this.attendancePercentage,
      this.leaveEarlyCount,
      this.notMorningParadeCount});

  final double attendancePercentage;
  final int lateCount;
  final int leaveEarlyCount;
  final int notMorningParadeCount;

  factory Monthly.fromJson(Map<String, dynamic> json) => Monthly(
      attendancePercentage:
          double.parse(json[REPORT_ATTENDANCE_PERCENTAGE_FIELD].toString()),
      lateCount: json[REPORT_LATE_COUNT_FIELD] as int,
      leaveEarlyCount: json[REPORT_LEAVE_EARLY_COUNT_FIELD] as int,
      notMorningParadeCount:
          json[REPORT_NOT_MORNING_PARADE_COUNT_FIELD] as int);
}
