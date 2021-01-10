import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
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
        AutoSizeText(
          "NIP             : ${this.employees[index].nip}",
          maxFontSize: 12.0,
          minFontSize: 10.0,
        ),
        SizedBox(height: 2.0),
        AutoSizeText(
          "Pangkat     : ${this.employees[index].rank}",
          maxFontSize: 12.0,
          minFontSize: 10.0,
        ),
        SizedBox(height: 2.0),
        AutoSizeText(
          "Golongan   : ${this.employees[index].group}",
          maxFontSize: 12.0,
          minFontSize: 10.0,
        ),
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
              var duration = calculateLateInMinutes(
                  presence.startTime, presence.attendTime);
              status =
                  '${presence.status} $duration (${formatPercentage(checkPresencePercentage(presence.status))})';
            }
            ListTile(
              dense: true,
              title: Text(presence.codeType),
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
        padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: ListView.builder(
          itemBuilder: (_, index) => Container(
            margin: EdgeInsets.symmetric(vertical: 4.0),
            child: Card(
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
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              AutoSizeText(
                                "Status        : ${this.employees[index].status}",
                                maxFontSize: 12.0,
                                minFontSize: 10.0,
                              ),
                              SizedBox(height: 2.0),
                              AutoSizeText(
                                "Jabatan     : ${this.employees[index].position}",
                                maxFontSize: 12.0,
                                minFontSize: 10.0,
                              ),
                              SizedBox(height: 2.0),
                              AutoSizeText(
                                "Bagian       : ${this.employees[index].department}",
                                maxFontSize: 12.0,
                                minFontSize: 10.0,
                              ),
                              SizedBox(height: 2.0),
                              _buildPnsInfoSection(index)
                            ],
                          ),
                        ),
                        SizedBox(
                          width: Get.width * 0.15,
                          child: RaisedButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            textColor: Colors.white,
                            color: Colors.blueAccent,
                            onPressed: () {
                              launch('tel:${this.employees[index].phone}');
                            },
                            child: Icon(
                              Icons.phone,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
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
