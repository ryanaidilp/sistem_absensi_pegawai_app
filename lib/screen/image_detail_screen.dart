import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ImageDetailScreen extends StatefulWidget {
  const ImageDetailScreen({this.imageUrl, this.bytes, @required this.tag});

  final String imageUrl;
  final Uint8List bytes;
  final String tag;

  @override
  _ImageDetailScreenState createState() => _ImageDetailScreenState();
}

class _ImageDetailScreenState extends State<ImageDetailScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = widget.imageUrl == null
        ? MemoryImage(widget.bytes)
        : CachedNetworkImageProvider(widget.imageUrl);
    return Scaffold(
      body: Center(
          child: PhotoView(
              heroAttributes: PhotoViewHeroAttributes(
                  tag: widget.tag, transitionOnUserGestures: true),
              maxScale: 5.0,
              imageProvider: provider as ImageProvider)),
    );
  }
}
