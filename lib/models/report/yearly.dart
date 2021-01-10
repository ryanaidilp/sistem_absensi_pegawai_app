import 'package:spo_balaesang/utils/app_const.dart';

class Yearly {
  const Yearly({
    this.attendancePercentage,
    this.outstation,
    this.absent,
    this.lateCount,
    this.absentPermission,
    this.leaveEarlyCount,
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
        lateCount: json[REPORT_LATE_COUNT_FIELD],
        attendancePercentage:
            double.parse(json[REPORT_ATTENDANCE_PERCENTAGE_FIELD].toString()),
        absent: json[YEARLY_ABSENT_FIELD] as Map<String, dynamic>,
        absentPermission:
            json[YEARLY_ABSENT_PERMISSION_FIELD] as Map<String, dynamic>,
        outstation: json[YEARLY_OUTSTATION_FIELD] as Map<String, dynamic>,
        leaveEarlyCount: json[REPORT_LEAVE_EARLY_COUNT_FIELD] as int,
        notMorningParadeCount:
            json[REPORT_NOT_MORNING_PARADE_COUNT_FIELD] as int,
        annualLeave: json[REPORT_ANNUAL_LEAVE_FIELD] as Map<String, dynamic>,
        importantReasonLeave:
            json[REPORT_IMPORTANT_REASON_LEAVE_FIELD] as Map<String, dynamic>,
        sickLeave: json[REPORT_SICK_LEAVE_FIELD] as Map<String, dynamic>,
        maternityLeave:
            json[REPORT_MATERNITY_LEAVE_FIELD] as Map<String, dynamic>,
        outOfLiabilityLeave:
            json[REPORT_OUT_OF_LIABILITY_LEAVE_FIELD] as Map<String, dynamic>);
  }
}
