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
      header: Text('${suffix[0].toUpperCase()}${suffix.substring(1)}'),
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
            style: const TextStyle(
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
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 24.0,
                ),
              ),
              const Text(
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
            style: const TextStyle(color: Colors.grey, fontSize: 12.0),
          )
        ],
      ),
      footer: Text(
        header.toUpperCase(),
        style: const TextStyle(
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
            sizedBoxW2,
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16.0,
              ),
            ),
          ],
        ),
        sizedBoxH6,
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
        sizedBoxH6,
        Row(
          children: <Widget>[sizedBoxW2, footer],
        )
      ],
    );
  }

  Widget _buildPaidLeaveSection() {
    if (status == 'Honorer') {
      return sizedBox;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Divider(color: Colors.black26),
        Text(
          'Cuti',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16.0,
            color: Colors.grey[600],
          ),
        ),
        sizedBoxH4,
        _buildLinearPercentage(
          double.parse(report
              .yearly.outOfLiabilityLeave[absentReportPercentageField]
              .toString()),
          'Diluar Tanggungan',
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: <Widget>[
              sizedBoxW6,
              Text(
                report.yearly.outOfLiabilityLeave[reportDayField].toString(),
                style: TextStyle(
                  color: Colors.grey[800],
                ),
              ),
              Text(
                '/${report.yearly.outOfLiabilityLeave[reportLimitField]} hari',
                style: const TextStyle(color: Colors.grey, fontSize: 12.0),
              )
            ],
          ),
          Colors.red[800],
          Get.width * 0.85,
        ),
        sizedBoxH20,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _buildLinearPercentage(
                double.parse(report
                    .yearly.annualLeave[absentReportPercentageField]
                    .toString()),
                'Tahunan',
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: <Widget>[
                    Text(
                      report.yearly.annualLeave[reportDayField].toString(),
                      style: TextStyle(
                        color: Colors.grey[800],
                      ),
                    ),
                    Text(
                      '/${report.yearly.annualLeave[reportLimitField]} hari',
                      style:
                          const TextStyle(color: Colors.grey, fontSize: 12.0),
                    )
                  ],
                ),
                Colors.indigo[300],
                Get.width * 0.4),
            _buildLinearPercentage(
                double.parse(report
                    .yearly.importantReasonLeave[absentReportPercentageField]
                    .toString()),
                'Alasan Penting',
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: <Widget>[
                    Text(
                      report.yearly.importantReasonLeave[reportDayField]
                          .toString(),
                      style: TextStyle(
                        color: Colors.grey[800],
                      ),
                    ),
                    Text(
                      '/${report.yearly.importantReasonLeave[reportLimitField]} hari',
                      style:
                          const TextStyle(color: Colors.grey, fontSize: 12.0),
                    )
                  ],
                ),
                Colors.pink[400],
                Get.width * 0.4),
          ],
        ),
        sizedBoxH20,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _buildLinearPercentage(
                double.parse(report
                    .yearly.sickLeave[absentReportPercentageField]
                    .toString()),
                'Sakit',
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: <Widget>[
                    Text(
                      report.yearly.sickLeave[reportDayField].toString(),
                      style: TextStyle(
                        color: Colors.grey[800],
                      ),
                    ),
                    Text(
                      '/${report.yearly.sickLeave[reportLimitField]} hari',
                      style:
                          const TextStyle(color: Colors.grey, fontSize: 12.0),
                    )
                  ],
                ),
                Colors.green[300],
                Get.width * 0.4),
            _buildLinearPercentage(
                double.parse(report
                    .yearly.maternityLeave[absentReportPercentageField]
                    .toString()),
                'Bersalin',
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: <Widget>[
                    Text(
                      report.yearly.maternityLeave[reportDayField].toString(),
                      style: TextStyle(
                        color: Colors.grey[800],
                      ),
                    ),
                    Text(
                      '/${report.yearly.maternityLeave[reportLimitField]} hari',
                      style:
                          const TextStyle(color: Colors.grey, fontSize: 12.0),
                    )
                  ],
                ),
                Colors.orange[300],
                Get.width * 0.4),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // ignore: sized_box_for_whitespace
    return Container(
      width: Get.width,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 2.0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Statistik',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Divider(color: Colors.black38),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  _buildCircularPercentage(
                    report.monthly.attendancePercentage,
                    DateFormat.MMMM('id_ID').format(year),
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
              const Divider(color: Colors.black26),
              _buildLinearPercentage(
                double.parse(report.yearly.absent[absentReportPercentageField]
                    .toString()),
                'Alpa',
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: <Widget>[
                    sizedBoxW6,
                    Text(
                      report.yearly.absent[reportDayField].toString(),
                      style: TextStyle(
                        color: Colors.grey[800],
                      ),
                    ),
                    Text(
                      '/${report.yearly.absent[reportLimitField]} hari',
                      style:
                          const TextStyle(color: Colors.grey, fontSize: 12.0),
                    )
                  ],
                ),
                Colors.red[800],
                Get.width * 0.85,
              ),
              sizedBoxH20,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  _buildLinearPercentage(
                      double.parse(report
                          .yearly.absentPermission[absentReportPercentageField]
                          .toString()),
                      'Izin',
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: <Widget>[
                          Text(
                            report.yearly.absentPermission[reportDayField]
                                .toString(),
                            style: TextStyle(
                              color: Colors.grey[800],
                            ),
                          ),
                          Text(
                            '/${report.totalWorkDay} hari kerja',
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 12.0),
                          )
                        ],
                      ),
                      Colors.blueAccent[400],
                      Get.width * 0.4),
                  _buildLinearPercentage(
                      double.parse(report
                          .yearly.outstation[absentReportPercentageField]
                          .toString()),
                      'Dinas Luar',
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: <Widget>[
                          Text(
                            report.yearly.outstation[reportDayField].toString(),
                            style: TextStyle(
                              color: Colors.grey[800],
                            ),
                          ),
                          Text(
                            '/${report.totalWorkDay} hari kerja',
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 12.0),
                          )
                        ],
                      ),
                      Colors.deepOrange[600],
                      Get.width * 0.4),
                ],
              ),
              _buildPaidLeaveSection(),
              sizedBoxH6,
              const Divider(color: Colors.black26),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text(
                    'Tidak Apel Pagi',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.0,
                    ),
                  ),
                  sizedBoxH8,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: <Widget>[
                          Text(
                            report.monthly.notMorningParadeCount.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 32.0,
                            ),
                          ),
                          const Text(
                            ' kali/bulan',
                            style:
                                TextStyle(color: Colors.grey, fontSize: 12.0),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40.0, child: verticalDiv),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: <Widget>[
                          Text(
                            report.yearly.notMorningParadeCount.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 32.0,
                            ),
                          ),
                          const Text(
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
              sizedBoxH6,
              const Divider(color: Colors.black26),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text(
                    'Terlambat',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.0,
                    ),
                  ),
                  sizedBoxH8,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: <Widget>[
                          Text(
                            report.monthly.lateCount.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 32.0,
                            ),
                          ),
                          const Text(
                            ' kali/bulan',
                            style:
                                TextStyle(color: Colors.grey, fontSize: 12.0),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40.0, child: verticalDiv),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: <Widget>[
                          Text(
                            report.yearly.lateCount.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 32.0,
                            ),
                          ),
                          const Text(
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
              sizedBoxH6,
              const Divider(color: Colors.black26),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text(
                    'Istrahat Sebelum Waktunya',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.0,
                    ),
                  ),
                  sizedBoxH8,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: <Widget>[
                          Text(
                            report.monthly.earlyLunchBreakCount.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 32.0,
                            ),
                          ),
                          const Text(
                            ' kali/bulan',
                            style:
                                TextStyle(color: Colors.grey, fontSize: 12.0),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40.0, child: verticalDiv),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: <Widget>[
                          Text(
                            report.yearly.earlyLunchBreakCount.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 32.0,
                            ),
                          ),
                          const Text(
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
              sizedBoxH6,
              const Divider(color: Colors.black26),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text(
                    'Tidak Masuk Siang',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.0,
                    ),
                  ),
                  sizedBoxH8,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: <Widget>[
                          Text(
                            report.monthly.notComeAfterLunchBreakCount
                                .toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 32.0,
                            ),
                          ),
                          const Text(
                            ' kali/bulan',
                            style:
                                TextStyle(color: Colors.grey, fontSize: 12.0),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40.0, child: verticalDiv),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: <Widget>[
                          Text(
                            report.yearly.notComeAfterLunchBreakCount
                                .toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 32.0,
                            ),
                          ),
                          const Text(
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
              sizedBoxH6,
              const Divider(color: Colors.black26),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text(
                    'Pulang Cepat',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.0,
                    ),
                  ),
                  sizedBoxH8,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: <Widget>[
                          Text(
                            report.monthly.leaveEarlyCount.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 32.0,
                            ),
                          ),
                          const Text(
                            ' kali/bulan',
                            style:
                                TextStyle(color: Colors.grey, fontSize: 12.0),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40.0, child: verticalDiv),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: <Widget>[
                          Text(
                            report.yearly.leaveEarlyCount.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 32.0,
                            ),
                          ),
                          const Text(
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
