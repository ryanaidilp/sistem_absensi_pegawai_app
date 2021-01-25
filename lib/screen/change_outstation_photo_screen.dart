import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:spo_balaesang/models/outstation.dart';
import 'package:spo_balaesang/repositories/data_repository.dart';
import 'package:spo_balaesang/screen/bottom_nav_screen.dart';
import 'package:spo_balaesang/screen/image_detail_screen.dart';
import 'package:spo_balaesang/utils/file_util.dart';
import 'package:spo_balaesang/utils/view_util.dart';
import 'package:spo_balaesang/widgets/employee_proposal_info_widget.dart';
import 'package:spo_balaesang/widgets/image_placeholder_widget.dart';

class ChangeOutstationPhotoScreen extends StatefulWidget {
  ChangeOutstationPhotoScreen({this.outstation});

  final Outstation outstation;

  @override
  _ChangeOutstationPhotoScreenState createState() =>
      _ChangeOutstationPhotoScreenState();
}

class _ChangeOutstationPhotoScreenState
    extends State<ChangeOutstationPhotoScreen> {
  String _base64Image;
  String _fileName;
  File _tmpFile;
  Outstation _outstation;

  _openCamera() async {
    var picture = await ImagePicker().getImage(source: ImageSource.camera);
    var file = await compressAndGetFile(File(picture.path),
        '/storage/emulated/0/Android/data/com.banuacoders.siap/files/Pictures/images.jpg');
    setState(() {
      _tmpFile = file;
      _base64Image = base64Encode(_tmpFile.readAsBytesSync());
      _fileName = _tmpFile.path.split('/').last;
    });
    await file.delete(recursive: true);
  }

  Future<void> _uploadData(Outstation outstation) async {
    ProgressDialog pd = ProgressDialog(context, isDismissible: false);
    try {
      pd.show();
      final dataRepo = Provider.of<DataRepository>(context, listen: false);
      Map<String, dynamic> data = {
        'photo': _base64Image,
        'file_name': _fileName,
        'outstation_id': outstation.id
      };
      Map<String, dynamic> _res = await dataRepo.changeOutstationPhoto(data);
      print(_res.toString());
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

  Widget _showImage() {
    if (_base64Image == null) {
      return InkWell(
        onTap: () {
          Get.to(ImageDetailScreen(
            imageUrl: _outstation.photo,
            tag: _outstation.id.toString(),
          ));
        },
        child: Hero(
          tag: _outstation.id.toString(),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: CachedNetworkImage(
              placeholder: (_, __) => ImagePlaceholderWidget(
                label: 'Memuat Foto',
                child: SpinKitFadingCircle(
                  size: 25.0,
                  color: Colors.blueAccent,
                ),
              ),
              imageUrl: _outstation.photo,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => ImagePlaceholderWidget(
                label: 'Gagal memuat foto!',
                child: Icon(
                  Icons.image_not_supported_rounded,
                  color: Colors.grey,
                ),
              ),
              width: Get.width,
              height: 250.0,
            ),
          ),
        ),
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

  @override
  void initState() {
    _outstation = widget.outstation;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text('Perbarui Lampiran'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Pastikan gembar yang akan dikirim adalah salah satu dari memo absen, SPPD, atau surat keterangan dokter. ' +
                  'Pastikan juga surat sudah ditandatangani oleh pihak yang berwenang disertai dengan cap resmi.'),
              SizedBox(height: 20.0),
              EmployeeProposalInfoWidget(
                title: _outstation.title,
                startDate: _outstation.startDate,
                dueDate: _outstation.dueDate,
                label: 'Dinas Luar',
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
                'Lampirkan foto SPPD atau surat lainnya seperti memo absen, dsb.',
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
              SizedBox(height: 10.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
                    onPressed: _openCamera,
                    color: Colors.blueAccent,
                    textColor: Colors.white,
                    child: Text('Ubah Foto'),
                  ),
                  RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
                    onPressed: () {
                      _uploadData(_outstation);
                    },
                    color: Colors.green,
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
