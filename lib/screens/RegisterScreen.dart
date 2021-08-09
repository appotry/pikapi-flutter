import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:pikapi/basic/Common.dart';
import 'package:pikapi/basic/Pica.dart';
import 'package:pikapi/basic/enum/Address.dart';

import 'components/ContentLoading.dart';

class RegisterScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  late bool _registering = false;
  late bool _registerOver = false;

  late String _address = "";
  late String _proxy = "";

  late String _email = "";
  late String _name = "";
  late String _password = "";
  late String _gender = "bot";
  late String _birthday = "2000-01-01";
  late String _question1 = "问题1";
  late String _answer1 = "回答1";
  late String _question2 = "问题2";
  late String _answer2 = "回答2";
  late String _question3 = "问题3";
  late String _answer3 = "回答3";

  late String _errorMessage = "";

  Future _load() async {
    var address = await pica.getSwitchAddress();
    var proxy = await pica.getProxy();
    setState(() {
      _address = address;
      _proxy = proxy;
    });
  }

  Future _register() async {
    setState(() {
      _registering = true;
    });
    try {
      var mustList = <String>[
        _email,
        _name,
        _password,
        _gender,
        _birthday,
        _question1,
        _answer1,
        _question2,
        _answer2,
        _question3,
        _answer3,
      ];
      for (var a in mustList) {
        if (a.isEmpty) {
          throw '请检查表单, 不允许留空';
        }
      }
      await pica.register(
        _email,
        _name,
        _password,
        _gender,
        _birthday,
        _question1,
        _answer1,
        _question2,
        _answer2,
        _question3,
        _answer3,
      );
      await pica.setUsername(_email);
      await pica.setPassword(_password);
      await pica.clearToken();
      setState(() {
        _registerOver = true;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "$e";
      });
    } finally {
      setState(() {
        _registering = false;
      });
    }
  }

  @override
  void initState() {
    _load();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_registerOver) {
      return Scaffold(
        appBar: AppBar(
          title: Text('注册成功'),
        ),
        body: Center(
          child: Container(
            child: Column(
              children: [
                Expanded(child: Container()),
                Text('您已经注册成功, 请返回登录'),
                Text('账号 : $_email'),
                Text('昵称 : $_name'),
                Text('密码 : $_password'),
                Expanded(child: Container()),
                Expanded(child: Container()),
              ],
            ),
          ),
        ),
      );
    }
    if (_registering) {
      return Scaffold(
        appBar: AppBar(),
        body: ContentLoading(label: '注册中'),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text('注册'), actions: [
        IconButton(onPressed: () => _register(), icon: Icon(Icons.check),),
      ],),
      body: ListView(
        children: [
          _buildErrorMessage(),
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
            subtitle: Text(
                _proxy == "" ? "未设置 ( 例如 socks5://127.0.0.1:1080/ )" : _proxy),
            onTap: () {
              displayTextInputDialog(
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
          Divider(),
          ListTile(
            title: Text("哔咔账号 (不一定是邮箱/登录使用)"),
            subtitle: Text(_email == "" ? "未设置" : _email),
            onTap: () {
              displayTextInputDialog(
                context,
                '哔咔账号',
                '请输入哔咔账号',
                _email,
                "",
                    (value) {
                  setState(() {
                    _email = value;
                  });
                },
              );
            },
          ),
          ListTile(
            title: Text("哔咔密码 (8位以上)"),
            subtitle: Text(_password == "" ? "未设置" : _password),
            onTap: () {
              displayTextInputDialog(
                context,
                '哔咔密码',
                '请输入哔咔密码',
                _password,
                "",
                    (value) {
                  setState(() {
                    _password = value;
                  });
                },
              );
            },
          ),
          ListTile(
            title: Text("昵称 (2-50字)"),
            subtitle: Text(_name == "" ? "未设置" : _name),
            onTap: () {
              displayTextInputDialog(
                context,
                '昵称',
                '请输入昵称',
                _name,
                "",
                    (value) {
                  setState(() {
                    _name = value;
                  });
                },
              );
            },
          ),
          ListTile(
            title: Text("性别"),
            subtitle: Text(_genderText(_gender)),
            onTap: () async {
              String? result = await showDialog<String>(
                context: context,
                builder: (BuildContext context) {
                  return SimpleDialog(
                    title: Text('选择您的性别'),
                    children: [
                      SimpleDialogOption(
                        child: Text('扶她'),
                        onPressed: () {
                          Navigator.pop(context, 'bot');
                        },
                      ),
                      SimpleDialogOption(
                        child: Text('公'),
                        onPressed: () {
                          Navigator.pop(context, 'm');
                        },
                      ),
                      SimpleDialogOption(
                        child: Text('母'),
                        onPressed: () {
                          Navigator.pop(context, 'f');
                        },
                      ),
                    ],
                  )
                },
              );
              if (result != null) {
                setState(() {
                  _gender = result;
                });
              }
            },
          ),
          ListTile(
            title: Text("生日"),
            subtitle: Text(_birthday),
            onTap: () async {
              DatePicker.showDatePicker(
                  context,
                  locale: LocaleType.zh,
                  currentTime: DateTime.parse(_birthday),
                  onConfirm: (date) {
                    setState(() {
                      _birthday = formatTimeToDate(date.toString());
                    });
                  }
              );
            },
          ),
          Divider(),
          ListTile(
            title: Text("回答1"),
            subtitle: Text(_answer1 == "" ? "未设置" : _answer1),
            onTap: () {
              displayTextInputDialog(
                context,
                '回答1',
                '请输入回答1',
                _answer1,
                "",
                    (value) {
                  setState(() {
                    _answer1 = value;
                  });
                },
              );
            },
          ),
          ListTile(
            title: Text("问题1"),
            subtitle: Text(_question1 == "" ? "未设置" : _question1),
            onTap: () {
              displayTextInputDialog(
                context,
                '问题1',
                '请输入问题1',
                _question1,
                "",
                    (value) {
                  setState(() {
                    _question1 = value;
                  });
                },
              );
            },
          ),
          ListTile(
            title: Text("回答2"),
            subtitle: Text(_answer2 == "" ? "未设置" : _answer2),
            onTap: () {
              displayTextInputDialog(
                context,
                '回答2',
                '请输入回答2',
                _answer2,
                "",
                    (value) {
                  setState(() {
                    _answer2 = value;
                  });
                },
              );
            },
          ),
          ListTile(
            title: Text("问题2"),
            subtitle: Text(_question2 == "" ? "未设置" : _question2),
            onTap: () {
              displayTextInputDialog(
                context,
                '问题2',
                '请输入问题2',
                _question2,
                "",
                    (value) {
                  setState(() {
                    _question2 = value;
                  });
                },
              );
            },
          ),
          ListTile(
            title: Text("回答3"),
            subtitle: Text(_answer3 == "" ? "未设置" : _answer3),
            onTap: () {
              displayTextInputDialog(
                context,
                '回答3',
                '请输入回答3',
                _answer3,
                "",
                    (value) {
                  setState(() {
                    _answer3 = value;
                  });
                },
              );
            },
          ),
          ListTile(
            title: Text("问题3"),
            subtitle: Text(_question3 == "" ? "未设置" : _question3),
            onTap: () {
              displayTextInputDialog(
                context,
                '问题3',
                '请输入问题3',
                _question3,
                "",
                    (value) {
                  setState(() {
                    _question3 = value;
                  });
                },
              );
            },
          ),
          Divider(),
        ],
      ),
    );
  }

  String _genderText(String gender) {
    switch (gender) {
      case 'bot':
        return "扶她";
      case "m":
        return "公";
      case "f":
        return "母";
      default:
        return "";
    }
  }

  Widget _buildErrorMessage() {
    return _errorMessage == "" ? Container() : Container(
      padding: EdgeInsets.all(10),
      child: Text(
        '注册失败 : $_errorMessage',
        style: TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    );
  }

}
