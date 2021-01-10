import 'package:spo_balaesang/utils/app_const.dart';

class Daily {
  const Daily({this.date, this.attendancePercentage, this.attendances});

  final DateTime date;
  final double attendancePercentage;
  final List<DailyData> attendances;

  factory Daily.fromJson(Map<String, dynamic> json) {
    List<dynamic> _presences = json[DAILY_PRESENCES_FIELD] as List<dynamic>;

    return Daily(
      date: DateTime.parse(json[DAILY_DATE_FIELD].toString()),
      attendancePercentage:
          double.parse(json[REPORT_ATTENDANCE_PERCENTAGE_FIELD].toString()),
      attendances: _presences.map((json) => DailyData.fromJson(json)).toList(),
    );
  }
}

class DailyData {
  const DailyData(
      {this.attendType,
      this.attendTime,
      this.attendStatus,
      this.startTime,
      this.address,
      this.photo});

  final String attendType;
  final String attendTime;
  final String attendStatus;
  final DateTime startTime;
  final String address;
  final String photo;

  factory DailyData.fromJson(Map<String, dynamic> json) => DailyData(
      attendTime: json[DAILY_DATA_ATTEND_TIME_FIELD],
      attendType: json[DAILY_DATA_ATTEND_TYPE_FIELD],
      attendStatus: json[DAILY_DATA_ATTEND_STATUS_FIELD],
      startTime: DateTime.parse(json[PRESENCE_START_TIME_FIELD]),
      address: json[LOCATION_ADDRESS_FIELD] as String,
      photo: json[PRESENCE_PHOTO_FIELD] as String);

  Map<String, dynamic> toMap() => <String, dynamic>{
        DAILY_DATA_ATTEND_TYPE_FIELD: this.attendType,
        DAILY_DATA_ATTEND_TIME_FIELD: this.attendTime,
        DAILY_DATA_ATTEND_STATUS_FIELD: this.attendStatus,
        PRESENCE_START_TIME_FIELD: this.startTime.toString(),
        LOCATION_ADDRESS_FIELD: this.address,
        PRESENCE_PHOTO_FIELD: this.photo
      };
}
