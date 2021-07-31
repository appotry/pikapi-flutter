import 'package:flutter/material.dart';

class ItemBuilder<T> extends StatelessWidget {
  final Future<T> future;
  final AsyncWidgetBuilder<T> successBuilder;
  final Future<dynamic> Function() onRefresh;

  const ItemBuilder({
    Key? key,
    required this.future,
    required this.successBuilder,
    required this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        var width = constraints.maxWidth;
        return FutureBuilder(
            future: future,
            builder: (BuildContext context, AsyncSnapshot<T> snapshot) {
              if (snapshot.hasError) {
                return InkWell(
                  onTap: onRefresh,
                  child: Container(
                    width: width,
                    height: width / 2,
                    child: Center(
                      child: Icon(Icons.sync_problem, size: width / 3),
                    ),
                  ),
                );
              }
              if (snapshot.connectionState != ConnectionState.done) {
                return Container(
                  width: width,
                  height: width / 2,
                  child: Center(
                    child: Icon(Icons.sync, size: width / 3),
                  ),
                );
              }
              return Container(
                width: width,
                child: successBuilder(context, snapshot),
              );
            });
      },
    );
  }
}
