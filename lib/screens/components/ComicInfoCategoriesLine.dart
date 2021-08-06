import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pikapi/screens/common/Navigatior.dart';

import '../ComicsScreen.dart';

class ComicInfoCategoriesLine extends StatelessWidget {
  final List<String> categories;

  const ComicInfoCategoriesLine(this.categories);

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: '分类 :'),
          ...categories.map(
            (e) => TextSpan(
              children: [
                TextSpan(text: ' '),
                TextSpan(
                  text: e,
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => navPushOrReplace(
                          context,
                          (context) => ComicsScreen(
                            category: e,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
      style: TextStyle(
        fontSize: 13,
        color: Theme.of(context).textTheme.bodyText1!.color!.withAlpha(0xCC),
      ),
    );
  }
}
