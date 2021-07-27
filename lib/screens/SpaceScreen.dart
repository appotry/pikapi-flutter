import 'package:flutter/material.dart';
import 'package:pikapi/basic/Themes.dart';
import 'package:pikapi/basic/enum/Quality.dart';
import 'package:pikapi/screens/AccountScreen.dart';
import 'package:pikapi/screens/DownloadListScreen.dart';
import 'package:pikapi/screens/FavouritePaperScreen.dart';
import 'package:pikapi/screens/ViewLogsScreen.dart';
import 'package:pikapi/service/pica.dart';

class SpaceScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SpaceScreenState();
}

class _SpaceScreenState extends State<SpaceScreen> {
  String _theme = "";
  String _quality = "";

  @override
  void initState() {
    init();
    super.initState();
  }

  init() async {
    var theme = await pica.loadTheme();
    var quality = await pica.loadQuality();
    setState(() {
      _theme = theme;
      _quality = quality;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('我的'),
        actions: [
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
            onTap: () {},
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
