import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:android_intent/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:spo_balaesang/repositories/data_repository.dart';
import 'package:spo_balaesang/screen/home_screen.dart';
import 'package:spo_balaesang/utils/file_util.dart';
import 'package:spo_balaesang/utils/view_util.dart';

class PresenceScreen extends StatefulWidget {
  @override
  _PresenceScreenState createState() => _PresenceScreenState();
}

class _PresenceScreenState extends State<PresenceScreen> {
  String _base64Image;
  String _fileName;
  File _tmpFile;
  String _address = "";
  double _latitude = 0;
  double _longitude = 0;
  String _code;

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController controller;

  _openCamera() async {
    if (_address == null || _address.isEmpty) {
      showAlertDialog(
          'failure',
          'Lokasi tidak ditemukan.',
          'Pastikan anda sudah menyalakan akses lokasi dan mengizinkan aplikasi untuk mengakses lokasi anda',
          context,
          false);
    } else {
      var picture = await ImagePicker().getImage(source: ImageSource.camera);
      var file = await compressAndGetFile(File(picture.path),
          '/storage/emulated/0/Android/data/com.banuacoders.siap/files/Pictures/images.jpg');
      setState(() {
        _tmpFile = file;
        _base64Image = base64Encode(_tmpFile.readAsBytesSync());
        _fileName = _tmpFile.path.split('/').last;
      });
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;

    controller.scannedDataStream.listen((scanData) {
      setState(() {
        _code = scanData;
      });
      if (_address != null || _address.isNotEmpty) {
        this.controller?.pauseCamera();
        _uploadData();
      } else {
        showAlertDialog(
            'failure',
            'Gagal',
            'Lokasi tidak ditemukan.\nPastikan lokasi sudah diaktifkan!',
            context,
            false);
      }
    });
  }

  Future<void> _uploadData() async {
    ProgressDialog pd = ProgressDialog(context, isDismissible: false);
    try {
      pd.show();
      final dataRepo = Provider.of<DataRepository>(context, listen: false);
      Map<String, dynamic> data = {
        'code': _code,
        'latitude': _latitude,
        'longitude': _longitude,
        'address': _address,
        'photo': _base64Image,
        'file_name': _fileName
      };
      print(jsonEncode(data));
      Response response = await dataRepo.presence(data);
      Map<String, dynamic> _res = jsonDecode(response.body);
      if (response.statusCode == 200) {
        pd.hide();
        showAlertDialog("success", "Sukses", _res['message'], context, false);
        Timer(
            Duration(seconds: 5),
            () => Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => HomeScreen()),
                (route) => false));
      } else {
        this.controller?.resumeCamera();
        if (pd.isShowing()) pd.hide();
        showErrorDialog(context, _res);
      }
    } catch (e) {
      print(e.toString());
      pd.hide();
    }
  }

  getUserLocation() async {
    if (await Permission.location.serviceStatus.isDisabled) {
      Permission.location.shouldShowRequestRationale;
      final AndroidIntent intent = AndroidIntent(
          action: 'android.settings.LOCATION_SOURCE_SETTINGS');
      intent.launch();
    }
    Position position = await Geolocator().getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    var address = await placemarkFromCoordinates(
        position.latitude, position.longitude,
        localeIdentifier: 'id');
    setState(() {
      _latitude = position.latitude;
      _longitude = position.longitude;
      _address =
          "${address.first.name}, ${address.first.street},  ${address.first.locality}, ${address.first.subAdministrativeArea}, ${address.first.administrativeArea} ${address.first.postalCode}";
    });
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

  Widget _buildQrScanner() {
    if (_address == null || _base64Image == null) {
      return Text(
        'Scanner akan aktif setelah lokasi berhasil dideteksi dan anda telah mengambil foto',
        style: TextStyle(color: Colors.grey),
      );
    }
    return Container(
        height: 300.0,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.0),
          child: QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
            overlay: QrScannerOverlayShape(
              borderColor: Colors.red,
              borderRadius: 10,
              borderLength: 30,
              borderWidth: 10,
              cutOutSize: 300,
            ),
          ),
        ));
  }

  Widget _buildPlaceholderQR() {
    if (_address == null || _base64Image == null) {
      return SizedBox();
    }
    return Text(
      'Arahkan kamera ke layar komputer',
      style: TextStyle(color: Colors.grey),
    );
  }

  @override
  void initState() {
    super.initState();
    getUserLocation();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text('Presensi'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text('Scanner'),
                  SizedBox(width: 5.0),
                  Text(
                    '*',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
              _buildPlaceholderQR(),
              _buildQrScanner(),
              SizedBox(height: 20.0),
              Row(
                children: <Widget>[
                  Text('Lokasi'),
                  SizedBox(width: 5.0),
                  Text(
                    '*',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
              Text(
                '${(_address == null || _address.isEmpty) ? 'Memuat lokasi..' : _address}',
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(height: 20.0),
              Row(
                children: <Widget>[
                  Text('Foto Diri'),
                  SizedBox(width: 5.0),
                  Text(
                    '*',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
              Text(
                'Ambil foto selfie anda di depan layar komputer sebagai bukti bahwa anda melakukan presensi di kantor tanpa diwakili orang lain.',
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(height: 10.0),
              Text(
                '*): Absen akan dibatalkan jika foto tidak sesuai dengan ketentuan.',
                style: TextStyle(
                    fontSize: 10.0,
                    color: Colors.blueAccent,
                    fontStyle: FontStyle.italic),
              ),
              SizedBox(height: 20.0),
              _showImage(),
              RaisedButton(
                onPressed: _openCamera,
                color: Colors.blueAccent,
                textColor: Colors.white,
                child: Text('Ambil Foto'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
