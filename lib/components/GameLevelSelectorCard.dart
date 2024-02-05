import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GameLevelSelectorCard extends StatelessWidget {
  const GameLevelSelectorCard(
      {Key? key, required this.title, required this.callback, this.color = const Color.fromRGBO(139, 201, 246, 1.0)})
      : super(key: key);
  final String title;
  final Function callback;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          systemNavigationBarColor: Theme.of(context).colorScheme.background,
          systemNavigationBarIconBrightness: Brightness.light));
    }
    return GestureDetector(
        onTap: () => callback(),
        child: Card(
            color: color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
              side: BorderSide(
                color: Colors.black,
                width: 2.0,
              ),
            ),
            child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(title,
                              style:
                                  Theme.of(context).textTheme.headlineMedium),
                        ],
                      ),
                      const Row(children: [
                        Icon(
                          Icons.arrow_right,
                          size: 40.0,
                        )
                      ])
                    ]))));
  }
}
