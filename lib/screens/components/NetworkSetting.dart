import 'package:flutter/material.dart';
import 'package:pikapi/basic/Common.dart';
import 'package:pikapi/basic/Pica.dart';
import 'package:pikapi/basic/enum/Address.dart';

// 这里用GlobalKey是为了让注册和登录页面保持一致
final _networkSettingGK = GlobalKey<_NetworkSettingState>();

class NetworkSetting extends StatefulWidget {
  NetworkSetting() : super(key: _networkSettingGK);

  @override
  State<StatefulWidget> createState() => _NetworkSettingState();
}

class _NetworkSettingState extends State<NetworkSetting> {
  late String _address = "";
  late String _proxy = "";

  @override
  void initState() {
    _load();
    super.initState();
  }

  Future _load() async {
    var address = await pica.getSwitchAddress();
    var proxy = await pica.getProxy();
    setState(() {
      _address = address;
      _proxy = proxy;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          ListTile(
            title: Text("分流"),
            subtitle: Text(addressName(_address)),
            onTap: () async {
              var address = await chooseAddress(context);
              if (address != null) {
                await pica.setSwitchAddress(address);
                setState(() {
                  _address = address;
                });
              }
            },
          ),
          ListTile(
            title: Text("代理服务器"),
            subtitle: Text(_proxy == "" ? "未设置" : _proxy),
            onTap: () {
              displayTextInputDialog(
                context,
                '代理服务器',
                '请输入代理服务器',
                _proxy,
                " ( 例如 socks5://127.0.0.1:1080/ ) ",
                (value) async {
                  await pica.setProxy(value);
                  setState(() {
                    _proxy = value;
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
