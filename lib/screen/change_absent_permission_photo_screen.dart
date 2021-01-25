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
import 'package:spo_balaesang/models/absent_permission.dart';
import 'package:spo_balaesang/repositories/data_repository.dart';
import 'package:spo_balaesang/screen/bottom_nav_screen.dart';
import 'package:spo_balaesang/screen/image_detail_screen.dart';
import 'package:spo_balaesang/utils/file_util.dart';
import 'package:spo_balaesang/utils/view_util.dart';
import 'package:spo_balaesang/widgets/employee_proposal_info_widget.dart';
import 'package:spo_balaesang/widgets/image_placeholder_widget.dart';

class ChangePermissionPhotoScreen extends StatefulWidget {
  ChangePermissionPhotoScreen({this.permission});

  final AbsentPermission permission;

  @override
  _ChangePermissionPhotoScreenState createState() =>
      _ChangePermissionPhotoScreenState();
}

class _ChangePermissionPhotoScreenState
    extends State<ChangePermissionPhotoScreen> {
  String _base64Image;
  String _fileName;
  File _tmpFile;
  AbsentPermission _permission;

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

  Future<void> _uploadData(AbsentPermission permission) async {
    ProgressDialog pd = ProgressDialog(context, isDismissible: false);
    try {
      pd.show();
      final dataRepo = Provider.of<DataRepository>(context, listen: false);
      Map<String, dynamic> data = {
        'photo': _base64Image,
        'file_name': _fileName,
        'permission_id': permission.id
      };
      Map<String, dynamic> _res = await dataRepo.changePermissionPhoto(data);
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
            imageUrl: _permission.photo,
            tag: _permission.id.toString(),
          ));
        },
        child: Hero(
          tag: _permission.id.toString(),
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
              imageUrl: _permission.photo,
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
    _permission = widget.permission;
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
                title: _permission.title,
                startDate: _permission.startDate,
                dueDate: _permission.dueDate,
                label: 'Izin',
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
                'Lampirkan foto surat izin atau surat lainnya seperti surat keterangan dokter, dsb.',
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
                      _uploadData(_permission);
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
