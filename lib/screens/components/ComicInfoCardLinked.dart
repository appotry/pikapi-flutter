import 'package:flutter/material.dart';
import 'package:pikapi/basic/Entities.dart';
import 'package:pikapi/screens/common/Navigatior.dart';

import '../ComicInfoScreen.dart';
import 'ComicInfoCard.dart';

class LinkedComicInfoCard extends StatelessWidget {
  final ComicSimple info;

  const LinkedComicInfoCard(this.info);

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () {
          navPushOrReplace(
            context,
            (context) => ComicInfoScreen(comicId: info.id),
          );
        },
        child: ComicInfoCard(info: info),
      );
}
