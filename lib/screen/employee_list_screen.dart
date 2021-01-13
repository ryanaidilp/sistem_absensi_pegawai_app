import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:spo_balaesang/models/employee.dart';
import 'package:spo_balaesang/utils/view_util.dart';
import 'package:url_launcher/url_launcher.dart';

class EmployeeListScreen extends StatelessWidget {
  const EmployeeListScreen({this.employees, key}) : super(key: key);

  final List<Employee> employees;

  Widget _buildPnsInfoSection(int index) {
    if (this.employees[index].status == 'Honorer') {
      return SizedBox();
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
            Text('${this.employees[index].group}')
          ],
        ),
        SizedBox(height: 2.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              "Pangkat",
              style: labelTextStyle,
            ),
            Text('${this.employees[index].rank}')
          ],
        ),
        SizedBox(height: 2.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              "NIP",
              style: labelTextStyle,
            ),
            Text('${this.employees[index].nip}')
          ],
        ),
        SizedBox(height: 2.0),
      ],
    );
  }

  Widget _buildPresenceSection(int index) {
    if (this.employees[index].presences.isEmpty) {
      return SizedBox();
    }

    return Column(
      children: <Widget>[
        Divider(
          thickness: 1.0,
        ),
        Row(
          children: <Widget>[
            SizedBox(width: 12),
            Text(
              'Kehadiran : ',
              style: TextStyle(color: Colors.blueGrey),
            ),
            Text(
              '${DateFormat("EEEE, d MMMM y").format(DateTime.now())}',
              style: TextStyle(fontSize: 12.0),
            )
          ],
        ),
        const SizedBox(height: 4.0),
        Column(
          children: this.employees[index].presences.map((presence) {
            String status =
                '${presence.status} (${formatPercentage(checkPresencePercentage(presence.status))})';
            if (presence.status == 'Terlambat') {
              var duration =
                  calculateLateTime(presence.startTime, presence.attendTime);
              status =
                  '${presence.status} $duration (${formatPercentage(checkPresencePercentage(presence.status))})';
            }
            return ListTile(
              dense: true,
              title: Text(
                presence.codeType,
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                status,
                style: TextStyle(color: checkStatusColor(presence.status)),
              ),
              trailing: Text(
                  '${presence.attendTime.isEmpty ? '-' : presence.attendTime}'),
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
        title: Text('Pegawai'),
      ),
      body: Padding(
        padding: EdgeInsets.only(bottom: 8, left: 8, right: 8),
        child: ListView.builder(
          itemBuilder: (_, index) => Container(
            margin: EdgeInsets.only(bottom: 16),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 3.0,
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      this.employees[index].name,
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Divider(thickness: 1),
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
                            Text('${this.employees[index].position}')
                          ],
                        ),
                        SizedBox(height: 2.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              "Bagian",
                              style: labelTextStyle,
                            ),
                            Text('${this.employees[index].department}')
                          ],
                        ),
                        SizedBox(height: 2.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              "Status",
                              style: labelTextStyle,
                            ),
                            Text('${this.employees[index].status}')
                          ],
                        ),
                        SizedBox(height: 2.0),
                        _buildPnsInfoSection(index)
                      ],
                    ),
                    Divider(thickness: 1),
                    Center(
                      child: Wrap(
                        spacing: 8.0,
                        children: <Widget>[
                          IconButton(
                            onPressed: () {
                              launch(
                                  'tel:${trimPhoneNumber(this.employees[index].phone)}');
                            },
                            color: Colors.blueAccent,
                            icon: Icon(Icons.phone),
                            enableFeedback: true,
                            tooltip: 'Hubungi via Telpon',
                          ),
                          IconButton(
                            onPressed: () async {
                              var whatsappUrl =
                                  "whatsapp://send?phone=${trimPhoneNumber(this.employees[index].phone)}";
                              await canLaunch(whatsappUrl)
                                  ? launch(whatsappUrl)
                                  : Get.defaultDialog(
                                      title: 'Gagal',
                                      content:
                                          Text('WhatsApp tidak ditemukan!'),
                                    );
                            },
                            color: Colors.green[600],
                            icon: FaIcon(FontAwesomeIcons.whatsapp),
                            enableFeedback: true,
                            tooltip: 'Hubungi via WA',
                          ),
                          IconButton(
                            onPressed: () async {
                              var smsUrl =
                                  "smsto:${trimPhoneNumber(this.employees[index].phone)}";
                              await canLaunch(smsUrl)
                                  ? launch(smsUrl)
                                  : Get.defaultDialog(
                                      title: 'Gagal',
                                      content:
                                          Text('Aplikasi SMS tidak ditemukan!'),
                                    );
                            },
                            color: Colors.red[800],
                            icon: FaIcon(FontAwesomeIcons.mailBulk),
                            enableFeedback: true,
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
          itemCount: this.employees.length,
        ),
      ),
    );
  }
}
