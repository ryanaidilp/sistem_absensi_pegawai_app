import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:search_page/search_page.dart';
import 'package:spo_balaesang/models/employee.dart';
import 'package:spo_balaesang/utils/app_const.dart';
import 'package:spo_balaesang/utils/extensions.dart';
import 'package:spo_balaesang/utils/view_util.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:url_launcher/url_launcher.dart';

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({this.employees});

  final List<Employee> employees;

  @override
  State<StatefulWidget> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  List<Employee> employees;
  List<bool> _isExpanded = <bool>[]; // ignore: prefer_final_fields

  @override
  void initState() {
    super.initState();
    employees = widget.employees;
    _isExpanded
        .addAll(List.generate(employees.length, (index) => false).toList());
  }

  Widget _buildPnsInfoSection(Employee employee) {
    if (employee.status == 'Honorer') {
      return sizedBox;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              "Golongan",
              style: labelTextStyle,
            ),
            Text(employee.group ?? '')
          ],
        ),
        sizedBoxH2,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              "Pangkat",
              style: labelTextStyle,
            ),
            Text(employee.rank ?? '')
          ],
        ),
        sizedBoxH2,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              "NIP",
              style: labelTextStyle,
            ),
            Text(employee.nip ?? '')
          ],
        ),
        sizedBoxH2,
      ],
    );
  }

  Widget _buildPresenceSection(int index) {
    if (employees[index].presences.isEmpty) {
      return sizedBox;
    }

    return Column(
      children: <Widget>[
        dividerT1,
        ExpansionPanelList(
          animationDuration: const Duration(milliseconds: 500),
          elevation: 0,
          expandedHeaderPadding: const EdgeInsets.all(1.0),
          expansionCallback: (i, isOpen) =>
              setState(() => {_isExpanded[index] = !isOpen}),
          children: <ExpansionPanel>[
            ExpansionPanel(
                canTapOnHeader: true,
                isExpanded: _isExpanded[index],
                headerBuilder: (_, isOpen) {
                  return Row(
                    children: <Widget>[
                      sizedBoxW12,
                      const Text(
                        'Kehadiran : ',
                        style: TextStyle(color: Colors.blueGrey),
                      ),
                      Text(
                        DateFormat("EEEE, d MMMM y").format(DateTime.now()),
                        style: const TextStyle(fontSize: 12.0),
                      )
                    ],
                  );
                },
                body: Column(
                  children: employees[index].presences.map((presence) {
                    final int _index =
                        employees[index].presences.indexOf(presence);

                    String status = presence.status;

                    if (presence.status == 'Terlambat') {
                      final duration = calculateLateTime(
                          presence.startTime, presence.attendTime);
                      status = '${presence.status} $duration';
                    }

                    final isFirst = _index == 0;

                    final isLast = _index == 3;

                    final isOnGoing = presence.startTime.isOnGoing();

                    final statusColor = isOnGoing
                        ? Colors.grey
                        : checkStatusColor(presence.status);

                    final afterLineColor =
                        isOnGoing ? Colors.grey[300] : statusColor;

                    var beforeLineColor = Colors.grey[300];

                    if (!isFirst) {
                      final _presence = employees[index].presences[_index - 1];
                      beforeLineColor = _presence.startTime.isFinished()
                          ? checkStatusColor(_presence.status)
                          : Colors.grey[300];
                    }

                    final indicatorIcon = _checkIconData(presence.status);

                    return TimelineTile(
                      isFirst: isFirst,
                      isLast: isLast,
                      startChild: Center(
                        child: Text(
                          presence.attendTime.isEmpty
                              ? "--:--:--"
                              : presence.attendTime,
                          style: TextStyle(
                              color: isOnGoing ? Colors.grey : Colors.black),
                        ),
                      ),
                      alignment: TimelineAlign.manual,
                      lineXY: 0.2,
                      endChild: ListTile(
                        dense: true,
                        title: Text(presence.codeType,
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: isOnGoing ? Colors.grey : Colors.black)),
                        subtitle:
                            Text(status, style: TextStyle(color: statusColor)),
                        trailing: Text(
                            formatPercentage(
                                checkPresencePercentage(presence.status)),
                            style: TextStyle(color: statusColor)),
                      ),
                      indicatorStyle: IndicatorStyle(
                        color: afterLineColor,
                        width: isOnGoing ? 20 : 23,
                        iconStyle: IconStyle(
                          color: Colors.white,
                          iconData: indicatorIcon,
                          fontSize: 16,
                        ),
                      ),
                      afterLineStyle: LineStyle(color: afterLineColor),
                      beforeLineStyle: LineStyle(color: beforeLineColor),
                    );
                  }).toList(),
                ))
          ],
        ),
      ],
    );
  }

  IconData _checkIconData(String status) {
    switch (status) {
      case 'Terlambat':
        return Icons.thumb_down;
      case 'Tidak Hadir':
        return Icons.close_rounded;
      case 'Tepat Waktu':
        return Icons.check_rounded;
      default:
        return Icons.calendar_today_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text('Pegawai'),
        actions: [
          IconButton(
              onPressed: () => showSearch(
                  context: context,
                  delegate: SearchPage(
                    searchLabel: 'Cari Pegawai',
                    searchStyle: const TextStyle(color: Colors.white),
                    barTheme: ThemeData(
                      appBarTheme: const AppBarTheme(
                        color: Colors.blueAccent,
                        brightness: Brightness.dark,
                      ),
                    ),
                    showItemsOnEmpty: true,
                    failure: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            width: Get.width * 0.5,
                            height: Get.height * 0.3,
                            child: const FlareActor(
                              'assets/flare/not_found.flr',
                              animation: 'empty',
                            ),
                          ),
                          const Text('Data tidak ditemukan :(')
                        ],
                      ),
                    ),
                    builder: (Employee employee) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: _buildEmployeeCardSection(employee),
                    ),
                    filter: (Employee employee) => [
                      employee.name,
                      employee.status,
                      employee.department,
                      employee.nip,
                    ],
                    items: employees,
                  )),
              icon: const Icon(Icons.search_rounded))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 8, right: 8),
        child: ListView.builder(
          itemBuilder: (_, index) =>
              _buildEmployeeCardSection(employees[index]),
          itemCount: employees.length,
        ),
      ),
    );
  }

  Widget _buildEmployeeCardSection(Employee employee) {
    final int index = employees.indexOf(employee);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 3.0,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                employee.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              dividerT1,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        "Jabatan",
                        style: labelTextStyle,
                      ),
                      Text(employee.position)
                    ],
                  ),
                  sizedBoxH2,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        "Bagian",
                        style: labelTextStyle,
                      ),
                      Text(employee.department)
                    ],
                  ),
                  sizedBoxH2,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        "Status",
                        style: labelTextStyle,
                      ),
                      Text(employee.status)
                    ],
                  ),
                  sizedBoxH2,
                  _buildPnsInfoSection(employee)
                ],
              ),
              dividerT1,
              Center(
                child: Wrap(
                  spacing: 8.0,
                  children: <Widget>[
                    IconButton(
                      onPressed: () {
                        launch('tel:${trimPhoneNumber(employee.phone)}');
                      },
                      color: Colors.blueAccent,
                      icon: const Icon(Icons.phone),
                      tooltip: 'Hubungi via Telpon',
                    ),
                    IconButton(
                      onPressed: () async {
                        final whatsappUrl =
                            "whatsapp://send?phone=${trimPhoneNumber(employee.phone)}";
                        await canLaunch(whatsappUrl)
                            ? launch(whatsappUrl)
                            : Get.defaultDialog(
                                title: 'Gagal',
                                content:
                                    const Text('WhatsApp tidak ditemukan!'),
                              );
                      },
                      color: Colors.green[600],
                      icon: const FaIcon(FontAwesomeIcons.whatsapp),
                      tooltip: 'Hubungi via WA',
                    ),
                    IconButton(
                      onPressed: () async {
                        final smsUrl =
                            "smsto:${trimPhoneNumber(employee.phone)}";
                        await canLaunch(smsUrl)
                            ? launch(smsUrl)
                            : Get.defaultDialog(
                                title: 'Gagal',
                                content:
                                    const Text('Aplikasi SMS tidak ditemukan!'),
                              );
                      },
                      color: Colors.red[800],
                      icon: const FaIcon(FontAwesomeIcons.mailBulk),
                      tooltip: 'Hubungi via SMS',
                    ),
                  ],
                ),
              ),
              _buildPresenceSection(index)
            ],
          ),
        ),
      ),
    );
  }
}
