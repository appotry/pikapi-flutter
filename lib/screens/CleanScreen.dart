import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pikapi/basic/Channels.dart';
import 'package:pikapi/service/pica.dart';

import 'components/ContentLoading.dart';

class CleanScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CleanScreenState();
}

class _CleanScreenState extends State<CleanScreen> {
  
  late bool _cleaning = false;
  late String _cleaningMessage = "清理中";
  late String _cleanResult = "";
  late StreamSubscription ls;

  void _onMessageChange(event) {
    if (event is String) {
      setState(() {
        _cleaningMessage = event;
      });
    }
  }

  @override
  void initState() {
    ls = eventChannel.receiveBroadcastStream(
        {"function": "EXPORT", "id": "DEFAULT"}).listen(_onMessageChange);
    super.initState();
  }

  @override
  void dispose() {
    ls.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    if (_cleaning) {
      return Scaffold(
        body: ContentLoading(label: _cleaningMessage),
      );
    }
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          MaterialButton(
            onPressed: () async {
              try {
                setState(() {
                  _cleaning = true;
                });
                await pica.clean();
                setState(() {
                  _cleanResult = "清理成功";
                });
              } catch (e) {
                setState(() {
                  _cleanResult = "清理失败 $e";
                });
              } finally {
                setState(() {
                  _cleaning = false;
                });
              }
            },
            child: Container(
              padding: EdgeInsets.all(20),
              child: Text('清理'),
            ),
          ),
          Container(
            padding: EdgeInsets.all(8),
            child: _cleanResult != "" ? Text(_cleanResult) : Container(),
          )
        ],
      ),
    );
  }
}
