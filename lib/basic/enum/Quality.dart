/// 图片质量的枚举

import 'package:flutter/material.dart';

const ImageQualityOriginal = "original";
const ImageQualityLow = "low";
const ImageQualityMedium = "medium";
const ImageQualityHigh = "high";

const LabelOriginal = "原图";
const LabelLow = "低";
const LabelMedium = "中";
const LabelHigh = "高";

class _Quality {
  final String code;
  final String label;

  _Quality.of({
    required this.code,
    required this.label,
  });
}

final qualityList = [
  _Quality.of(code: ImageQualityOriginal, label: LabelOriginal),
  _Quality.of(code: ImageQualityLow, label: LabelLow),
  _Quality.of(code: ImageQualityMedium, label: LabelMedium),
  _Quality.of(code: ImageQualityHigh, label: LabelHigh),
];

List<DropdownMenuItem<String>> qualityItems = qualityList
    .map(
      (e) => DropdownMenuItem(
        value: e.code,
        child: Text(e.label),
      ),
    )
    .toList();

Future<String?> chooseQuality(BuildContext context, String title) async {
  return await showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return SimpleDialog(
        title: Text(title),
        children: <Widget>[
          ...qualityList.map(
            (e) => SimpleDialogOption(
              child: Text(e.label),
              onPressed: () {
                Navigator.of(context).pop(e.code);
              },
            ),
          ),
        ],
      );
    },
  );
}

String qualityName(String quality) {
  switch (quality) {
    case ImageQualityOriginal:
      return LabelOriginal;
    case ImageQualityLow:
      return LabelLow;
    case ImageQualityMedium:
      return LabelMedium;
    case ImageQualityHigh:
      return LabelHigh;
    default:
      return "";
  }
}
