import 'package:flutter/material.dart';
import 'package:pikapi/basic/enum/Address.dart';
import 'package:pikapi/basic/Pica.dart';

import 'AppScreen.dart';
import 'DownloadListScreen.dart';
import 'components/ContentLoading.dart';

// 账户设置
class AccountScreen extends StatefulWidget {
  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  late bool _logging = false;
  late String _username = "";
  late String _password = "";
  late String _address = "";
  late String _proxy = "";

  @override
  void initState() {
    _loadProperties();
    super.initState();
  }

  Future _loadProperties() async {
    var username = await pica.getUsername();
    var password = await pica.getPassword();
    var address = await pica.getSwitchAddress();
    var proxy = await pica.getProxy();
    setState(() {
      _username = username;
      _password = password;
      _address = address;
      _proxy = proxy;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_logging) {
      return _buildLogging();
    }
    return _buildGui();
  }

  Widget _buildLogging() {
    return Scaffold(
      body: ContentLoading(label: '登录中'),
    );
  }

  Widget _buildGui() {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.dark,
        title: Text('配置选项'),
        actions: [
          IconButton(
            onPressed: _toDownloadList,
            icon: Icon(Icons.download_rounded),
          ),
          IconButton(
            onPressed: _logIn,
            icon: Icon(Icons.save),
          ),
        ],
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text("哔咔账号"),
            subtitle: Text(_username == "" ? "未设置" : _username),
            onTap: () {
              _displayTextInputDialog(
                context,
                '哔咔账号',
                '请输入哔咔账号',
                _username,
                "",
                (value) async {
                  await pica.setUsername(value);
                  setState(() {
                    _username = value;
                  });
                },
              );
            },
          ),
          ListTile(
            title: Text("哔咔密码"),
            subtitle: Text(_password == "" ? "未设置" : _password),
            onTap: () {
              _displayTextInputDialog(
                context,
                '哔咔密码',
                '请输入哔咔密码',
                _password,
                "",
                (value) async {
                  await pica.setPassword(value);
                  setState(() {
                    _password = value;
                  });
                },
              );
            },
          ),
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
              _displayTextInputDialog(
                context,
                '代理服务器',
                '请输入代理服务器',
                _proxy,
                "",
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

  _logIn() async {
    setState(() {
      _logging = true;
    });
    try {
      await pica.login();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AppScreen()),
      );
    } catch (e) {
      print(e);
      setState(() {
        _logging = false;
      });
    }
  }

  _toDownloadList() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DownloadListScreen()),
    );
  }

  var _controller = TextEditingController.fromValue(TextEditingValue(text: ''));

  Future<void> _displayTextInputDialog(
    BuildContext context,
    String title,
    String hint,
    String src,
    String desc,
    void Function(String) onConfirm,
  ) async {
    _controller.text = src;
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(hintText: hint),
          ),
          actions: <Widget>[
            MaterialButton(
              child: Text('取消'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            MaterialButton(
              child: Text('确认'),
              onPressed: () {
                onConfirm(_controller.text);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
