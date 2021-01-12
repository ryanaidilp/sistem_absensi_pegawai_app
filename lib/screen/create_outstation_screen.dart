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
import 'package:spo_balaesang/utils/file_util.dart';
import 'package:spo_balaesang/utils/view_util.dart';
import 'package:spo_balaesang/widgets/image_placeholder_widget.dart';
import 'package:table_calendar/table_calendar.dart';

class CreateOutstationScreen extends StatefulWidget {
  @override
  _CreateOutstationScreenState createState() => _CreateOutstationScreenState();
}

class _CreateOutstationScreenState extends State<CreateOutstationScreen> {
  String _base64Image;
  String _fileName;
  File _tmpFile;
  DateTime _dueDate = DateTime.now();
  DateTime _startDate = DateTime.now();
  final CalendarController _startDateController = CalendarController();
  final CalendarController _dueDateController = CalendarController();
  bool _isDateChange = false;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  _openCamera() async {
    var picture = await ImagePicker().getImage(source: ImageSource.camera);
    var file = await compressAndGetFile(File(picture.path),
        '/storage/emulated/0/Android/data/com.banuacoders.siap/files/Pictures/images.jpg');
    setState(() {
      _tmpFile = file;
      _base64Image = base64Encode(_tmpFile.readAsBytesSync());
      _fileName = _tmpFile.path.split('/').last;
    });
  }

  Future<void> _uploadData() async {
    if (!_isDateChange) {
      showAlertDialog(
          'failed', 'Pelanggaran', 'Pilih tanggal terlebih dahulu!', true);
    } else {
      ProgressDialog pd = ProgressDialog(context, isDismissible: false);
      try {
        pd.show();
        final dataRepo = Provider.of<DataRepository>(context, listen: false);
        Map<String, dynamic> data = {
          'title': _titleController.value.text,
          'description': _descriptionController.value.text,
          'photo': _base64Image,
          'due_date': _dueDate.toIso8601String(),
          'start_date': _startDate.toIso8601String(),
          'file_name': _fileName
        };
        Map<String, dynamic> _res = await dataRepo.outstation(data);
        if (_res['success']) {
          pd.hide();
          showAlertDialog('success', "Sukses", _res['message'], false);
          Timer(Duration(seconds: 5), () => Get.off(BottomNavScreen()));
        } else {
          if (pd.isShowing()) pd.hide();
          showErrorDialog(_res);
        }
      } catch (e) {
        print(e.toString());
        pd.hide();
      }
    }
  }

  Widget _showImage() {
    if (_base64Image == null) {
      return ImagePlaceholderWidget(
        child: Icon(
          Icons.camera_alt_rounded,
          color: Colors.grey,
        ),
        label: 'Ambil Foto',
      );
    }

    Uint8List bytes = base64Decode(_base64Image);
    return InkWell(
      onTap: () {
        Get.to(ImageDetailScreen(
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

  _selectDueDate() async {
    Get.defaultDialog(
        title: 'Pilih Tanggal Selesai',
        content: Flexible(
          child: Container(
            width: Get.width * 0.9,
            child: TableCalendar(
              availableCalendarFormats: <CalendarFormat, String>{
                CalendarFormat.month: '1 minggu',
                CalendarFormat.twoWeeks: '1 bulan',
                CalendarFormat.week: '2 minggu'
              },
              availableGestures: AvailableGestures.horizontalSwipe,
              headerStyle:
                  HeaderStyle(formatButtonTextStyle: TextStyle(fontSize: 12.0)),
              calendarController: _dueDateController,
              startingDayOfWeek: StartingDayOfWeek.monday,
              startDay: DateTime.now().subtract(Duration(days: 7)),
              endDay: DateTime.now().add(Duration(days: 7)),
              initialSelectedDay: _dueDate,
              locale: 'in_ID',
              initialCalendarFormat: CalendarFormat.month,
              onDaySelected: (day, events, holidays) {
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
          ),
        ));
  }

  _selectStartDate() async {
    Get.defaultDialog(
        title: 'Pilih Tanggal Mulai',
        content: Flexible(
          child: Container(
            width: Get.width * 0.9,
            child: TableCalendar(
              availableCalendarFormats: <CalendarFormat, String>{
                CalendarFormat.month: '1 minggu',
                CalendarFormat.twoWeeks: '1 bulan',
                CalendarFormat.week: '2 minggu'
              },
              availableGestures: AvailableGestures.horizontalSwipe,
              headerStyle:
                  HeaderStyle(formatButtonTextStyle: TextStyle(fontSize: 12.0)),
              calendarController: _startDateController,
              startingDayOfWeek: StartingDayOfWeek.monday,
              startDay: DateTime.now().subtract(Duration(days: 7)),
              initialSelectedDay: _startDate,
              locale: 'in_ID',
              initialCalendarFormat: CalendarFormat.month,
              onDaySelected: (day, events, holidays) {
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
          ),
        ));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _startDateController.dispose();
    _dueDateController.dispose();
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
        title: Text('Ajukan Dinas Luar'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                  'Pastikan data yang dikirim sudah benar. Anda tidak dapat mengubah dokumen setelah dikirim. Jika terjadi kesalahan, hubungi administrator sistem.'),
              SizedBox(height: 20.0),
              Row(
                children: <Widget>[
                  Text('Judul Surat'),
                  SizedBox(width: 5.0),
                  Text(
                    '*',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
              TextFormField(
                keyboardType: TextInputType.text,
                controller: _titleController,
                decoration: InputDecoration(
                    alignLabelWithHint: true,
                    hintText: 'Judul',
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blueAccent)),
                    labelStyle: TextStyle(color: Colors.grey)),
              ),
              SizedBox(height: 20.0),
              Row(
                children: <Widget>[
                  Text('Deskripsi'),
                  SizedBox(width: 5.0),
                  Text(
                    '*',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
              Text(
                'Jelaskan secara singkat tentang Dinas Luar yang diajukan!',
                style: TextStyle(color: Colors.grey),
              ),
              TextFormField(
                keyboardType: TextInputType.multiline,
                minLines: 1,
                maxLines: 5,
                controller: _descriptionController,
                decoration: InputDecoration(
                    alignLabelWithHint: true,
                    hintText: 'Deskripsi',
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blueAccent)),
                    labelStyle: TextStyle(color: Colors.grey)),
              ),
              SizedBox(height: 20.0),
              Row(
                children: <Widget>[
                  Text('Tanggal Mulai'),
                  SizedBox(width: 5.0),
                  Text(
                    '*',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
              Text(
                'Pilih kapan tugas Dinas Luar mulai!',
                style: TextStyle(color: Colors.grey),
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      '${DateFormat('EEEE, d MMMM y').format(
                        _startDate,
                      )}',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  IconButton(
                      icon: Icon(
                        Icons.calendar_today_rounded,
                        color: Colors.blueAccent,
                      ),
                      onPressed: () {
                        _selectStartDate();
                      })
                ],
              ),
              SizedBox(height: 20.0),
              Row(
                children: <Widget>[
                  Text('Tanggal Selesai'),
                  SizedBox(width: 5.0),
                  Text(
                    '*',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
              Text(
                'Pilih sampai kapan Dinas Luar yang diajukan berlaku!',
                style: TextStyle(color: Colors.grey),
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      '${DateFormat('EEEE, d MMMM y').format(
                        _dueDate,
                      )}',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  IconButton(
                      icon: Icon(
                        Icons.calendar_today_rounded,
                        color: Colors.blueAccent,
                      ),
                      onPressed: () {
                        _selectDueDate();
                      })
                ],
              ),
              SizedBox(height: 20.0),
              Row(
                children: <Widget>[
                  Text('Foto Surat Tugas'),
                  SizedBox(width: 5.0),
                  Text(
                    '*',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
              Text(
                'Lampirkan foto surat tugas atau Surat Perintah Perjalanan Dinas (SPPD).',
                style: TextStyle(color: Colors.grey),
              ),
              Text(
                '*tekan untuk memperbesar',
                style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.black87,
                    fontStyle: FontStyle.italic),
              ),
              SizedBox(height: 20.0),
              _showImage(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  RaisedButton(
                    onPressed: _openCamera,
                    color: Colors.blueAccent,
                    textColor: Colors.white,
                    child:
                        Text(_base64Image == null ? 'Ambil Foto' : 'Ubah Foto'),
                  ),
                  RaisedButton(
                    onPressed: _uploadData,
                    color: Colors.blueAccent,
                    textColor: Colors.white,
                    child: Text('Kirim'),
                  ),
                ],
              ),
              SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }
}
