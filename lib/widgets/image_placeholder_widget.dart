import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spo_balaesang/utils/app_const.dart';

class ImagePlaceholderWidget extends StatelessWidget {
  const ImagePlaceholderWidget({this.label, this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: Get.width,
        height: 250,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(color: Colors.grey[400]),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            child,
            sizedBoxH5,
            Text(
              label,
              style: const TextStyle(color: Colors.grey),
            )
          ],
        ));
  }
}
