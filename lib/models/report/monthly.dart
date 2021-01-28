import 'package:spo_balaesang/utils/app_const.dart';

class Monthly {
  const Monthly(
      {this.lateCount,
      this.attendancePercentage,
      this.leaveEarlyCount,
      this.notMorningParadeCount,
      this.earlyLunchBreakCount,
      this.notComeAfterLunchBreakCount});

  final double attendancePercentage;
  final int lateCount;
  final int leaveEarlyCount;
  final int notMorningParadeCount;
  final int earlyLunchBreakCount;
  final int notComeAfterLunchBreakCount;

  factory Monthly.fromJson(Map<String, dynamic> json) => Monthly(
      attendancePercentage:
          double.parse(json[reportAttendancePercentageFieldField].toString()),
      lateCount: json[reportLateCountField] as int,
      leaveEarlyCount: json[reportLeaveEarlyFieldCountField] as int,
      notMorningParadeCount: json[reportNotMorningParadeCountField] as int,
      earlyLunchBreakCount: json[reportEarlyLunchBreakCountField] as int,
      notComeAfterLunchBreakCount:
          json[reportNotComeAfterLunchBreakCountField] as int);
}
