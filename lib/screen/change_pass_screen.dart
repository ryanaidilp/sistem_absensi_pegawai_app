import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:spo_balaesang/repositories/data_repository.dart';
import 'package:spo_balaesang/screen/bottom_nav_screen.dart';
import 'package:spo_balaesang/utils/view_util.dart';

class ChangePasswordScreen extends StatefulWidget {
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _oldPassCtrl = TextEditingController();
  final TextEditingController _newPassCtrl = TextEditingController();
  final TextEditingController _newPass2Ctrl = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey();

  bool isLoading = false;
  bool isOldPassVisible = false;
  bool isNewPassVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text('Ubah Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          children: <Widget>[
            SizedBox(
              height: Get.height,
              child: Form(
                  key: _formKey,
                  child: ListView(
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text('Password Lama',
                              style: TextStyle(fontSize: 12.0)),
                          TextFormField(
                            controller: _oldPassCtrl,
                            validator: (String value) {
                              return value.isEmpty
                                  ? 'Password lama tidak boleh kosong!'
                                  : null;
                            },
                            obscureText: !isNewPassVisible,
                            decoration: InputDecoration(
                                suffixIcon: IconButton(
                                    icon: Icon(isNewPassVisible
                                        ? Icons.visibility_off
                                        : Icons.visibility),
                                    onPressed: () {
                                      setState(() {
                                        isNewPassVisible = !isNewPassVisible;
                                      });
                                    }),
                                hintText: 'Password Lama'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text('Password Baru',
                              style: TextStyle(fontSize: 12.0)),
                          TextFormField(
                            controller: _newPassCtrl,
                            validator: (String value) {
                              if (value.isEmpty) {
                                return 'Password baru tidak boleh kosong!';
                              }
                              if (value == _oldPassCtrl.text) {
                                return 'Password baru tidak boleh sama dengan Password Lama!';
                              }
                              return null;
                            },
                            obscureText: !isOldPassVisible,
                            decoration: InputDecoration(
                                suffixIcon: IconButton(
                                    icon: Icon(isOldPassVisible
                                        ? Icons.visibility_off
                                        : Icons.visibility),
                                    onPressed: () {
                                      setState(() {
                                        isOldPassVisible = !isOldPassVisible;
                                      });
                                    }),
                                hintText: 'Password Baru'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text('Ulangi Password Baru',
                              style: TextStyle(fontSize: 12.0)),
                          TextFormField(
                            controller: _newPass2Ctrl,
                            validator: (String value) {
                              if (value.isEmpty) {
                                return 'Konfirmasi Password baru tidak boleh kosong!';
                              }
                              if (value != _newPassCtrl.text) {
                                return 'Kolom ini harus sama dengan password baru!';
                              }
                              return null;
                            },
                            obscureText: true,
                            decoration: const InputDecoration(
                                hintText: 'Konfirmasi Password Baru'),
                          ),
                        ],
                      )
                    ],
                  )),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: MediaQuery.of(context).viewInsets.bottom,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  onPrimary: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  primary: Colors.blueAccent,
                ),
                onPressed: () async {
                  final ProgressDialog pd =
                      ProgressDialog(context, isDismissible: false);
                  pd.show();
                  try {
                    final dataRepo =
                        Provider.of<DataRepository>(context, listen: false);
                    final Map<String, dynamic> data = {
                      'old_pass': _oldPassCtrl.value.text,
                      'new_pass': _newPassCtrl.value.text,
                      'new_pass_conf': _newPass2Ctrl.value.text
                    };
                    final http.Response response =
                        await dataRepo.changePass(data);
                    final Map<String, dynamic> _res =
                        jsonDecode(response.body) as Map<String, dynamic>;
                    if (response.statusCode == 200) {
                      pd.hide();
                      showAlertDialog(
                          'success', "Sukses", _res['message'].toString(),
                          dismissible: false);
                      Timer(const Duration(seconds: 1),
                          () => Get.off(() => BottomNavScreen()));
                    } else {
                      pd.hide();
                      showErrorDialog(_res);
                    }
                  } catch (e) {
                    pd.hide();
                    showErrorDialog({
                      'message': 'Kesalahan',
                      'errors': {
                        'exception': ['Terjadi kesalahan!']
                      }
                    });
                  }
                },
                child: isLoading
                    ? const SizedBox(
                        height: 30.0,
                        width: 30.0,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('SIMPAN'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
