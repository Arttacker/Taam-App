import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

import '../../shared/style/icon_broken.dart';

class OpenImageChat extends StatelessWidget {
  OpenImageChat({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(IconBroken.Arrow___Left_2),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: PhotoView(
          minScale: PhotoViewComputedScale.contained,
          imageProvider: NetworkImage(url),
          backgroundDecoration: const BoxDecoration(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
