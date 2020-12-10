import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spo_balaesang/models/employee.dart';
import 'package:url_launcher/url_launcher.dart';

class EmployeeListScreen extends StatelessWidget {
  const EmployeeListScreen({this.employees, key}) : super(key: key);

  final List<Employee> employees;

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
            margin: EdgeInsets.symmetric(vertical: 8.0),
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                this.employees[index].name,
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              SizedBox(height: 2.0),
                              AutoSizeText(
                                "Status    : ${this.employees[index].status}",
                                maxFontSize: 12.0,
                                minFontSize: 10.0,
                                style: TextStyle(color: Colors.grey),
                              ),
                              SizedBox(height: 2.0),
                              AutoSizeText(
                                "NIP         : ${this.employees[index].nip}",
                                maxFontSize: 12.0,
                                minFontSize: 10.0,
                                style: TextStyle(color: Colors.grey),
                              ),
                              SizedBox(height: 2.0),
                              AutoSizeText(
                                "Jabatan : ${this.employees[index].position}",
                                maxFontSize: 12.0,
                                minFontSize: 10.0,
                              ),
                              SizedBox(height: 2.0),
                              AutoSizeText(
                                "Bagian   : ${this.employees[index].department}",
                                maxFontSize: 12.0,
                                minFontSize: 10.0,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.15,
                          child: RaisedButton(
                              color: Colors.blueAccent,
                              onPressed: () {
                                launch('tel:${this.employees[index].phone}');
                              },
                              child: Icon(
                                Icons.phone,
                                color: Colors.white,
                              )),
                        )
                      ],
                    ),
                    Divider(
                      thickness: 1.0,
                    ),
                    Row(
                      children: <Widget>[
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
                      children: this
                          .employees[index]
                          .presences
                          .map((presence) => Column(
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Text(
                                        "${presence.codeType} : ${presence.status}",
                                        style: TextStyle(
                                          fontSize: 12.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4.0)
                                ],
                              ))
                          .toList(),
                    )
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
