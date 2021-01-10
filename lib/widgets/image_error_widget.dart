import 'package:flutter/material.dart';

class ImageErrorWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(color: Colors.grey[500]),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.warning_amber_rounded),
            Text('Gagal memuat gambar!')
          ],
        ));
  }
}
