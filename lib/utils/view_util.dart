import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:introduction_screen/introduction_screen.dart';

import 'extensions.dart';

Future showAlertDialog(String type, String title, String content,
    {bool dismissible}) async {
  final List<Widget> actions = type == 'success'
      ? []
      : [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text(
              'OK',
              style: TextStyle(
                color: Colors.blueAccent,
              ),
            ),
          )
        ];
  final color = type == 'success' ? Colors.green : Colors.red;
  final icon = type == 'success' ? Icons.check_circle : Icons.dangerous;
  return Get.defaultDialog(
      title: title,
      content: Column(
        children: <Widget>[
          Icon(
            icon,
            color: color,
            size: 72,
          ),
          const SizedBox(height: 10.0),
          Center(
              child: Text(
            content,
            textAlign: TextAlign.center,
          )),
        ],
      ),
      actions: actions,
      barrierDismissible: dismissible);
}

Future showErrorDialog(Map<String, dynamic> json) {
  return Get.defaultDialog(
    title: 'Gagal',
    content: Column(
      children: <Widget>[
        const Icon(
          Icons.dangerous,
          color: Colors.red,
          size: 72.0,
        ),
        const SizedBox(height: 10.0),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              json['message'].toString(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10.0),
            Column(
                children: (json['errors'] as Map<String, dynamic>)
                    .entries
                    .map((e) => Text(e.value[0].toString()))
                    .toList()),
          ],
        ),
      ],
    ),
    cancel: TextButton(
      onPressed: () {
        Get.back();
      },
      child: const Text(
        'OK',
        style: TextStyle(
          color: Colors.blueAccent,
        ),
      ),
    ),
  );
}

Color percentageLabelColor(double percentage) {
  if (percentage < 50) {
    return Colors.black87;
  }
  return Colors.white;
}

Color checkStatusColor(String status) {
  switch (status) {
    case 'Tidak Hadir':
      return Colors.red[800];
    case 'Tepat Waktu':
      return Colors.green;
    case 'Terlambat':
      return Colors.orange;
    case 'Dinas Luar':
    case 'Izin':
      return Colors.blueAccent;
    case 'Cuti Tahunan':
    case 'Cuti Bersalin':
    case 'Cuti Sakit':
    case 'Cuti Alasan Penting':
      return Colors.pink;
    default:
      return Colors.red[800];
  }
}

double checkPresencePercentage(String status) {
  switch (status) {
    case 'Tepat Waktu':
    case 'Dinas Luar':
    case 'Cuti Tahunan':
      return 100;
    case 'Cuti Bersalin':
    case 'Cuti Sakit':
    case 'Cuti Alasan Penting':
      return 97.5;
    case 'Terlambat':
      return 25;
      break;
    case 'Izin':
      return 50;
    default:
      return 0;
  }
}

List<PageViewModel> onBoardingScreens = [
  PageViewModel(
    title: "QR Code",
    body: "Lakukan presensi cukup dengan scan QR Code",
    image: const Center(
        child: FlareActor(
      'assets/flare/qrcode.flr',
      animation: 'scan',
    )),
    decoration: const PageDecoration(
        titleTextStyle: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.w700,
            color: Colors.blueAccent),
        bodyTextStyle:
            TextStyle(fontSize: 12.0, fontWeight: FontWeight.normal)),
  ),
  PageViewModel(
    title: "Izin, Cuti, & Dinas Luar",
    body: "Ajukan Izin, Cuti, dan Dinas Luar melalui aplikasi.",
    image: const Center(
        child: FlareActor(
      'assets/flare/documents.flr',
      animation: 'document',
    )),
    decoration: const PageDecoration(
        titleTextStyle: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.w700,
            color: Colors.blueAccent),
        bodyTextStyle:
            TextStyle(fontSize: 12.0, fontWeight: FontWeight.normal)),
  )
];

String calculateLateTime(DateTime startTime, String attendTime) {
  const dur = Duration(minutes: 30);
  final attendDate =
      '${startTime.year.toString()}-${startTime.month.toString().padLeft(2, '0')}-${startTime.day.toString().padLeft(2, '0')}';
  final diff =
      DateTime.parse('$attendDate $attendTime').difference(startTime.add(dur));
  var duration = diff.inMinutes;

  if (duration == 0) {
    duration = diff.inSeconds;
    return '$duration detik';
  }

  if (duration > 59) {
    duration = diff.inHours;
    return '$duration jam';
  }

  return '$duration menit';
}

final TextStyle labelTextStyle = TextStyle(color: Colors.grey[600]);

String formatPercentage(double percentage) {
  return '${NumberFormat.decimalPattern('id_ID').format(percentage)}%';
}

String formatCurrency(double salary) {
  return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp. ').format(salary);
}

String trimPhoneNumber(String phoneNumber) {
  final phone = phoneNumber.replaceAll(' ', '');
  return '62${phone.substring(1, phone.length)}';
}

Widget dowBuilder(BuildContext context, DateTime date) {
  TextStyle _style = const TextStyle(color: Colors.black);
  if (date.isWeekend()) {
    _style = const TextStyle(color: Colors.red);
  }
  final text = DateFormat.E().format(date);
  return Center(
    child: Text(
      text,
      style: _style,
    ),
  );
}

Widget holidayBuilder(DateTime date, {bool isNotEmpty}) {
  TextStyle _style = const TextStyle(color: Colors.black);
  if (isNotEmpty || date.isWeekend()) {
    _style = const TextStyle(color: Colors.red);
  }
  final text = DateFormat.d().format(date);
  return Center(
    child: Text(
      text,
      style: _style,
    ),
  );
}
