import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pikapi/basic/Entities.dart';

Widget buildMock(double? width, double? height) {
  return Container(
    width: width,
    height: height,
    padding: EdgeInsets.all(10),
    child: Center(
      child: SvgPicture.asset(
        'lib/assets/unknown.svg',
        width: width,
        height: height,
        color: Colors.grey.shade600,
      ),
    ),
  );
}

Widget buildError(double? width, double? height) {
  return Image(
    image: AssetImage('lib/assets/error.png'),
    width: width,
    height: height,
  );
}

Widget buildLoading(double? width, double? height) {
  return Container(
    width: width,
    height: height,
    child: Center(
      child: Icon(
        Icons.downloading,
        size: width,
        color: Colors.black12,
      ),
    ),
  );
}

Widget buildBuff(Uint8List file, double? width, double? height) {
  return Image.memory(
    file,
    width: width,
    height: height,
    errorBuilder: (a, b, c) => buildError(width, height),
    fit: BoxFit.cover,
  );
}

Widget buildFile(String file, double? width, double? height) {
  return Image.file(
    File(file),
    width: width,
    height: height,
    errorBuilder: (a, b, c) {
      print("$b");
      print("$c");
      return buildError(width, height);
    },
    fit: BoxFit.cover,
  );
}

Widget imageDataFutureBuilder(
    Future<RemoteImageData> future, double? width, double? height) {
  return FutureBuilder(
      future: future,
      builder: (BuildContext context, AsyncSnapshot<RemoteImageData> snapshot) {
        if (snapshot.hasError) {
          print("${snapshot.error}");
          print("${snapshot.stackTrace}");
          return buildError(width, height);
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return buildLoading(width, height);
        }
        return buildBuff(snapshot.data!.buff, width, height);
      });
}
