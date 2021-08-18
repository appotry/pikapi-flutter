import 'package:flutter/material.dart';
import 'package:pikapi/basic/Pica.dart';
import 'package:pikapi/basic/Storage.dart';
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
