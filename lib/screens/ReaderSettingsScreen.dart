import 'package:flutter/material.dart';
import 'package:pikapi/basic/Pica.dart';
import 'package:pikapi/basic/enum/PagerType.dart';
import 'package:pikapi/basic/enum/Quality.dart';

class ReaderSettingsScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ReaderSettingsScreenState();
}

class _ReaderSettingsScreenState extends State<ReaderSettingsScreen> {
  String _quality = "";
  PagerType? _pagerType;

  Future<dynamic> _init() async {
    var quality = await pica.loadQuality();
    var pt = await pica.loadPagerType();
    setState(() {
      _quality = quality;
      _pagerType = pt;
    });
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text('网络设置')),
        body: ListView(
          children: [
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
              title: Text("阅读器模式"),
              subtitle:
                  Text(_pagerType == null ? "" : pagerTypeName(_pagerType!)),
              onTap: () async {
                PagerType? t = await choosePagerType(context);
                if (t != null) {
                  pica.savePagerType(t);
                  setState(() {
                    _pagerType = t;
                  });
                }
              },
            ),
            Divider(),
          ],
        ),
      );
}
