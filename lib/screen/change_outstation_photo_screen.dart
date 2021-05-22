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
import 'package:spo_balaesang/utils/app_const.dart';
import 'package:spo_balaesang/utils/file_util.dart';
import 'package:spo_balaesang/utils/view_util.dart';
import 'package:spo_balaesang/widgets/employee_proposal_info_widget.dart';
import 'package:spo_balaesang/widgets/image_placeholder_widget.dart';

class ChangeOutstationPhotoScreen extends StatefulWidget {
  const ChangeOutstationPhotoScreen({this.outstation});

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

  Future<void> _uploadData(Outstation outstation) async {
    final ProgressDialog pd = ProgressDialog(context, isDismissible: false);
    try {
      pd.show();
      final dataRepo = Provider.of<DataRepository>(context, listen: false);
      final Map<String, dynamic> data = {
        'photo': _base64Image,
        'file_name': _fileName,
        'outstation_id': outstation.id
      };
      final Map<String, dynamic> _res =
          await dataRepo.changeOutstationPhoto(data);
      if (_res['success'] as bool) {
        pd.hide();
        showAlertDialog('success', "Sukses", _res['message'].toString(),
            dismissible: false);
        Timer(
            const Duration(seconds: 5), () => Get.off(() => BottomNavScreen()));
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

  Widget _showImage() {
    if (_base64Image == null) {
      return InkWell(
        onTap: () {
          Get.to(() => ImageDetailScreen(
                imageUrl: _outstation.photo,
                tag: _outstation.id.toString(),
              ));
        },
        child: Hero(
          tag: _outstation.id.toString(),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: CachedNetworkImage(
              placeholder: (_, __) => const ImagePlaceholderWidget(
                label: 'Memuat Foto',
                child: SpinKitFadingCircle(
                  size: 25.0,
                  color: Colors.blueAccent,
                ),
              ),
              imageUrl: _outstation.photo,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => const ImagePlaceholderWidget(
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
        title: const Text('Perbarui Lampiran'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                  'Pastikan gembar yang akan dikirim adalah salah satu dari memo absen, SPPD, atau surat keterangan dokter. ' +
                      'Pastikan juga surat sudah ditandatangani oleh pihak yang berwenang disertai dengan cap resmi.'),
              sizedBoxH20,
              EmployeeProposalInfoWidget(
                title: _outstation.title,
                startDate: _outstation.startDate,
                dueDate: _outstation.dueDate,
                label: 'Dinas Luar',
              ),
              sizedBoxH20,
              Row(
                children: const <Widget>[
                  Text('Foto Surat Tugas'),
                  SizedBox(width: 5.0),
                  Text(
                    '*',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
              const Text(
                'Lampirkan foto SPPD atau surat lainnya seperti memo absen, dsb.',
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
                  child: const Text('Ubah Foto'),
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
                  onPressed: () {
                    _uploadData(_outstation);
                  },
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
