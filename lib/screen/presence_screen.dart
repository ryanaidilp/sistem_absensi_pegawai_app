import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:android_intent/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:spo_balaesang/repositories/data_repository.dart';
import 'package:spo_balaesang/screen/bottom_nav_screen.dart';
import 'package:spo_balaesang/screen/image_detail_screen.dart';
import 'package:spo_balaesang/utils/app_const.dart';
import 'package:spo_balaesang/utils/file_util.dart';
import 'package:spo_balaesang/utils/view_util.dart';
import 'package:spo_balaesang/widgets/image_placeholder_widget.dart';

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

  Future<void> _openCamera() async {
    if (_address == null || _address.isEmpty) {
      showAlertDialog('failure', 'Lokasi tidak ditemukan.',
          'Pastikan anda sudah menyalakan akses lokasi dan mengizinkan aplikasi untuk mengakses lokasi anda',
          dismissible: false);
    } else {
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
        showAlertDialog('failure', 'Gagal',
            'Lokasi tidak ditemukan.\nPastikan lokasi sudah diaktifkan!',
            dismissible: false);
      }
    });
  }

  Future<void> _uploadData() async {
    final ProgressDialog pd = ProgressDialog(context, isDismissible: false);
    try {
      pd.show();
      final dataRepo = Provider.of<DataRepository>(context, listen: false);
      final Map<String, dynamic> data = {
        'code': _code,
        'latitude': _latitude,
        'longitude': _longitude,
        'address': _address,
        'photo': _base64Image,
        'file_name': _fileName
      };
      final http.Response response = await dataRepo.presence(data);
      final Map<String, dynamic> _res =
          jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200) {
        pd.hide();
        showAlertDialog("success", "Sukses", _res['message'].toString(),
            dismissible: false);
        Timer(const Duration(seconds: 5), () => Get.off(BottomNavScreen()));
      } else {
        controller?.resumeCamera();
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

  Future<void> _getUserLocation() async {
    if (await Permission.location.serviceStatus.isDisabled) {
      Permission.location.shouldShowRequestRationale;
      const AndroidIntent intent =
          AndroidIntent(action: 'android.settings.LOCATION_SOURCE_SETTINGS');
      intent.launch();
    }
    final Position position = await Geolocator().getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    final address = await placemarkFromCoordinates(
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

  Widget _buildQrScanner() {
    if (_address == null || _base64Image == null) {
      return const Text(
        'Scanner akan aktif setelah lokasi berhasil dideteksi dan anda telah mengambil foto',
        style: TextStyle(color: Colors.grey),
      );
    }
    return SizedBox(
        height: 300.0,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.0),
          child: QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
            overlay: QrScannerOverlayShape(
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
      return const SizedBox();
    }
    return const Text(
      'Arahkan kamera ke layar komputer',
      style: TextStyle(color: Colors.grey),
    );
  }

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text('Presensi'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: const <Widget>[
                  Text('Scanner'),
                  sizedBoxW5,
                  Text(
                    '*',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
              _buildPlaceholderQR(),
              _buildQrScanner(),
              sizedBoxH20,
              Row(
                children: const <Widget>[
                  Text('Lokasi'),
                  sizedBoxW5,
                  Text(
                    '*',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
              Text(
                (_address == null || _address.isEmpty)
                    ? 'Memuat lokasi..'
                    : _address,
                style: const TextStyle(color: Colors.grey),
              ),
              sizedBoxH20,
              Row(
                children: const <Widget>[
                  Text('Foto Diri'),
                  sizedBoxW5,
                  Text(
                    '*',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
              const Text(
                'Ambil foto selfie anda sebagai bukti bahwa anda melakukan presensi di kantor tanpa diwakili orang lain. Pastikan wajah terlihat jelas.',
                style: TextStyle(color: Colors.grey),
              ),
              sizedBoxH10,
              const Text(
                '*): Absen akan dibatalkan jika foto tidak sesuai dengan ketentuan. Tekan untuk memperbesar.',
                style: TextStyle(
                    fontSize: 10.0,
                    color: Colors.blueAccent,
                    fontStyle: FontStyle.italic),
              ),
              sizedBoxH20,
              _showImage(),
              RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6)),
                onPressed: _openCamera,
                color: Colors.blueAccent,
                textColor: Colors.white,
                child: Text(_base64Image == null ? 'Ambil Foto' : 'Ubah Foto'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
