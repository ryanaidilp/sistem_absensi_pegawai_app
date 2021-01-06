import 'package:spo_balaesang/models/holiday.dart';
import 'package:spo_balaesang/models/report/daily.dart';
import 'package:spo_balaesang/models/report/monthly.dart';
import 'package:spo_balaesang/models/report/yearly.dart';
import 'package:spo_balaesang/utils/app_const.dart';

class AbsentReport {
  const AbsentReport({this.daily, this.monthly, this.yearly, this.holidays});

  final List<Daily> daily;
  final Monthly monthly;
  final Yearly yearly;
  final List<Holiday> holidays;

  factory AbsentReport.fromJson(Map<String, dynamic> json) => AbsentReport(
      daily: (json[ABSENT_REPORT_DAILY_FIELD] as List<dynamic>)
          .map((item) => Daily.fromJson(item))
          .toList(),
      monthly: Monthly.fromJson(json[ABSENT_REPORT_MONTHLY_FIELD]),
      yearly: Yearly.fromJson(json[ABSENT_REPORT_YEARLY_FIELD]),
      holidays: (json[ABSENT_REPORT_HOLIDAYS_FIELD] as List<dynamic>)
          .map((item) => Holiday.fromJson(item))
          .toList());
}
