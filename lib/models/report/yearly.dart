import 'package:spo_balaesang/utils/app_const.dart';

class Yearly {
  const Yearly({
    this.attendancePercentage,
    this.outstation,
    this.absent,
    this.lateCount,
    this.absentPermission,
    this.leaveEarlyCount,
    this.earlyLunchBreakCount,
    this.notComeAfterLunchBreakCount,
    this.notMorningParadeCount,
    this.annualLeave,
    this.importantReasonLeave,
    this.sickLeave,
    this.maternityLeave,
    this.outOfLiabilityLeave,
  });

  final double attendancePercentage;
  final int lateCount;
  final int leaveEarlyCount;
  final int notMorningParadeCount;
  final int earlyLunchBreakCount;
  final int notComeAfterLunchBreakCount;
  final Map<String, dynamic> absentPermission;
  final Map<String, dynamic> outstation;
  final Map<String, dynamic> absent;
  final Map<String, dynamic> annualLeave;
  final Map<String, dynamic> importantReasonLeave;
  final Map<String, dynamic> sickLeave;
  final Map<String, dynamic> maternityLeave;
  final Map<String, dynamic> outOfLiabilityLeave;

  factory Yearly.fromJson(Map<String, dynamic> json) {
    return Yearly(
        lateCount: json[reportLateCountField] as int,
        attendancePercentage:
            double.parse(json[reportAttendancePercentageFieldField].toString()),
        absent: json[yearlyAbsentField] as Map<String, dynamic>,
        absentPermission:
            json[yearlyAbsentPermissionField] as Map<String, dynamic>,
        outstation: json[yearlyOutstationField] as Map<String, dynamic>,
        leaveEarlyCount: json[reportLeaveEarlyFieldCountField] as int,
        notMorningParadeCount: json[reportNotMorningParadeCountField] as int,
        earlyLunchBreakCount: json[reportEarlyLunchBreakCountField] as int,
        notComeAfterLunchBreakCount:
            json[reportNotComeAfterLunchBreakCountField] as int,
        annualLeave: json[reportAnnualLeaveField] as Map<String, dynamic>,
        importantReasonLeave:
            json[reportImportantReasonLeaveField] as Map<String, dynamic>,
        sickLeave: json[reportSickLeaveField] as Map<String, dynamic>,
        maternityLeave: json[reportMaternityLeaveField] as Map<String, dynamic>,
        outOfLiabilityLeave:
            json[reportOutOfLiabilityLeaveField] as Map<String, dynamic>);
  }
}
