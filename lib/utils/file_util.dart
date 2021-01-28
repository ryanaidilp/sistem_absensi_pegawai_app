import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';

Future<File> compressAndGetFile(File file, String targetPath) async {
  final result = await FlutterImageCompress.compressAndGetFile(
    file.absolute.path,
    targetPath,
    quality: 60,
  );
  return result;
}
