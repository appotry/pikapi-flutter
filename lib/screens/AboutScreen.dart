import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pikapi/basic/Cross.dart';

class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var size = MediaQuery.of(context).size;
    var min = size.width < size.height ? size.width : size.height;

    final url = 'https://github.com/niuhuan/pikapi-flutter';

    return Scaffold(
      appBar: AppBar(
        title: Text('关于'),
      ),
      body: ListView(
        children: [
          Container(
            width: min / 2,
            height: min / 2,
            child: Center(
              child: SvgPicture.asset(
                'lib/assets/github.svg',
                width: min / 3,
                height: min / 3,
                color: Colors.grey.shade500,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(20),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '项目地址 : ',
                  ),
                  TextSpan(
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                    ),
                    text: url,
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => openUrl(url),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

