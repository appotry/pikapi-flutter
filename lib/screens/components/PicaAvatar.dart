import 'package:flutter/material.dart';
import 'package:pikapi/basic/Entities.dart';
import 'Images.dart';

const double _avatarMargin = 5;
const double _avatarBorderSize = 1.5;

// 头像
class PicaAvatar extends StatelessWidget {
  final PicaImage avatarImage;
  final double size;

  const PicaAvatar(this.avatarImage, {this.size = 50});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Container(
      margin: EdgeInsets.all(_avatarMargin),
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: theme.colorScheme.secondary,
            style: BorderStyle.solid,
            width: _avatarBorderSize,
          )),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(size)),
        child: RemoteImage(
          width: size,
          height: size,
          fileServer: avatarImage.fileServer,
          path: avatarImage.path,
        ),
      ),
    );
  }
}
