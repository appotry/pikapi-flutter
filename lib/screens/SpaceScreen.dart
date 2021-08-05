import 'package:flutter/material.dart';
import 'package:pikapi/basic/Themes.dart';
import 'package:pikapi/basic/enum/Quality.dart';
import 'package:pikapi/screens/AboutScreen.dart';
import 'package:pikapi/screens/AccountScreen.dart';
import 'package:pikapi/screens/CleanScreen.dart';
import 'package:pikapi/screens/DownloadListScreen.dart';
import 'package:pikapi/screens/FavouritePaperScreen.dart';
import 'package:pikapi/screens/ViewLogsScreen.dart';
import 'package:pikapi/basic/Pica.dart';

import 'components/UserProfileCard.dart';

// 个人空间页面
class SpaceScreen extends StatefulWidget {
  const SpaceScreen();

  @override
  State<StatefulWidget> createState() => _SpaceScreenState();
}

class _SpaceScreenState extends State<SpaceScreen> {
  String _theme = "";
  String _quality = "";

  Future<dynamic> init() async {
    var theme = await pica.loadTheme();
    var quality = await pica.loadQuality();
    setState(() {
      _theme = theme;
      _quality = quality;
    });
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('我的'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AboutScreen()),
              );
            },
            icon: Icon(Icons.grade),
          ),
          IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AccountScreen()),
              );
            },
            icon: Icon(Icons.manage_accounts),
          ),
        ],
      ),
      body: ListView(
        children: [
          Divider(),
          UserProfileCard(),
          Divider(),
          ListTile(
            onTap: () async {
              String? theme = await chooseTheme(context);
              if (theme != null) {
                pica.saveTheme(theme);
                changeThemeByCode(theme);
                setState(() {
                  _theme = theme;
                });
              }
            },
            title: Text('主题'),
            subtitle: Text(themeName(_theme)),
          ),
          Divider(),
          ListTile(
            title: Text("浏览时的图片质量"),
            subtitle: Text(qualityName(_quality)),
            onTap: () async {
              String? quality = await chooseQuality(context, "请选择浏览时的图片质量");
              if (quality != null) {
                pica.saveQuality(quality);
                setState(() {
                  _quality = quality;
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
          ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ViewLogsScreen()),
              );
            },
            title: Text('浏览记录'),
          ),
          Divider(),
          ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FavouritePaperScreen()),
              );
            },
            title: Text('我的收藏'),
          ),
          Divider(),
          ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DownloadListScreen()),
              );
            },
            title: Text('我的下载'),
          ),
          Divider(),
        ],
      ),
    );
  }
}
