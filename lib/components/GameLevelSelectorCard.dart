import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GameLevelSelectorCard extends StatelessWidget {
  const GameLevelSelectorCard({Key? key, required this.title, required this.callback}) : super(key: key);
  final String title;
  final Function callback;

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          systemNavigationBarColor: Theme.of(context).colorScheme.background,
          systemNavigationBarIconBrightness: Brightness.light));
    }
    return Card(
        color: Theme.of(context).colorScheme.tertiaryContainer,
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text("Prosty", style: Theme.of(context).textTheme.headlineMedium),
                    ],
                  ),
                  const Row(
                      children: [
                        Icon(Icons.arrow_right, size: 40.0,)
                      ]
                  )
                ]
            )
        )
    );
  }
}