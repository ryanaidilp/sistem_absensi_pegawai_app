import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:spo_balaesang/models/employee.dart';
import 'package:spo_balaesang/utils/app_const.dart';
import 'package:spo_balaesang/utils/view_util.dart';
import 'package:url_launcher/url_launcher.dart';

class EmployeeListScreen extends StatelessWidget {
  const EmployeeListScreen({this.employees});

  final List<Employee> employees;

  Widget _buildPnsInfoSection(int index) {
    if (employees[index].status == 'Honorer') {
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
            Text(employees[index].group ?? '')
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
            Text(employees[index].rank ?? '')
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
            Text(employees[index].nip ?? '')
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
        Row(
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
        ),
        sizedBoxH4,
        Column(
          children: employees[index].presences.map((presence) {
            String status =
                '${presence.status} (${formatPercentage(checkPresencePercentage(presence.status))})';
            if (presence.status == 'Terlambat') {
              final duration =
                  calculateLateTime(presence.startTime, presence.attendTime);
              status =
                  '${presence.status} $duration (${formatPercentage(checkPresencePercentage(presence.status))})';
            }
            return ListTile(
              dense: true,
              title: Text(
                presence.codeType,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                status,
                style: TextStyle(color: checkStatusColor(presence.status)),
              ),
              trailing:
                  Text(presence.attendTime.isEmpty ? '-' : presence.attendTime),
            );
          }).toList(),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text('Pegawai'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 8, right: 8),
        child: ListView.builder(
          itemBuilder: (_, index) => Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 3.0,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      employees[index].name,
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
                            Text(employees[index].position)
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
                            Text(employees[index].department)
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
                            Text(employees[index].status)
                          ],
                        ),
                        sizedBoxH2,
                        _buildPnsInfoSection(index)
                      ],
                    ),
                    dividerT1,
                    Center(
                      child: Wrap(
                        spacing: 8.0,
                        children: <Widget>[
                          IconButton(
                            onPressed: () {
                              launch(
                                  'tel:${trimPhoneNumber(employees[index].phone)}');
                            },
                            color: Colors.blueAccent,
                            icon: const Icon(Icons.phone),
                            tooltip: 'Hubungi via Telpon',
                          ),
                          IconButton(
                            onPressed: () async {
                              final whatsappUrl =
                                  "whatsapp://send?phone=${trimPhoneNumber(employees[index].phone)}";
                              await canLaunch(whatsappUrl)
                                  ? launch(whatsappUrl)
                                  : Get.defaultDialog(
                                      title: 'Gagal',
                                      content: const Text(
                                          'WhatsApp tidak ditemukan!'),
                                    );
                            },
                            color: Colors.green[600],
                            icon: const FaIcon(FontAwesomeIcons.whatsapp),
                            tooltip: 'Hubungi via WA',
                          ),
                          IconButton(
                            onPressed: () async {
                              final smsUrl =
                                  "smsto:${trimPhoneNumber(employees[index].phone)}";
                              await canLaunch(smsUrl)
                                  ? launch(smsUrl)
                                  : Get.defaultDialog(
                                      title: 'Gagal',
                                      content: const Text(
                                          'Aplikasi SMS tidak ditemukan!'),
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
          ),
          itemCount: employees.length,
        ),
      ),
    );
  }
}
