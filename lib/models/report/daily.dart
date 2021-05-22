import 'package:spo_balaesang/models/location.dart';
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
      {this.id,
      this.date,
      this.location,
      this.attendType,
      this.attendTime,
      this.attendStatus,
      this.startTime,
      this.endTime,
      this.address,
      this.photo});

  final int id;
  final String date;
  final Location location;
  final String attendType;
  final String attendTime;
  final String attendStatus;
  final DateTime startTime;
  final DateTime endTime;
  final String address;
  final String photo;

  factory DailyData.fromJson(Map<String, dynamic> json) => DailyData(
      id: json[userIdField] as int,
      date: json[presenceDateField].toString(),
      location: Location.fromJson(
          json[presenceLocationField] as Map<String, dynamic>),
      attendTime: json[dailyDataAttendTimeField].toString(),
      attendType: json[dailyDataAttendTypeField].toString(),
      attendStatus: json[dailyDataAttendStatusField].toString(),
      startTime: DateTime.parse(json[presenceStartTimeField].toString()),
      endTime: DateTime.parse(json[presenceEndTimeField].toString()),
      address: json[locationAddressField] as String,
      photo: json[presencePhotoField] as String);

  Map<String, dynamic> toMap() => <String, dynamic>{
        userIdField: id,
        dailyDataAttendTypeField: attendType,
        dailyDataAttendTimeField: attendTime,
        dailyDataAttendStatusField: attendStatus,
        presenceStartTimeField: startTime.toString(),
        locationAddressField: address,
        presencePhotoField: photo
      };

  Map<String, dynamic> toPresenceJson() => <String, dynamic>{
        userIdField: id,
        presenceDateField: date,
        presenceLocationField: location.toJson(),
        presenceCodeTypeField: attendType,
        presenceStatusField: attendStatus,
        presenceAttendTimeField: attendTime,
        presenceStartTimeField: startTime.toString(),
        presenceEndTimeField: endTime.toString(),
        presencePhotoField: photo
      };
}
