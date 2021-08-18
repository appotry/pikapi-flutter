import 'package:flutter/material.dart';
import 'package:pikapi/basic/Common.dart';
import 'package:pikapi/basic/Pica.dart';
import 'package:pikapi/basic/Storage.dart';
import 'package:pikapi/basic/enum/FullScreenAction.dart';
import 'package:pikapi/basic/enum/PagerDirection.dart';
import 'package:pikapi/basic/enum/PagerType.dart';
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
              subtitle: Text(pagerTypeName(storedPagerType)),
              onTap: () async {
                PagerType? t = await choosePagerType(context);
                if (t != null) {
                  await pica.savePagerType(t);
                  setState(() {
                    storedPagerType = t;
                  });
                }
              },
            ),
            ListTile(
              title: Text("阅读器方向"),
              subtitle: Text(pagerDirectionName(storedPagerDirection)),
              onTap: () async {
                PagerDirection? t = await choosePagerDirection(context);
                if (t != null) {
                  await pica.savePagerDirection(t);
                  setState(() {
                    storedPagerDirection = t;
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
