import 'package:spo_balaesang/utils/app_const.dart';

class Yearly {
  const Yearly({
    this.attendancePercentage,
    this.outstation,
    this.absent,
    this.lateCount,
    this.absentPermission,
  });

  final double attendancePercentage;
  final int lateCount;
  final Map<String, dynamic> absentPermission;
  final Map<String, dynamic> outstation;
  final Map<String, dynamic> absent;

  factory Yearly.fromJson(Map<String, dynamic> json) {
    return Yearly(
        lateCount: json[REPORT_LATE_COUNT_FIELD],
        attendancePercentage:
            double.parse(json[REPORT_ATTENDANCE_PERCENTAGE_FIELD].toString()),
        absent: json[YEARLY_ABSENT_FIELD] as Map<String, dynamic>,
        absentPermission:
            json[YEARLY_ABSENT_PERMISSION_FIELD] as Map<String, dynamic>,
        outstation: json[YEARLY_OUTSTATION_FIELD] as Map<String, dynamic>);
  }
}
