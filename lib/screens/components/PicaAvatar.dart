import 'package:flutter/material.dart';
import 'package:pikapi/basic/Entities.dart';
import 'Images.dart';

const double _avatarMargin = 5;
const double _avatarImageSize = 50;
const double _avatarBorderSize = 1.5;

// 头像
class PicaAvatar extends StatelessWidget {
  final PicaImage avatarImage;

  PicaAvatar(this.avatarImage);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Container(
      margin: EdgeInsets.all(_avatarMargin),
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: theme.accentColor,
            style: BorderStyle.solid,
            width: _avatarBorderSize,
          )),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(_avatarImageSize)),
        child: RemoteImage(
          width: _avatarImageSize,
          height: _avatarImageSize,
          fileServer: avatarImage.fileServer,
          path: avatarImage.path,
        ),
      ),
    );
  }
}
