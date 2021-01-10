import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spo_balaesang/models/holiday.dart';
import 'package:spo_balaesang/models/report/absent_report.dart';
import 'package:spo_balaesang/models/report/daily.dart';
import 'package:spo_balaesang/models/user.dart';
import 'package:spo_balaesang/repositories/data_repository.dart';
import 'package:spo_balaesang/screen/image_detail_screen.dart';
import 'package:spo_balaesang/utils/app_const.dart';
import 'package:spo_balaesang/utils/view_util.dart';
import 'package:spo_balaesang/widgets/image_error_widget.dart';
import 'package:spo_balaesang/widgets/statistics_card_widget.dart';
import 'package:spo_balaesang/widgets/user_info_card_widgets.dart';
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
  User _user;
  TextEditingController _salaryController = TextEditingController();
  double _salary = 0;

  Future<void> _loadUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    User user = User.fromJson(jsonDecode(prefs.getString(PREFS_USER_KEY)));
    if (user != null) {
      setState(() {
        _user = user;
      });
    }
  }

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
        if (_events.entries.last.key.isAtSameMomentAs(DateTime.now())) {
          _selectedEvents = _events.entries.last.value;
        } else {
          _selectedEvents = [];
        }
        _selectedHolidays = _holidays.entries
            .firstWhere(
                (element) => element.key.isAtSameMomentAs(DateTime.now()))
            .value;
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

      _selectedDate = day;
    });
  }

  Color _checkAttendancePercentageColor(double percentage) {
    if (percentage >= 25 && percentage < 50) {
      return Colors.yellow[800];
    }

    if (percentage >= 50 && percentage < 70) {
      return Colors.indigo;
    }

    if (percentage >= 70 && percentage <= 80) {
      return Colors.blueAccent;
    }
    if (percentage >= 80 && percentage <= 100) {
      return Colors.green[600];
    }
    return Colors.red[800];
  }

  Widget _buildUserInfoSection() {
    return UserInfoCard(user: _user);
  }

  Widget _buildStatisticSection(AbsentReport report, DateTime year) {
    return StatisticCard(
      report: report,
      year: year,
      status: _user?.status,
    );
  }

  Widget _buildSalaryCalculator() {
    if (_user?.status == 'PNS') {
      return SizedBox();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Kalkulator Gaji : ${DateFormat.yMMMM('id_ID').format(_year)}',
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        Divider(),
        Card(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  controller: _salaryController,
                  decoration: InputDecoration(
                    labelStyle: TextStyle(color: Colors.blueAccent),
                    border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blueAccent)),
                    prefixIcon: Icon(
                      Icons.money_rounded,
                      color: Colors.blueAccent,
                    ),
                    labelText: 'Jumlah Gaji Bulanan',
                  ),
                  maxLines: 1,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      setState(() {
                        _salary = double.parse(value);
                      });
                    }
                  },
                ),
                SizedBox(height: 2),
                Divider(color: Colors.black26),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('Kehadiran      : '),
                    Text(
                      '${formatPercentage(_absentReport.monthly.attendancePercentage)}',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    )
                  ],
                ),
                SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('Gaji Bulanan  : '),
                    Text(
                      '${formatCurrency(_salary)}',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    )
                  ],
                ),
                SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('Potongan       : '),
                    Text(
                      formatCurrency(_countSalaryCuts()),
                      style: TextStyle(fontWeight: FontWeight.w600),
                    )
                  ],
                ),
                SizedBox(height: 6),
                Divider(color: Colors.black26),
                SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('Total               : '),
                    Text(
                      formatCurrency(_countTotalSalary()),
                      style: TextStyle(fontWeight: FontWeight.w600),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
        Divider(),
        SizedBox(height: 10.0),
      ],
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
              height: 200,
              child: const FlareActor(
                'assets/flare/failure.flr',
                animation: 'failure',
                fit: BoxFit.cover,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildStatisticSection(_absentReport, _year),
        Divider(),
        SizedBox(height: 10.0),
        _buildSalaryCalculator(),
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
        AnimatedSwitcher(
            duration: Duration(milliseconds: 300), child: _buildEventList())
      ],
    );
  }

  double _countTotalSalary() {
    return _salary * _absentReport.monthly.attendancePercentage / 100;
  }

  double _countSalaryCuts() {
    return _salary - _countTotalSalary();
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
        case 'Cuti Tahunan':
          sum += 25;
          break;
        case 'Cuti Alasan Penting':
        case 'Cuti Sakit':
        case 'Cuti Bersalin':
          sum += 24.375;
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

  Widget _showImage(DailyData presence) {
    if (presence.photo.isEmpty) {
      return Image.asset(
        'assets/images/upload_placeholder.png',
      );
    }

    return InkWell(
      onTap: () {
        Get.to(ImageDetailScreen(
          tag: presence.photo,
          imageUrl: presence.photo,
        ));
      },
      child: Hero(
        tag: presence.photo,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: CachedNetworkImage(
            placeholder: (_, __) => Container(
              child: Stack(
                children: <Widget>[
                  Image.asset('assets/images/upload_placeholder.png'),
                  Center(
                    child: SizedBox(
                      child: SpinKitFadingGrid(
                        size: 25,
                        color: Colors.blueAccent,
                      ),
                      width: 25.0,
                      height: 25.0,
                    ),
                  ),
                ],
              ),
            ),
            imageUrl: presence.photo,
            fit: BoxFit.cover,
            errorWidget: (_, __, ___) => ImageErrorWidget(),
            width: Get.width,
            height: 250.0,
          ),
        ),
      ),
    );
  }

  Widget _buildTableCalendar() {
    return Card(
      child: TableCalendar(
        startingDayOfWeek: StartingDayOfWeek.monday,
        calendarController: _calendarController,
        availableCalendarFormats: <CalendarFormat, String>{
          CalendarFormat.month: '1 minggu',
          CalendarFormat.twoWeeks: '1 bulan',
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
            ? _checkAttendancePercentageColor(
                _countAttendancePercentage(events))
            : _calendarController.isToday(date)
                ? _calendarController.isSelected(date)
                    ? _checkAttendancePercentageColor(
                        _countAttendancePercentage(events))
                    : Colors.white
                : Colors.white,
      ),
      child: Center(
        child: Text(
          '${formatPercentage(_countAttendancePercentage(events).toPrecision(0))}',
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
      children: _selectedEvents.map((event) {
        String status =
            '${event.attendStatus} (${formatPercentage(checkPresencePercentage(event.attendStatus))})';
        if (event.attendStatus == 'Terlambat') {
          var duration =
              calculateLateInMinutes(event.startTime, event.attendTime);
          status =
              '${event.attendStatus} $duration (${formatPercentage(checkPresencePercentage(event.attendStatus))})';
        }
        Color color = checkStatusColor(event.attendStatus);
        final TextStyle labelTextStyle = TextStyle(color: Colors.grey[600]);
        return Container(
          margin: const EdgeInsets.only(bottom: 24.0),
          width: Get.width,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    event.attendType,
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Divider(thickness: 1.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Jam Absen',
                        style: labelTextStyle,
                      ),
                      Text(
                        event.attendTime.isEmpty ? '-' : event.attendTime,
                      )
                    ],
                  ),
                  SizedBox(height: 4.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Poin Kehadiran',
                        style: labelTextStyle,
                      ),
                      Text(
                        '${formatPercentage(checkPresencePercentage(event.attendStatus))}',
                        style: TextStyle(
                          color: color,
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 4.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Status Kehadiran',
                        style: labelTextStyle,
                      ),
                      Text(
                        status,
                        style: TextStyle(
                          color: color,
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 4.0),
                  Divider(thickness: 1),
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.location_on,
                        color: Colors.grey[600],
                        size: 20.0,
                      ),
                      SizedBox(width: 4.0),
                      Text('Lokasi', style: labelTextStyle)
                    ],
                  ),
                  SizedBox(height: 4.0),
                  AutoSizeText(
                    event.address.isEmpty ? '-' : event.address,
                    maxLines: 3,
                    minFontSize: 10.0,
                    maxFontSize: 12.0,
                    textAlign: TextAlign.justify,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Divider(thickness: 1),
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.photo,
                        color: Colors.grey[600],
                        size: 20.0,
                      ),
                      SizedBox(width: 4.0),
                      Text('Foto Wajah', style: labelTextStyle)
                    ],
                  ),
                  SizedBox(height: 4.0),
                  _showImage(event),
                  SizedBox(height: 8.0),
                ],
              ),
            ),
          ),
        );
      }).toList(),
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
    _loadUser();
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
              _buildUserInfoSection(),
              Divider(thickness: 1.0),
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
