import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:spo_balaesang/models/report/absent_report.dart';
import 'package:spo_balaesang/utils/app_const.dart';
import 'package:spo_balaesang/utils/view_util.dart';

class StatisticCard extends StatelessWidget {
  const StatisticCard({this.report, this.year, this.status});

  final AbsentReport report;
  final DateTime year;
  final String status;

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

  Widget _buildCircularPercentage(
      double percentage, String header, String suffix, String type) {
    return CircularPercentIndicator(
      radius: Get.width * 0.3,
      linearGradient: LinearGradient(colors: <Color>[
        _checkAttendancePercentageColor(percentage).withOpacity(1),
        _checkAttendancePercentageColor(percentage).withOpacity(0.5)
      ]),
      animation: true,
      animationDuration: 1000,
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
          animationDuration: 1000,
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

  Widget _buildPaidLeaveSection() {
    if (status == 'Honorer') {
      return SizedBox();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Divider(color: Colors.black26),
        Text(
          'Cuti',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16.0,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 4.0),
        _buildLinearPercentage(
          double.parse(report
              .yearly.outOfLiabilityLeave[REPORT_PERCENTAGE_FIELD]
              .toString()),
          'Diluar Tanggungan',
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            children: <Widget>[
              SizedBox(width: 6.0),
              Text(
                report.yearly.outOfLiabilityLeave[REPORT_DAY_FIELD].toString(),
                style: TextStyle(
                  color: Colors.grey[800],
                ),
              ),
              Text(
                '/${report.yearly.outOfLiabilityLeave[REPORT_LIMIT_FIELD]} hari',
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
                double.parse(report.yearly.annualLeave[REPORT_PERCENTAGE_FIELD]
                    .toString()),
                'Tahunan',
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  children: <Widget>[
                    Text(
                      report.yearly.annualLeave[REPORT_DAY_FIELD].toString(),
                      style: TextStyle(
                        color: Colors.grey[800],
                      ),
                    ),
                    Text(
                      '/${report.yearly.annualLeave[REPORT_LIMIT_FIELD]} hari',
                      style: TextStyle(color: Colors.grey, fontSize: 12.0),
                    )
                  ],
                ),
                Colors.indigo[600],
                Get.width * 0.4),
            _buildLinearPercentage(
                double.parse(report
                    .yearly.importantReasonLeave[REPORT_PERCENTAGE_FIELD]
                    .toString()),
                'Alasan Penting',
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  children: <Widget>[
                    Text(
                      report.yearly.importantReasonLeave[REPORT_DAY_FIELD]
                          .toString(),
                      style: TextStyle(
                        color: Colors.grey[800],
                      ),
                    ),
                    Text(
                      '/${report.yearly.importantReasonLeave[REPORT_LIMIT_FIELD]} hari',
                      style: TextStyle(color: Colors.grey, fontSize: 12.0),
                    )
                  ],
                ),
                Colors.pink[400],
                Get.width * 0.4),
          ],
        ),
        SizedBox(height: 20.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _buildLinearPercentage(
                double.parse(report.yearly.sickLeave[REPORT_PERCENTAGE_FIELD]
                    .toString()),
                'Sakit',
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  children: <Widget>[
                    Text(
                      report.yearly.sickLeave[REPORT_DAY_FIELD].toString(),
                      style: TextStyle(
                        color: Colors.grey[800],
                      ),
                    ),
                    Text(
                      '/180 hari',
                      style: TextStyle(color: Colors.grey, fontSize: 12.0),
                    )
                  ],
                ),
                Colors.green[800],
                Get.width * 0.4),
            _buildLinearPercentage(
                double.parse(report
                    .yearly.maternityLeave[REPORT_PERCENTAGE_FIELD]
                    .toString()),
                'Bersalin',
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  children: <Widget>[
                    Text(
                      report.yearly.maternityLeave[REPORT_DAY_FIELD].toString(),
                      style: TextStyle(
                        color: Colors.grey[800],
                      ),
                    ),
                    Text(
                      '/${report.yearly.maternityLeave[REPORT_LIMIT_FIELD]} hari',
                      style: TextStyle(color: Colors.grey, fontSize: 12.0),
                    )
                  ],
                ),
                Colors.lime[600],
                Get.width * 0.4),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width,
      child: Card(
        elevation: 2.0,
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
              Divider(color: Colors.black38),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  _buildCircularPercentage(
                    report.monthly.attendancePercentage,
                    '${DateFormat.MMMM('id_ID').format(year)}',
                    'bulan',
                    'Kehadiran',
                  ),
                  _buildCircularPercentage(
                    report.yearly.attendancePercentage,
                    '${year.year}',
                    'tahun',
                    'Kehadiran',
                  ),
                ],
              ),
              Divider(color: Colors.black26),
              _buildLinearPercentage(
                double.parse(
                    report.yearly.absent[REPORT_PERCENTAGE_FIELD].toString()),
                'Alpa',
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  children: <Widget>[
                    SizedBox(width: 6.0),
                    Text(
                      report.yearly.absent[REPORT_DAY_FIELD].toString(),
                      style: TextStyle(
                        color: Colors.grey[800],
                      ),
                    ),
                    Text(
                      '/${report.yearly.absent[REPORT_LIMIT_FIELD]} hari',
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
                      double.parse(report
                          .yearly.absentPermission[REPORT_PERCENTAGE_FIELD]
                          .toString()),
                      'Izin',
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        children: <Widget>[
                          Text(
                            report.yearly.absentPermission[REPORT_DAY_FIELD]
                                .toString(),
                            style: TextStyle(
                              color: Colors.grey[800],
                            ),
                          ),
                          Text(
                            '/${report.totalWorkDay} hari kerja',
                            style:
                                TextStyle(color: Colors.grey, fontSize: 12.0),
                          )
                        ],
                      ),
                      Colors.blueAccent[400],
                      Get.width * 0.4),
                  _buildLinearPercentage(
                      double.parse(report
                          .yearly.outstation[REPORT_PERCENTAGE_FIELD]
                          .toString()),
                      'Dinas Luar',
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        children: <Widget>[
                          Text(
                            report.yearly.outstation[REPORT_DAY_FIELD]
                                .toString(),
                            style: TextStyle(
                              color: Colors.grey[800],
                            ),
                          ),
                          Text(
                            '/${report.totalWorkDay} hari kerja',
                            style:
                                TextStyle(color: Colors.grey, fontSize: 12.0),
                          )
                        ],
                      ),
                      Colors.deepOrange[600],
                      Get.width * 0.4),
                ],
              ),
              _buildPaidLeaveSection(),
              SizedBox(height: 6.0),
              Divider(color: Colors.black26),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Tidak Apel Pagi',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.0,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        children: <Widget>[
                          Text(
                            report.monthly.notMorningParadeCount.toString(),
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
                      ),
                      Text(
                        '|',
                        style: TextStyle(fontSize: 32.0, color: Colors.black54),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        children: <Widget>[
                          Text(
                            report.yearly.notMorningParadeCount.toString(),
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
                    ],
                  )
                ],
              ),
              SizedBox(height: 6.0),
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
                  SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        children: <Widget>[
                          Text(
                            report.monthly.lateCount.toString(),
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
                      ),
                      Text(
                        '|',
                        style: TextStyle(fontSize: 32.0, color: Colors.black54),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        children: <Widget>[
                          Text(
                            report.yearly.lateCount.toString(),
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
                    ],
                  )
                ],
              ),
              SizedBox(height: 6.0),
              Divider(color: Colors.black26),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Pulang Cepat',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.0,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        children: <Widget>[
                          Text(
                            report.monthly.leaveEarlyCount.toString(),
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
                      ),
                      Text(
                        '|',
                        style: TextStyle(fontSize: 32.0, color: Colors.black54),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        children: <Widget>[
                          Text(
                            report.yearly.leaveEarlyCount.toString(),
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
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
