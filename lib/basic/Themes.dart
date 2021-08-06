import 'package:event/event.dart';
import 'package:flutter/material.dart';

class ThemeEventArgs extends EventArgs {
  ThemeData? themeData;

  ThemeEventArgs(this.themeData);
}

abstract class ThemePackage {
  String code();

  String name();

  ThemeData themeData();
}

class _OriginTheme extends ThemePackage {
  @override
  String code() => "origin";

  @override
  String name() => "原生";

  @override
  ThemeData themeData() => ThemeData();
}

class _PinkTheme extends ThemePackage {
  @override
  String code() => "pink";

  @override
  String name() => "粉色";

  @override
  ThemeData themeData() => ThemeData().copyWith(
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

class _BlackTheme extends ThemePackage {
  @override
  String code() => "black";

  @override
  String name() => "酷黑";

  @override
  ThemeData themeData() => ThemeData().copyWith(
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

class _DarkTheme extends ThemePackage {
  @override
  String code() => "dark";

  @override
  String name() => "暗黑";

  @override
  ThemeData themeData() => ThemeData.dark().copyWith(
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

final themePackages = <ThemePackage>[
  _OriginTheme(),
  _PinkTheme(),
  _BlackTheme(),
  _DarkTheme(),
];

var themeEvent = Event<ThemeEventArgs>();

changeThemeByCode(String themeCode) {
  for (var package in themePackages) {
    if (themeCode == package.code()) {
      themeEvent.broadcast(ThemeEventArgs(package.themeData()));
      return;
    }
  }
  themeEvent.broadcast(ThemeEventArgs(ThemeData()));
}

String themeName(String themeCode) {
  for (var package in themePackages) {
    if (themeCode == package.code()) {
      return package.name();
    }
  }
  return "";
}

Future<String?> chooseTheme(BuildContext buildContext) async {
  return await showDialog<String>(
    context: buildContext,
    builder: (BuildContext context) {
      return SimpleDialog(
        title: Text("选择主题"),
        children: themePackages
            .map((e) => SimpleDialogOption(
                  child: Text(e.name()),
                  onPressed: () {
                    Navigator.of(context).pop(e.code());
                  },
                ))
            .toList(),
      );
    },
  );
}
