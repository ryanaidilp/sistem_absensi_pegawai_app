import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:spo_balaesang/repositories/data_repository.dart';
import 'package:spo_balaesang/screen/home_screen.dart';
import 'package:spo_balaesang/utils/file_util.dart';
import 'package:spo_balaesang/utils/view_util.dart';

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
      Map<String, dynamic> _res = await dataRepo.permission(data);
      if (_res['success']) {
        pd.hide();
        showAlertDialog('success', "Sukses",
            _res['message'], context, false);
        Timer(
            Duration(seconds: 5),
            () => Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => HomeScreen()),
                (route) => false));
      } else {
        if (pd.isShowing()) pd.hide();
        showErrorDialog(context, _res);
      }
    } catch (e) {
      print(e.toString());
      pd.hide();
    }
  }

  Widget _showImage() {
    if (_base64Image == null) {
      return Image.asset(
        'assets/images/upload_placeholder.png',
      );
    }

    Uint8List bytes = base64Decode(_base64Image);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.0),
      child: Image.memory(bytes),
    );
  }

  _selectDueDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: _dueDate,
        firstDate: DateTime.now(),
        lastDate: DateTime(2025));
    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }
  
  _selectStartDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: _startDate,
        firstDate: DateTime.now(),
        lastDate: DateTime(2025));
    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text('Buat Izin'),
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
              Text(
                'Mis: Izin Sakit, Izin Kegiatan Lapangan, dsb.',
                style: TextStyle(color: Colors.grey),
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
                smartDashesType: SmartDashesType.enabled,
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
                'Jelaskan secara singkat tentang izin yang diajukan!',
                style: TextStyle(color: Colors.grey),
              ),
              TextFormField(
                keyboardType: TextInputType.text,
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
                  Text('Tanggal Izin'),
                  SizedBox(width: 5.0),
                  Text(
                    '*',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
              Text(
                'Pilih kapan izin mulai berlaku!',
                style: TextStyle(color: Colors.grey),
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      '${DateFormat.yMMMMd().format(
                        _startDate,
                      )}',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  IconButton(
                      icon: Icon(
                        Icons.calendar_today_rounded,
                        color: Colors.blueAccent,
                      ),
                      onPressed: () {
                        _selectStartDate(context);
                      })
                ],
              ),
              SizedBox(height: 20.0),
              Row(
                children: <Widget>[
                  Text('Tanggal Kadaluarsa'),
                  SizedBox(width: 5.0),
                  Text(
                    '*',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
              Text(
                'Pilih sampai kapan izin yang diajukan berlaku!',
                style: TextStyle(color: Colors.grey),
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      '${DateFormat.yMMMMd().format(
                        _dueDate,
                      )}',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  IconButton(
                      icon: Icon(
                        Icons.calendar_today_rounded,
                        color: Colors.blueAccent,
                      ),
                      onPressed: () {
                        _selectDueDate(context);
                      })
                ],
              ),
              SizedBox(height: 20.0),
              Row(
                children: <Widget>[
                  Text('Foto Surat Izin'),
                  SizedBox(width: 5.0),
                  Text(
                    '*',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
              Text(
                'Lampirkan foto surat izin atau surat lainnya seperti surat keterangan sakit dsb.',
                style: TextStyle(color: Colors.grey),
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
                    child: Text('Ambil Foto'),
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
