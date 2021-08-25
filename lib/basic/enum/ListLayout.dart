/// 列表页的布局

import 'package:event/event.dart';
import 'package:flutter/material.dart';

import '../Common.dart';
import '../Pica.dart';

enum ListLayout {
  INFO_CARD,
  ONLY_IMAGE,
  COVER_AND_TITLE,
}

const Map<String, ListLayout> listLayoutMap = {
  '详情': ListLayout.INFO_CARD,
  '封面': ListLayout.ONLY_IMAGE,
  '封面+标题': ListLayout.COVER_AND_TITLE,
};

ListLayout listLayoutFromString(String layoutString) {
  for (var value in ListLayout.values) {
    if (layoutString == value.toString()) {
      return value;
    }
  }
  return ListLayout.INFO_CARD;
}

late ListLayout currentLayout;

class ListLayoutArgs extends EventArgs {}

var listLayoutEvent = Event<ListLayoutArgs>();

void chooseListLayout(BuildContext context) async {
  ListLayout? layout = await chooseMapDialog(context, listLayoutMap, '请选择布局');
  if (layout != null) {
    await pica.saveListLayout(layout);
    currentLayout = layout;
    listLayoutEvent.broadcast();
  }
}

IconButton chooseLayoutAction(BuildContext context) => IconButton(
      onPressed: () {
        chooseListLayout(context);
      },
      icon: Icon(Icons.view_quilt),
    );
