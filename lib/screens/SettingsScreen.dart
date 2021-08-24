import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:multi_select_flutter/dialog/mult_select_dialog.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:pikapi/basic/Common.dart';
import 'package:pikapi/basic/Pica.dart';
import 'package:pikapi/basic/Storage.dart';
import 'package:pikapi/basic/enum/FullScreenAction.dart';
import 'package:pikapi/basic/enum/PagerAction.dart';
import 'package:pikapi/basic/enum/ReaderDirection.dart';
import 'package:pikapi/basic/enum/ReaderType.dart';
import 'package:pikapi/basic/enum/Quality.dart';
import 'package:pikapi/screens/components/NetworkSetting.dart';

import 'CleanScreen.dart';

class SettingsScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text('设置')),
        body: ListView(
          children: [
            Divider(),
            NetworkSetting(),
            Divider(),
            ListTile(
              title: Text("浏览时的图片质量"),
              subtitle: Text(qualityName(storedQuality)),
              onTap: () async {
                String? quality = await chooseQuality(context, "请选择浏览时的图片质量");
                if (quality != null) {
                  pica.saveQuality(quality);
                  setState(() {
                    storedQuality = quality;
                  });
                }
              },
            ),
            ListTile(
              title: Text("阅读器模式"),
              subtitle: Text(readerTypeName(storedReaderType)),
              onTap: () async {
                ReaderType? t = await choosePagerType(context);
                if (t != null) {
                  await pica.saveReaderType(t);
                  setState(() {
                    storedReaderType = t;
                  });
                }
              },
            ),
            ListTile(
              title: Text("阅读器方向"),
              subtitle: Text(readerDirectionName(storedReaderDirection)),
              onTap: () async {
                ReaderDirection? t = await choosePagerDirection(context);
                if (t != null) {
                  await pica.saveReaderDirection(t);
                  setState(() {
                    storedReaderDirection = t;
                  });
                }
              },
            ),
            ListTile(
              title: Text("进入阅读器自动全屏"),
              subtitle: Text(storedAutoFullScreen ? "是" : "否"),
              onTap: () async {
                String? result = await chooseListDialog<String>(
                    context, "进入阅读器自动全屏", ["是", "否"]);
                if (result != null) {
                  var target = result == "是";
                  pica.setAutoFullScreen(target);
                  setState(() {
                    storedAutoFullScreen = target;
                  });
                }
              },
            ),
            ListTile(
              title: Text("进入全屏的方式"),
              subtitle: Text(fullScreenActionName(storedFullScreenAction)),
              onTap: () async {
                FullScreenAction? result =
                    await chooseMapDialog<FullScreenAction>(
                        context, fullScreenActionMap, "选择进入全屏的方式");
                if (result != null) {
                  pica.saveFullScreenAction(result);
                  setState(() {
                    storedFullScreenAction = result;
                  });
                }
              },
            ),
            Divider(),
            ListTile(
              title: Text("列表页加载方式"),
              subtitle: Text(pagerActionName(storedPagerAction)),
              onTap: () async {
                PagerAction? result = await chooseMapDialog<PagerAction>(
                    context, pagerActionMap, "选择列表页加载方式");
                if (result != null) {
                  pica.savePagerAction(result);
                  setState(() {
                    storedPagerAction = result;
                  });
                }
              },
            ),
            Divider(),
            ListTile(
              title: Text("封印"),
              subtitle: Text(jsonEncode(storedShadowCategories)),
              onTap: () async {
                await showDialog(
                  context: context,
                  builder: (ctx) {
                    var initialValue = <String>[];
                    storedShadowCategories.forEach((element) {
                      if (storedCategories.contains(element)) {
                        initialValue.add(element);
                      }
                    });
                    return MultiSelectDialog<String>(
                      title: Text('封印'),
                      searchHint: '搜索',
                      cancelText: Text('取消'),
                      confirmText: Text('确定'),
                      items: storedCategories
                          .map((e) => MultiSelectItem(e, e))
                          .toList(),
                      initialValue: initialValue,
                      onConfirm: (List<String>? value) async {
                        if (value != null) {
                          await pica.setShadowCategories(value);
                          setState(() {
                            storedShadowCategories = value;
                          });
                          storedShadowCategoriesEvent.broadcast();
                        }
                      },
                    );
                  },
                );
              },
            ),
            Divider(),
            ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CleanScreen()),
                );
              },
              title: Text('清除缓存'),
            ),
            Divider(),
          ],
        ),
      );
}
