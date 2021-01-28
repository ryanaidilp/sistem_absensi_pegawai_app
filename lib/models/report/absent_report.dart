import 'package:spo_balaesang/models/holiday.dart';
import 'package:spo_balaesang/models/report/daily.dart';
import 'package:spo_balaesang/models/report/monthly.dart';
import 'package:spo_balaesang/models/report/yearly.dart';
import 'package:spo_balaesang/utils/app_const.dart';

class AbsentReport {
  const AbsentReport(
      {this.daily,
      this.monthly,
      this.yearly,
      this.holidays,
      this.totalWorkDay});

  final List<Daily> daily;
  final Monthly monthly;
  final Yearly yearly;
  final List<Holiday> holidays;
  final int totalWorkDay;

  factory AbsentReport.fromJson(Map<String, dynamic> json) => AbsentReport(
      daily: (json[absentReportDailyField] as List<dynamic>)
          .map((item) => Daily.fromJson(item as Map<String, dynamic>))
          .toList(),
      monthly: Monthly.fromJson(
          json[absentReportMonthlyField] as Map<String, dynamic>),
      yearly: Yearly.fromJson(
          json[absentReportYearlyField] as Map<String, dynamic>),
      holidays: (json[absentReportHolidaysField] as List<dynamic>)
          .map((item) => Holiday.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalWorkDay: json[reportTotalWorkDayField] as int);
}
