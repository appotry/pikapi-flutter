import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('关于'),
      ),
      body: ListView(
        children: [
          Text.rich(TextSpan(
            children: [
              TextSpan(text: '项目地址 : '),
              WidgetSpan(
                child: InkWell(
                  child: Text('https://github.com/niuhuan/pikapi-flutter'),
                ),
              ),
            ],
          )),
        ],
      ),
    );
  }
}
