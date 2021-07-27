import 'package:flutter/material.dart';

class ComicTagsCard extends StatelessWidget {
  final List<String> tags;

  const ComicTagsCard({Key? key, required this.tags}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.only(top: 5, bottom: 5),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor,
          ),
        ),
      ),
      child: Wrap(
        children: tags.map((e) {
          return Container(
            padding: EdgeInsets.only(
              left: 10,
              right: 10,
              top: 3,
              bottom: 3,
            ),
            margin: EdgeInsets.only(
              left: 5,
              right: 5,
              top: 3,
              bottom: 3,
            ),
            decoration: BoxDecoration(
              color: Colors.pink.shade100,
              border: Border.all(
                style: BorderStyle.solid,
                color: Colors.pink.shade400,
              ),
              borderRadius: BorderRadius.all(Radius.circular(30)),
            ),
            child: Text(
              e,
              style: TextStyle(
                color: Colors.pink.shade500,
                height: 1.4,
              ),
              strutStyle: StrutStyle(
                height: 1.4,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
