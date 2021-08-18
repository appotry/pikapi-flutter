import 'package:flutter/material.dart';
import 'package:pikapi/basic/Common.dart';
import 'package:pikapi/basic/Pica.dart';
import 'package:pikapi/basic/Storage.dart';
import 'package:pikapi/basic/enum/Address.dart';

class NetworkSetting extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _NetworkSettingState();
}

class _NetworkSettingState extends State<NetworkSetting> {

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          ListTile(
            title: Text("分流"),
            subtitle: Text(addressName(storedAddress)),
            onTap: () async {
              var address = await chooseAddress(context);
              if (address != null) {
                await pica.setSwitchAddress(address);
                setState(() {
                  storedAddress = address;
                });
              }
            },
          ),
          ListTile(
            title: Text("代理服务器"),
            subtitle: Text(storedProxy == "" ? "未设置" : storedProxy),
            onTap: () {
              displayTextInputDialog(
                context,
                '代理服务器',
                '请输入代理服务器',
                storedProxy,
                " ( 例如 socks5://127.0.0.1:1080/ ) ",
                (value) async {
                  await pica.setProxy(value);
                  setState(() {
                    storedProxy = value;
                  });
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
