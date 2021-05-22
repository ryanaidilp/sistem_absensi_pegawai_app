import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:spo_balaesang/repositories/data_repository.dart';
import 'package:spo_balaesang/screen/bottom_nav_screen.dart';
import 'package:spo_balaesang/utils/app_const.dart';
import 'package:spo_balaesang/utils/view_util.dart';

class CreateNotificationScreen extends StatefulWidget {
  @override
  _CreateNotificationScreenState createState() =>
      _CreateNotificationScreenState();
}

class _CreateNotificationScreenState extends State<CreateNotificationScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  Future<void> _sendNotification() async {
    final ProgressDialog pd = ProgressDialog(context, isDismissible: false);
    try {
      pd.show();
      final dataRepo = Provider.of<DataRepository>(context, listen: false);
      final Map<String, dynamic> data = {
        'title': _titleController.value.text,
        'content': _descriptionController.value.text,
      };
      final Map<String, dynamic> _res = await dataRepo.sendNotification(data);
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
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text('Buat Pemberitahuan'),
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
                  Text('Judul Pemberitahuan'),
                  sizedBoxW5,
                  Text(
                    '*',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
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
                  Text('Isi Pemberitahuan'),
                  sizedBoxW5,
                  Text(
                    '*',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
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
                  onPressed: _sendNotification,
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
