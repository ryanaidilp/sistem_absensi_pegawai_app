import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:spo_balaesang/models/holiday.dart';
import 'package:spo_balaesang/models/report/absent_report.dart';
import 'package:spo_balaesang/models/report/daily.dart';
import 'package:spo_balaesang/repositories/data_repository.dart';
import 'package:spo_balaesang/utils/app_const.dart';
import 'package:spo_balaesang/utils/view_util.dart';
import 'package:table_calendar/table_calendar.dart';

class ReportScreen extends StatefulWidget {
  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  AbsentReport _absentReport;
  bool _isLoading = false;
  DataRepository _dataRepo;
  DateTime _year;
  DateTime _selectedDate = DateTime.now();
  CalendarController _calendarController;
  Map<DateTime, List<dynamic>> _events = new Map();
  List<DailyData> _selectedEvents;
  List<Holiday> _selectedHolidays;
  Map<DateTime, List<dynamic>> _holidays = new Map();

  Future<void> _fetchReportData() async {
    try {
      setState(() {
        _isLoading = true;
      });
      Map<String, dynamic> _result = await _dataRepo.getStatistics(_year);
      AbsentReport absentReport = AbsentReport.fromJson(_result['data']);
      setState(() {
        _absentReport = absentReport;
        _events.addEntries(absentReport.daily
            .map((daily) => MapEntry(daily.date, daily.attendances)));
        _holidays.addEntries(absentReport.holidays
            .map((holiday) => MapEntry(holiday.date, <Holiday>[holiday])));
        _selectedEvents = _events.entries.last.value;
        _selectedHolidays = _holidays.entries.first.value as List<Holiday>;
      });
    } catch (e) {
      print(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onDaySelected(DateTime day, List events, List holidays) {
    setState(() {
      if (events is List<DailyData>)
        _selectedEvents = events;
      else
        _selectedEvents = [];

      if (holidays is List<Holiday>)
        _selectedHolidays = holidays;
      else
        _selectedHolidays = [];

      print(_selectedHolidays);

      _selectedDate = day;
    });
  }

  Color _checkAttendancePercentageColor(double percentage) {
    if (percentage >= 25 && percentage < 50) {
      return Colors.yellow[800];
    }

    if (percentage >= 50 && percentage < 70) {
      return Colors.blueAccent;
    }

    if (percentage >= 70 && percentage <= 80) {
      return Colors.blueAccent;
    }
    if (percentage >= 80 && percentage <= 100) {
      return Colors.green[600];
    }
    return Colors.red[800];
  }

  Widget _buildCircularPercentage(
      double percentage, String header, String suffix, String type) {
    return CircularPercentIndicator(
      radius: Get.width * 0.3,
      linearGradient: LinearGradient(colors: <Color>[
        _checkAttendancePercentageColor(percentage).withOpacity(1),
        _checkAttendancePercentageColor(percentage).withOpacity(0.5)
      ]),
      animation: true,
      percent: percentage / 100,
      lineWidth: 10.0,
      circularStrokeCap: CircularStrokeCap.round,
      backgroundColor:
          _checkAttendancePercentageColor(percentage).withOpacity(0.2),
      center: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            type,
            style: TextStyle(
              fontSize: 10.0,
              color: Colors.black87,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '$percentage',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 24.0,
                ),
              ),
              Text(
                '%',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14.0,
                ),
              )
            ],
          ),
          Text(
            '/$suffix',
            style: TextStyle(color: Colors.grey, fontSize: 12.0),
          )
        ],
      ),
      footer: Text(
        header.toUpperCase(),
        style: TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildLinearPercentage(double percentage, String label, Widget footer,
      Color color, double width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            SizedBox(width: 2.0),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16.0,
              ),
            ),
          ],
        ),
        SizedBox(height: 6.0),
        LinearPercentIndicator(
          progressColor: color,
          percent: percentage / 100,
          width: width,
          animation: true,
          lineHeight: 15.0,
          backgroundColor: color.withOpacity(0.15),
          center: Text(
            '$percentage%',
            style: TextStyle(
                fontSize: 12.0, color: percentageLabelColor(percentage)),
          ),
        ),
        SizedBox(height: 6.0),
        Row(
          children: <Widget>[SizedBox(width: 2.0), footer],
        )
      ],
    );
  }

  Widget _buildStatisticSection() {
    return Container(
      width: Get.width,
      child: Card(
        elevation: 3.0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Statistik',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  _buildCircularPercentage(
                    _absentReport.yearly.attendancePercentage,
                    '${_year.year}',
                    'tahun',
                    'Kehadiran',
                  ),
                  _buildCircularPercentage(
                    _absentReport.monthly.attendancePercentage,
                    '${DateFormat.MMMM('id_ID').format(_year)}',
                    'bulan',
                    'Kehadiran',
                  )
                ],
              ),
              Divider(color: Colors.black26),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Terlambat',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.0,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        children: <Widget>[
                          Text(
                            _absentReport.yearly.lateCount.toString(),
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 32.0,
                            ),
                          ),
                          Text(
                            ' kali/tahun',
                            style:
                                TextStyle(color: Colors.grey, fontSize: 12.0),
                          ),
                        ],
                      ),
                      Text(
                        '|',
                        style: TextStyle(fontSize: 32.0, color: Colors.black54),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        children: <Widget>[
                          Text(
                            _absentReport.monthly.lateCount.toString(),
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 32.0,
                            ),
                          ),
                          Text(
                            ' kali/bulan',
                            style:
                                TextStyle(color: Colors.grey, fontSize: 12.0),
                          ),
                        ],
                      )
                    ],
                  )
                ],
              ),
              SizedBox(height: 6.0),
              Divider(color: Colors.black26),
              SizedBox(height: 8.0),
              _buildLinearPercentage(
                double.parse(_absentReport
                    .yearly.absent[REPORT_PERCENTAGE_FIELD]
                    .toString()),
                'Alpa',
                Row(
                  children: <Widget>[
                    SizedBox(width: 6.0),
                    Text(
                      _absentReport.yearly.absent[REPORT_DAY_FIELD].toString(),
                      style: TextStyle(
                        color: Colors.grey[800],
                      ),
                    ),
                    Text(
                      ' hari',
                      style: TextStyle(color: Colors.grey, fontSize: 12.0),
                    )
                  ],
                ),
                Colors.red[800],
                Get.width * 0.85,
              ),
              SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  _buildLinearPercentage(
                      double.parse(_absentReport
                          .yearly.absentPermission[REPORT_PERCENTAGE_FIELD]
                          .toString()),
                      'Izin',
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        children: <Widget>[
                          Text(
                            _absentReport
                                .yearly.absentPermission[REPORT_DAY_FIELD]
                                .toString(),
                            style: TextStyle(
                              color: Colors.grey[800],
                            ),
                          ),
                          Text(
                            '/12 hari',
                            style:
                                TextStyle(color: Colors.grey, fontSize: 12.0),
                          )
                        ],
                      ),
                      Colors.blueAccent[400],
                      Get.width * 0.4),
                  _buildLinearPercentage(
                      double.parse(_absentReport
                          .yearly.outstation[REPORT_PERCENTAGE_FIELD]
                          .toString()),
                      'Dinas Luar',
                      Row(
                        children: <Widget>[
                          Text(
                            _absentReport.yearly.outstation[REPORT_DAY_FIELD]
                                .toString(),
                            style: TextStyle(
                              color: Colors.grey[800],
                            ),
                          ),
                          Text(
                            ' hari',
                            style:
                                TextStyle(color: Colors.grey, fontSize: 12.0),
                          )
                        ],
                      ),
                      Colors.deepOrange[600],
                      Get.width * 0.4),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Container(
        height: Get.height * 0.7,
        child: Center(
          child: SpinKitFadingCircle(
            size: 45,
            color: Colors.blueAccent,
          ),
        ),
      );
    }
    if (_absentReport == null) {
      return Center(
        child: Column(
          children: <Widget>[
            Container(
              width: Get.width * 0.6,
              height: 300,
              child: const FlareActor('assets/flare/not_found.flr'),
            ),
            const Text('Gagal memuat data'),
            const SizedBox(height: 20.0),
            RaisedButton(
              color: Colors.blueAccent,
              textColor: Colors.white,
              onPressed: _fetchReportData,
              child: Text('Coba Lagi'),
            )
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildStatisticSection(),
        Divider(),
        SizedBox(height: 10.0),
        Text(
          'Kalender Presensi : ',
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 10.0),
        Divider(),
        _buildTableCalendar(),
        Divider(),
        Text(
          'Presensi ${DateFormat.yMMMMEEEEd('id_ID').format(_selectedDate)} : ',
          style: TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 10.0),
        _buildEventList()
      ],
    );
  }

  double _countAttendancePercentage(List<DailyData> presences) {
    double sum = 0;
    if (presences == null) {
      return 0;
    }

    if (presences.isEmpty) {
      return 0;
    }

    presences.forEach((presence) {
      switch (presence.attendStatus) {
        case 'Tepat Waktu':
        case 'Dinas Luar':
          sum += 25;
          break;
        case 'Terlambat':
          sum += 6.25;
          break;
        case 'Izin':
          sum += 12.5;
          break;
        default:
          sum += 0;
          break;
      }
    });

    return sum;
  }

  Widget _buildTableCalendar() {
    return Card(
      child: TableCalendar(
        startingDayOfWeek: StartingDayOfWeek.monday,
        calendarController: _calendarController,
        availableCalendarFormats: <CalendarFormat, String>{
          CalendarFormat.month: 'Satu minggu',
          CalendarFormat.twoWeeks: 'Satu bulan',
          CalendarFormat.week: '2 minggu'
        },
        startDay: DateTime(2021),
        initialCalendarFormat: CalendarFormat.month,
        onDaySelected: _onDaySelected,
        availableGestures: AvailableGestures.horizontalSwipe,
        builders: CalendarBuilders(
          markersBuilder: (context, date, events, holidays) {
            final children = <Widget>[];

            if (events.isNotEmpty) {
              children.add(
                Positioned(
                  bottom: 1,
                  child: _buildEventsMarker(date, events),
                ),
              );
            }

            return children;
          },
        ),
        events: _events,
        holidays: _holidays,
      ),
    );
  }

  Widget _buildEventsMarker(DateTime date, List events) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 32.0,
      height: 16.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        shape: BoxShape.rectangle,
        color: _calendarController.isSelected(date)
            ? Colors.grey[800]
            : _calendarController.isToday(date)
                ? Colors.indigo
                : Colors.white,
      ),
      child: Center(
        child: Text(
          '${NumberFormat.percentPattern('id_ID').format(_countAttendancePercentage(events) / 100)}',
          style: TextStyle(
            color: _calendarController.isSelected(date)
                ? Colors.white
                : _checkAttendancePercentageColor(
                    _countAttendancePercentage(events)),
            fontSize: 10.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildEventList() {
    if (_selectedEvents == null) {
      return Center(
        child: Column(
          children: <Widget>[
            Container(
              width: Get.width * 0.6,
              height: 300,
              child: const FlareActor(
                'assets/flare/not_found.flr',
                animation: 'empty',
              ),
            ),
            const Text('Gagal memuat data'),
            const SizedBox(height: 20.0),
            RaisedButton(
              color: Colors.blueAccent,
              textColor: Colors.white,
              onPressed: _fetchReportData,
              child: Text('Coba Lagi'),
            )
          ],
        ),
      );
    }

    if (_selectedEvents.isEmpty) {
      if (_selectedHolidays != null && _selectedHolidays.isNotEmpty) {
        return Column(
          children: _selectedHolidays
              .map((Holiday holiday) => Card(
                    margin: const EdgeInsets.symmetric(vertical: 6.0),
                    child: ListTile(
                      title: Text(
                        'Libur Nasional : ${holiday.name}',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        holiday.description,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ))
              .toList(),
        );
      }

      return Center(
        child: Column(
          children: <Widget>[
            Container(
              width: Get.width * 0.6,
              height: 300,
              child: const FlareActor(
                'assets/flare/not_found.flr',
                animation: 'empty',
              ),
            ),
            const Text('Tidak ada presensi'),
            const SizedBox(height: 20.0),
          ],
        ),
      );
    }

    return Column(
      children: _selectedEvents
          .map((event) => Card(
                margin: const EdgeInsets.symmetric(vertical: 6.0),
                child: ListTile(
                  title: Row(
                    children: <Widget>[
                      Text(
                        '${event.attendType} : ',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text('${event.attendTime}')
                    ],
                  ),
                  subtitle: Text(
                    event.attendStatus,
                    style:
                        TextStyle(color: checkStatusColor(event.attendStatus)),
                  ),
                ),
              ))
          .toList(),
    );
  }

  @override
  void dispose() {
    if (mounted) {
      _calendarController.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    _year = DateTime.now().year == 2021 ? DateTime.now() : DateTime.utc(2021);
    _dataRepo = Provider.of<DataRepository>(context, listen: false);
    _calendarController = CalendarController();
    super.initState();
    _fetchReportData();
  }

  _selectYear(BuildContext context) async {
    DatePicker.showDatePicker(context,
        initialDateTime: _year,
        minDateTime: DateTime(2021),
        maxDateTime: DateTime(DateTime.now().year + 5), onConfirm: (picked, _) {
      if (picked != null) {
        setState(() {
          _year = picked;
        });
        _fetchReportData();
      }
    }, locale: DateTimePickerLocale.id, dateFormat: 'MMMM-y');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text('Statistik'),
      ),
      body: SingleChildScrollView(
        child: Container(
          width: Get.width,
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Pilih Tahun & Bulan : ',
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    DateFormat.yMMMM('id_ID').format(_year),
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                      icon: Icon(
                        Icons.calendar_today_rounded,
                        color: Colors.blueAccent[400],
                      ),
                      onPressed: () {
                        _selectYear(context);
                      })
                ],
              ),
              Divider(thickness: 1.0),
              _buildBody(),
            ],
          ),
        ),
      ),
    );
  }
}
