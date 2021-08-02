import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

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

Widget pathFutureImage(Future<String> future, double? width, double? height) {
  return FutureBuilder(
      future: future,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.hasError) {
          print("${snapshot.error}");
          print("${snapshot.stackTrace}");
          return buildError(width, height);
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return buildLoading(width, height);
        }
        return buildFile(snapshot.data!, width, height);
      });
}
