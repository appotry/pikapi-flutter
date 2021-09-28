/// 主题

import 'dart:io';

import 'package:event/event.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Pica.dart';

// 主题包
abstract class _ThemePackage {
  String code();

  String name();

  ThemeData themeData();
}

class _OriginTheme extends _ThemePackage {
  @override
  String code() => "origin";

  @override
  String name() => "原生";

  @override
  ThemeData themeData() => ThemeData();
}

class _PinkTheme extends _ThemePackage {
  @override
  String code() => "pink";

  @override
  String name() => "粉色";

  @override
  ThemeData themeData() =>
      ThemeData().copyWith(
        brightness: Brightness.light,
        colorScheme: ColorScheme.light(
          secondary: Colors.pink.shade200,
        ),
        appBarTheme: AppBarTheme(
          brightness: Brightness.dark,
          color: Colors.pink.shade200,
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: Colors.pink[300],
          unselectedItemColor: Colors.grey[500],
        ),
        dividerColor: Colors.grey.shade200,
      );
}

class _BlackTheme extends _ThemePackage {
  @override
  String code() => "black";

  @override
  String name() => "酷黑";

  @override
  ThemeData themeData() =>
      ThemeData().copyWith(
        brightness: Brightness.light,
        colorScheme: ColorScheme.light(
          secondary: Colors.pink.shade200,
        ),
        appBarTheme: AppBarTheme(
          brightness: Brightness.dark,
          color: Colors.grey.shade800,
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey[400],
          backgroundColor: Colors.grey.shade800,
        ),
        dividerColor: Colors.grey.shade200,
      );
}

class _DarkTheme extends _ThemePackage {
  @override
  String code() => "dark";

  @override
  String name() => "暗黑";

  @override
  ThemeData themeData() =>
      ThemeData.dark().copyWith(
        colorScheme: ColorScheme.light(
          secondary: Colors.pink.shade200,
        ),
        appBarTheme: AppBarTheme(
          brightness: Brightness.dark,
          color: Color(0xFF1E1E1E),
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey.shade300,
          backgroundColor: Colors.grey.shade900,
        ),
      );
}

final _themePackages = <_ThemePackage>[
  _OriginTheme(),
  _PinkTheme(),
  _BlackTheme(),
  _DarkTheme(),
];

// 主题更换事件
var themeEvent = Event<EventArgs>();

int _androidVersion = 1;
String? _themeCode;
ThemeData? _themeData;
bool _androidNightMode = false;
bool _systemNight = false;

String currentThemeName() {
  for (var package in _themePackages) {
    if (_themeCode == package.code()) {
      return package.name();
    }
  }
  return "";
}

ThemeData? currentThemeData() {
  return (_androidNightMode && _systemNight)
      ? _themePackages[3].themeData()
      : _themeData;
}

// 根据Code选择主题, 并发送主题更换事件
void _changeThemeByCode(String themeCode) {
  for (var package in _themePackages) {
    if (themeCode == package.code()) {
      _themeCode = themeCode;
      _themeData = package.themeData();
      break;
    }
  }
  themeEvent.broadcast();
}

// 为了匹配安卓夜间模式增加的配置文件
const _nightModePropertyName = "androidNightMode";

Future<dynamic> initTheme() async {
  if (Platform.isAndroid) {
    _androidVersion = await pica.androidGetVersion();
    if (_androidVersion >= 29) {
      _androidNightMode =
          (await pica.loadProperty(_nightModePropertyName, "false")) == "true";
      _systemNight = (await pica.androidGetUiMode()) == "NIGHT";
      EventChannel("ui_mode").receiveBroadcastStream().listen((event) {
        _systemNight = "$event" == "NIGHT";
        themeEvent.broadcast();
      });
    }
  }
  _changeThemeByCode(await pica.loadTheme());
}

// 选择主题的对话框
Future<dynamic> chooseTheme(BuildContext buildContext) async {
  String? theme = await showDialog<String>(
    context: buildContext,
    builder: (BuildContext context) {
      return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            var list = <SimpleDialogOption>[];
            if (_androidVersion >= 29) {
              list.add(
                SimpleDialogOption(
                  child: Row(
                    children: [
                      Checkbox(
                          value: _androidNightMode,
                          onChanged: (bool? v) async {
                            if (v != null) {
                              await pica.saveProperty(
                                  _nightModePropertyName, "$v");
                              _androidNightMode = v;
                            }
                            setState(() {});
                            themeEvent.broadcast();
                          }),
                      Text("随手机进入夜间模式"),
                    ],
                  ),
                ),
              );
            }
            list.addAll(_themePackages
                .map((e) =>
                SimpleDialogOption(
                  child: Text(e.name()),
                  onPressed: () {
                    Navigator.of(context).pop(e.code());
                  },
                )
            ));
            return SimpleDialog(
              title: Text("选择主题"),
              children: list,
            );
          })
    },
  );
  if (theme != null) {
    pica.saveTheme(theme);
    _changeThemeByCode(theme);
  }
}
