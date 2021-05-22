import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:spo_balaesang/repositories/data_repository.dart';
import 'package:spo_balaesang/screen/bottom_nav_screen.dart';
import 'package:spo_balaesang/screen/image_detail_screen.dart';
import 'package:spo_balaesang/utils/app_const.dart';
import 'package:spo_balaesang/utils/file_util.dart';
import 'package:spo_balaesang/utils/view_util.dart';
import 'package:spo_balaesang/widgets/image_placeholder_widget.dart';
import 'package:table_calendar/table_calendar.dart';

class CreatePermissionScreen extends StatefulWidget {
  @override
  _CreatePermissionScreenState createState() => _CreatePermissionScreenState();
}

class _CreatePermissionScreenState extends State<CreatePermissionScreen> {
  String _base64Image;
  String _fileName;
  File _tmpFile;
  DateTime _dueDate = DateTime.now();
  DateTime _startDate = DateTime.now();
  bool _isDateChange = false;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  Future<void> _openCamera() async {
    final picture = await ImagePicker().getImage(source: ImageSource.camera);
    final file = await compressAndGetFile(File(picture.path),
        '/storage/emulated/0/Android/data/com.banuacoders.siap/files/Pictures/images.jpg');
    setState(() {
      _tmpFile = file;
      _base64Image = base64Encode(_tmpFile.readAsBytesSync());
      _fileName = _tmpFile.path.split('/').last;
    });
    await file.delete(recursive: true);
  }

  Future<void> _uploadData() async {
    if (!_isDateChange) {
      showAlertDialog('failed', 'Pelanggaran', 'Pilih tanggal terlebih dahulu!',
          dismissible: true);
    } else {
      final ProgressDialog pd = ProgressDialog(context, isDismissible: false);
      try {
        pd.show();
        final dataRepo = Provider.of<DataRepository>(context, listen: false);
        final Map<String, dynamic> data = {
          'title': _titleController.value.text,
          'description': _descriptionController.value.text,
          'photo': _base64Image,
          'due_date': _dueDate.toIso8601String(),
          'start_date': _startDate.toIso8601String(),
          'file_name': _fileName
        };
        final Map<String, dynamic> _res = await dataRepo.permission(data);
        if (_res['success'] as bool) {
          pd.hide();
          showAlertDialog('success', "Sukses", _res['message'].toString(),
              dismissible: false);
          Timer(const Duration(seconds: 5),
              () => Get.off(() => BottomNavScreen()));
        } else {
          if (pd.isShowing()) pd.hide();
          showErrorDialog(_res);
        }
      } catch (e) {
        showErrorDialog({
          'message': 'Kesalahan',
          'errors': {
            'exception': ['Terjadi kesalahan!']
          }
        });
        pd.hide();
      }
    }
  }

  Widget _showImage() {
    if (_base64Image == null) {
      return const ImagePlaceholderWidget(
        label: 'Ambil Foto',
        child: Icon(
          Icons.camera_alt_rounded,
          color: Colors.grey,
        ),
      );
    }

    final Uint8List bytes = base64Decode(_base64Image);
    return InkWell(
      onTap: () {
        Get.to(() => ImageDetailScreen(
              bytes: bytes,
              tag: 'image',
            ));
      },
      child: Hero(
        tag: 'image',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Image.memory(
            bytes,
            width: Get.width,
            height: 250,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Future<void> _selectDueDate() async {
    Get.defaultDialog(
        title: 'Pilih Tanggal Selesai',
        content: SizedBox(
          width: Get.width * 0.9,
          height: Get.height * 0.4,
          child: TableCalendar(
            availableCalendarFormats: const <CalendarFormat, String>{
              CalendarFormat.month: '1 bulan',
            },
            calendarStyle: const CalendarStyle(
              weekendTextStyle: TextStyle(color: Colors.red),
            ),
            calendarBuilders: const CalendarBuilders(
              dowBuilder: dowBuilder,
            ),
            shouldFillViewport: true,
            calendarFormat: CalendarFormat.month,
            availableGestures: AvailableGestures.horizontalSwipe,
            headerStyle: const HeaderStyle(titleCentered: true),
            startingDayOfWeek: StartingDayOfWeek.monday,
            firstDay: DateTime.now().subtract(const Duration(days: 7)),
            focusedDay: _dueDate,
            lastDay: DateTime.now().add(const Duration(days: 180)),
            locale: 'in_ID',
            selectedDayPredicate: (day) {
              return isSameDay(_dueDate, day);
            },
            onDaySelected: (day, focusedDay) {
              Get.back();
              setState(() {
                if (!_isDateChange) {
                  _isDateChange = true;
                }
                _dueDate = day;
                if (_dueDate.isBefore(_startDate)) {
                  _startDate = day;
                }
              });
            },
          ),
        ));
  }

  Future<void> _selectStartDate() async {
    Get.defaultDialog(
        title: 'Pilih Tanggal Mulai',
        content: SizedBox(
          height: Get.height * 0.4,
          width: Get.width * 0.9,
          child: TableCalendar(
            availableCalendarFormats: const <CalendarFormat, String>{
              CalendarFormat.month: '1 bulan',
            },
            calendarStyle: const CalendarStyle(
              weekendTextStyle: TextStyle(color: Colors.red),
            ),
            calendarBuilders: const CalendarBuilders(
              dowBuilder: dowBuilder,
            ),
            shouldFillViewport: true,
            calendarFormat: CalendarFormat.month,
            availableGestures: AvailableGestures.horizontalSwipe,
            headerStyle: const HeaderStyle(titleCentered: true),
            startingDayOfWeek: StartingDayOfWeek.monday,
            firstDay: DateTime.now().subtract(const Duration(days: 7)),
            focusedDay: _startDate,
            lastDay: DateTime.now().add(const Duration(days: 180)),
            locale: 'in_ID',
            selectedDayPredicate: (day) {
              return isSameDay(_startDate, day);
            },
            onDaySelected: (day, focusedDay) {
              Get.back();
              setState(() {
                if (!_isDateChange) {
                  _isDateChange = true;
                }
                _startDate = day;
                if (_startDate.isAfter(_dueDate)) {
                  _dueDate = day;
                }
              });
            },
          ),
        ));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text('Buat Izin'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                  'Pastikan data yang dikirim sudah benar. Anda tidak dapat mengubah dokumen setelah dikirim. Jika terjadi kesalahan, hubungi administrator sistem.'),
              sizedBoxH20,
              Row(
                children: const <Widget>[
                  Text('Judul Surat'),
                  sizedBoxW5,
                  Text(
                    '*',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
              const Text(
                'Mis: Izin Sakit, dsb.',
                style: TextStyle(color: Colors.grey),
              ),
              TextFormField(
                keyboardType: TextInputType.text,
                controller: _titleController,
                decoration: const InputDecoration(
                    alignLabelWithHint: true,
                    hintText: 'Judul',
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blueAccent)),
                    labelStyle: TextStyle(color: Colors.grey)),
              ),
              sizedBoxH20,
              Row(
                children: const <Widget>[
                  Text('Deskripsi'),
                  sizedBoxW5,
                  Text(
                    '*',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
              const Text(
                'Jelaskan secara singkat tentang izin yang diajukan!',
                style: TextStyle(color: Colors.grey),
              ),
              TextFormField(
                keyboardType: TextInputType.multiline,
                minLines: 1,
                maxLines: 5,
                controller: _descriptionController,
                decoration: const InputDecoration(
                    alignLabelWithHint: true,
                    hintText: 'Deskripsi',
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blueAccent)),
                    labelStyle: TextStyle(color: Colors.grey)),
              ),
              sizedBoxH20,
              Row(
                children: const <Widget>[
                  Text('Tanggal Izin'),
                  sizedBoxW5,
                  Text(
                    '*',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
              const Text(
                'Pilih kapan izin mulai berlaku!',
                style: TextStyle(color: Colors.grey),
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      DateFormat('EEEE, d MMMM y').format(_startDate),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  IconButton(
                      icon: const Icon(
                        Icons.calendar_today_rounded,
                        color: Colors.blueAccent,
                      ),
                      onPressed: () {
                        _selectStartDate();
                      })
                ],
              ),
              sizedBoxH20,
              Row(
                children: const <Widget>[
                  Text('Tanggal Kadaluarsa'),
                  sizedBoxW5,
                  Text(
                    '*',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
              const Text(
                'Pilih sampai kapan izin yang diajukan berlaku!',
                style: TextStyle(color: Colors.grey),
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      DateFormat('EEEE, d MMMM y').format(_dueDate),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  IconButton(
                      icon: const Icon(
                        Icons.calendar_today_rounded,
                        color: Colors.blueAccent,
                      ),
                      onPressed: () {
                        _selectDueDate();
                      })
                ],
              ),
              sizedBoxH20,
              Row(
                children: const <Widget>[
                  Text('Foto Surat Izin'),
                  sizedBoxW5,
                  Text(
                    '*',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
              const Text(
                'Lampirkan foto surat izin atau surat lainnya seperti surat keterangan sakit dsb.',
                style: TextStyle(color: Colors.grey),
              ),
              const Text(
                '*tekan untuk memperbesar',
                style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.black87,
                    fontStyle: FontStyle.italic),
              ),
              sizedBoxH20,
              _showImage(),
              sizedBoxH20,
              SizedBox(
                width: Get.width,
                height: 40.0,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
                    primary: Colors.blueAccent,
                    onPrimary: Colors.white,
                  ),
                  onPressed: _openCamera,
                  child:
                      Text(_base64Image == null ? 'Ambil Foto' : 'Ubah Foto'),
                ),
              ),
              sizedBoxH20,
              SizedBox(
                width: Get.width,
                height: 40.0,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
                    primary: Colors.green,
                    onPrimary: Colors.white,
                  ),
                  onPressed: _uploadData,
                  child: const Text('Kirim'),
                ),
              ),
              sizedBoxH20,
            ],
          ),
        ),
      ),
    );
  }
}
