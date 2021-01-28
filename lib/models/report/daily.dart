import 'package:spo_balaesang/utils/app_const.dart';

class Daily {
  const Daily({this.date, this.attendancePercentage, this.attendances});

  final DateTime date;
  final double attendancePercentage;
  final List<DailyData> attendances;

  factory Daily.fromJson(Map<String, dynamic> json) {
    final List<dynamic> _presences = json[dailyPresencesField] as List<dynamic>;

    return Daily(
      date: DateTime.parse(json[dailyDateField].toString()),
      attendancePercentage:
          double.parse(json[reportAttendancePercentageFieldField].toString()),
      attendances: _presences
          .map((json) => DailyData.fromJson(json as Map<String, dynamic>))
          .toList(),
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
      attendTime: json[dailyDataAttendTimeField].toString(),
      attendType: json[dailyDataAttendTypeField].toString(),
      attendStatus: json[dailyDataAttendStatusField].toString(),
      startTime: DateTime.parse(json[presenceStartTimeField].toString()),
      address: json[locationAddressField] as String,
      photo: json[presencePhotoField] as String);

  Map<String, dynamic> toMap() => <String, dynamic>{
        dailyDataAttendTypeField: attendType,
        dailyDataAttendTimeField: attendTime,
        dailyDataAttendStatusField: attendStatus,
        presenceStartTimeField: startTime.toString(),
        locationAddressField: address,
        presencePhotoField: photo
      };
}
