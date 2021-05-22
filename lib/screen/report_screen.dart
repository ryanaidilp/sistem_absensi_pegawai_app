import 'dart:async';
import 'dart:convert';

import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cupertino_datetime_picker/flutter_cupertino_datetime_picker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:spo_balaesang/models/holiday.dart';
import 'package:spo_balaesang/models/presence.dart';
import 'package:spo_balaesang/models/report/absent_report.dart';
import 'package:spo_balaesang/models/report/daily.dart';
import 'package:spo_balaesang/models/user.dart';
import 'package:spo_balaesang/repositories/data_repository.dart';
import 'package:spo_balaesang/utils/app_const.dart';
import 'package:spo_balaesang/utils/extensions.dart';
import 'package:spo_balaesang/utils/view_util.dart';
import 'package:spo_balaesang/widgets/employee_presence_card_widget.dart';
import 'package:spo_balaesang/widgets/statistics_card_widget.dart';
import 'package:spo_balaesang/widgets/user_info_card_widget.dart';
import 'package:table_calendar/table_calendar.dart';

import 'bottom_nav_screen.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({this.user, this.isApproval = false});

  final User user;
  final bool isApproval;

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  AbsentReport _absentReport;
  bool _isLoading = false;
  bool _isApproval;
  DataRepository _dataRepo;
  DateTime _year;
  DateTime _selectedDate = DateTime.now();
  final Map<DateTime, List<dynamic>> _events = {};
  List<DailyData> _selectedEvents;
  List<Holiday> _selectedHolidays;
  final Map<DateTime, List<dynamic>> _holidays = {};
  User _user;
  final TextEditingController _salaryController = TextEditingController();
  double _salary = 0;
  final TextEditingController _reasonController = TextEditingController();

  Future<void> _fetchReportData() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final Map<String, dynamic> _result =
          await _dataRepo.getStatistics(_year, _user.id);
      final AbsentReport absentReport =
          AbsentReport.fromJson(_result['data'] as Map<String, dynamic>);
      setState(() {
        _absentReport = absentReport;
        _events.addEntries(absentReport.daily
            .map((daily) => MapEntry(daily.date, daily.attendances)));
        _holidays.addEntries(absentReport.holidays
            .map((holiday) => MapEntry(holiday.date, <Holiday>[holiday])));
        if (_events.entries.last.key.isSameDate(DateTime.now())) {
          _selectedEvents = _events.entries.last.value as List<DailyData>;
        } else {
          _selectedEvents = [];
        }
        // _selectedHolidays = _getHolidayForDay(DateTime.now()) as List<Holiday>;
      });
    } catch (e) {
      //
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onDaySelected(DateTime day, DateTime focusedDay) {
    final List<dynamic> _eventsData = _getEventsForDay(day);
    final List<dynamic> _holidaysData = _getHolidayForDay(day);
    setState(() {
      if (_eventsData is List<DailyData>) {
        _selectedEvents = _eventsData;
      } else {
        _selectedEvents = [];
      }
      if (_holidaysData is List<Holiday>) {
        _selectedHolidays = _holidaysData;
      } else {
        _selectedHolidays = [];
      }
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
    return UserInfoCardWidget(
      name: _user?.name,
      status: _user?.status,
      group: _user?.group,
      rank: _user?.rank,
      department: _user?.department,
      nip: _user?.nip,
      position: _user?.position,
    );
  }

  Widget _buildStatisticSection(AbsentReport report, DateTime year) {
    return StatisticCard(
      report: report,
      year: year,
      status: _user?.status,
    );
  }

  Widget _buildSalaryCalculator() {
    final String date = DateFormat.yMMMM('id_ID').format(_year);
    String label = 'Kalkulator Gaji : $date';
    String _prefix = 'Gaji';
    if (_user?.status == 'PNS') {
      label = 'Kalkulator Tunjangan : $date';
      _prefix = 'Tunjangan';
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Divider(),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  controller: _salaryController,
                  decoration: InputDecoration(
                    labelStyle: const TextStyle(color: Colors.blueAccent),
                    border: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blueAccent)),
                    prefixIcon: const Icon(
                      Icons.money_rounded,
                      color: Colors.blueAccent,
                    ),
                    labelText: 'Jumlah $_prefix Bulanan',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      setState(() {
                        _salary = double.parse(value);
                      });
                    }
                  },
                ),
                sizedBoxH2,
                const Divider(color: Colors.black26),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Text('Kehadiran      : '),
                    Text(
                      formatPercentage(
                          _absentReport.monthly.attendancePercentage),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    )
                  ],
                ),
                sizedBoxH6,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Text('Gaji Bulanan  : '),
                    Text(
                      formatCurrency(_salary),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    )
                  ],
                ),
                sizedBoxH6,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Text('Potongan       : '),
                    Text(
                      formatCurrency(_countSalaryCuts()),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    )
                  ],
                ),
                sizedBoxH6,
                const Divider(color: Colors.black26),
                sizedBoxH6,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Text('Total               : '),
                    Text(
                      formatCurrency(_countTotalSalary()),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
        const Divider(),
        sizedBoxH10,
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return SizedBox(
        height: Get.height * 0.7,
        child: const Center(
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
            SizedBox(
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
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  primary: Colors.blueAccent,
                  onPrimary: Colors.white),
              onPressed: _fetchReportData,
              child: const Text('Coba Lagi'),
            )
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildStatisticSection(_absentReport, _year),
        const Divider(),
        sizedBoxH10,
        _buildSalaryCalculator(),
        const Text(
          'Kalender Presensi : ',
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        sizedBoxH10,
        const Divider(),
        _buildTableCalendar(),
        const Divider(),
        Text(
          'Presensi ${DateFormat.yMMMMEEEEd('id_ID').format(_selectedDate)} : ',
          style: const TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        sizedBoxH10,
        AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _buildEventList())
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

    // ignore: avoid_function_literals_in_foreach_calls
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

  Widget _buildTableCalendar() {
    return Center(
      child: Card(
        elevation: 2.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        child: SizedBox(
          child: TableCalendar(
            startingDayOfWeek: StartingDayOfWeek.monday,
            availableCalendarFormats: const <CalendarFormat, String>{
              CalendarFormat.month: '1 bulan',
            },
            calendarFormat: CalendarFormat.month,
            firstDay: DateTime(2021),
            lastDay: DateTime(DateTime.now().year + 5),
            focusedDay: _selectedDate,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDate, day);
            },
            headerStyle: const HeaderStyle(titleCentered: true),
            onDaySelected: _onDaySelected,
            availableGestures: AvailableGestures.horizontalSwipe,
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (_, date, focusedDay) {
                return holidayBuilder(date,
                    isNotEmpty: _getHolidayForDay(date).isNotEmpty);
              },
              dowBuilder: dowBuilder,
              markerBuilder: (context, date, events) {
                if (events.isNotEmpty) {
                  return Positioned(
                    bottom: 1,
                    child: _buildEventsMarker(date, events),
                  );
                }

                return const SizedBox();
              },
            ),
            eventLoader: _getEventsForDay,
          ),
        ),
      ),
    );
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    List<dynamic> _event;
    try {
      _event = _events.entries
          .singleWhere((element) => isSameDay(day, element.key))
          .value;
    } catch (e) {
      printError(info: e.toString());
    }
    return _event ?? [];
  }

  List<dynamic> _getHolidayForDay(DateTime day) {
    List<dynamic> _holiday;
    try {
      _holiday = _holidays.entries
          .firstWhere((element) => isSameDay(day, element.key))
          .value;
    } catch (e) {
      printError(info: e.toString());
    }
    return _holiday ?? [];
  }

  Widget _buildEventsMarker(DateTime date, List events) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 32.0,
      height: 16.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: date.isSameDate(_selectedDate)
            ? _checkAttendancePercentageColor(
                _countAttendancePercentage(events as List<DailyData>))
            : date.isToday()
                ? date.isSameDate(_selectedDate)
                    ? _checkAttendancePercentageColor(
                        _countAttendancePercentage(events as List<DailyData>))
                    : Colors.white
                : Colors.white,
      ),
      child: Center(
        child: Text(
          formatPercentage(_countAttendancePercentage(events as List<DailyData>)
              .toPrecision(0)),
          style: TextStyle(
            color: isSameDay(_selectedDate, date)
                ? Colors.white
                : _checkAttendancePercentageColor(
                    _countAttendancePercentage(events as List<DailyData>)),
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
            SizedBox(
              width: Get.width * 0.6,
              height: 300,
              child: const FlareActor(
                'assets/flare/not_found.flr',
                animation: 'empty',
              ),
            ),
            const Text('Gagal memuat data'),
            const SizedBox(height: 20.0),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6)),
                  primary: Colors.blueAccent,
                  onPrimary: Colors.white),
              onPressed: _fetchReportData,
              child: const Text('Coba Lagi'),
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
                        style: const TextStyle(fontWeight: FontWeight.w600),
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
            SizedBox(
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
        final Color color = checkStatusColor(event.attendStatus);
        String status = event.attendStatus ?? '';
        if (event.attendStatus == 'Terlambat') {
          final duration = calculateLateTime(event.startTime, event.attendTime);
          status = '${event.attendStatus} $duration';
        }
        return EmployeePresenceCardWidget(
          isApprovalCard: _isApproval,
          photo: event.photo,
          heroTag: event.photo,
          status: status,
          color: color,
          address: event.address,
          attendTime: event.attendTime,
          point: formatPercentage(checkPresencePercentage(event.attendStatus)),
          presenceType: event.attendType,
          buttonWidget: SizedBox(
            width: Get.width * 0.9,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6)),
                primary: Colors.red[600],
                onPrimary: Colors.white,
              ),
              onPressed: () {
                _cancelAttendance(Presence.fromJson(event.toPresenceJson()));
              },
              child: const Text('Batalkan'),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _cancelAttendance(Presence presence) {
    Get.defaultDialog(
        title: 'Alasan Pembatalan!',
        content: Flexible(
          child: Container(
            padding: const EdgeInsets.all(8),
            width: Get.width * 0.9,
            child: TextFormField(
              controller: _reasonController,
              decoration: const InputDecoration(
                  labelText: 'Alasan',
                  focusColor: Colors.blueAccent,
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blueAccent))),
            ),
          ),
        ),
        confirm: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            primary: Colors.blueAccent,
            onPrimary: Colors.white,
          ),
          onPressed: () {
            Get.back();
            _sendData(presence);
          },
          child: const Text('OK'),
        ));
  }

  @override
  void initState() {
    _year = DateTime.now().year == 2021 ? DateTime.now() : DateTime.utc(2021);
    _dataRepo = Provider.of<DataRepository>(context, listen: false);
    super.initState();
    _user = widget.user;
    _isApproval = widget.isApproval;
    _fetchReportData();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _selectYear(BuildContext context) async {
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

  Future<void> _sendData(Presence presence) async {
    final ProgressDialog pd = ProgressDialog(context, isDismissible: false);
    pd.show();
    try {
      final dataRepo = Provider.of<DataRepository>(context, listen: false);
      final Map<String, dynamic> data = {
        'presence_id': presence.id,
        'reason': _reasonController.value.text
      };
      final http.Response response = await dataRepo.cancelAttendance(data);
      final Map<String, dynamic> _res =
          jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200) {
        pd.hide();
        showAlertDialog("success", "Sukses", _res['message'].toString(),
            dismissible: false);
        Timer(
            const Duration(seconds: 5), () => Get.off(() => BottomNavScreen()));
      } else {
        if (pd.isShowing()) pd.hide();
        showErrorDialog(_res);
      }
    } catch (e) {
      pd.hide();
      showErrorDialog({
        'message': 'Kesalahan',
        'errors': {
          'exception': ['Terjadi kesalahan!']
        }
      });
    }
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
              dividerT1,
              const Text(
                'Pilih Tahun & Bulan : ',
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    DateFormat.yMMMM('id_ID').format(_year),
                    style: const TextStyle(
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
              dividerT1,
              _buildBody(),
            ],
          ),
        ),
      ),
    );
  }
}
