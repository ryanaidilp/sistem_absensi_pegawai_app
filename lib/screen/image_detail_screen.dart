import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ImageDetailScreen extends StatefulWidget {
  const ImageDetailScreen({this.imageUrl});

  final String imageUrl;

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
    return Scaffold(
      body: Center(
          child: PhotoView(
              heroAttributes: PhotoViewHeroAttributes(
                  tag: 'image', transitionOnUserGestures: true),
              maxScale: 5.0,
              imageProvider: CachedNetworkImageProvider(widget.imageUrl))),
    );
  }
}
