import 'package:flutter/material.dart';

class ItemBuilder<T> extends StatelessWidget {
  final Future<T> future;
  final AsyncWidgetBuilder<T> successBuilder;
  final Future<dynamic> Function() onRefresh;
  final double? loadingHeight;

  const ItemBuilder({
    Key? key,
    required this.future,
    required this.successBuilder,
    required this.onRefresh,
    this.loadingHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        var width = constraints.maxWidth;
        var height = loadingHeight ?? (width / 2);
        return FutureBuilder(
            future: future,
            builder: (BuildContext context, AsyncSnapshot<T> snapshot) {
              if (snapshot.hasError) {
                return InkWell(
                  onTap: onRefresh,
                  child: Container(
                    width: width,
                    height: height,
                    child: Center(
                      child: Icon(Icons.sync_problem, size: height / 1.5),
                    ),
                  ),
                );
              }
              if (snapshot.connectionState != ConnectionState.done) {
                return Container(
                  width: width,
                  height: height,
                  child: Center(
                    child: Icon(Icons.sync, size: height / 1.5),
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
