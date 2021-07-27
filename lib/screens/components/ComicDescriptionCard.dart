import 'package:flutter/material.dart';

class ComicDescriptionCard extends StatelessWidget {
  final String description;

  ComicDescriptionCard({Key? key, required this.description}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.only(
        top: 5,
        bottom: 5,
        left: 10,
        right: 10,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor,
          ),
        ),
      ),
      child: Text(description, style: _categoriesStyle),
    );
  }
}

const _categoriesStyle = TextStyle(
  fontSize: 13,
  color: Colors.grey,
);
