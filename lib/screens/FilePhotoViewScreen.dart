import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class FilePhotoViewScreen extends StatelessWidget {
  final String filePath;

  FilePhotoViewScreen(this.filePath);

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Stack(
      children: [
        PhotoView(
          imageProvider: FileImage(File(filePath)),
        ),
        InkWell(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            margin: EdgeInsets.only(top: 30),
            padding: EdgeInsets.only(left: 4, right: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(.75),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: Icon(Icons.keyboard_backspace, color: Colors.white),
          ),
        ),
      ],
    ),
  );
}
