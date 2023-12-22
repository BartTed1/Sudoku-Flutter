import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';

class GameCell extends StatelessWidget {
  const GameCell({
    Key? key,
    required this.x,
    required this.y,
    required this.selectedX,
    required this.selectedY,
    required this.value,
    required this.callback,
    required this.isMisplaced,
  }) : super(key: key);

  final int x;
  final int y;
  final Function callback;
  final int value;
  final int selectedX;
  final int selectedY;
  final bool isMisplaced;

  @override
  Widget build(BuildContext context) {
    bool isSelected = (x == selectedX && y == selectedY);
    bool isAxisSelected = (x == selectedX || y == selectedY);
    ColorScheme colorScheme = ColorScheme.fromSeed(seedColor: Colors.deepPurple);

    return GestureDetector(
      onTap: () => callback(x, y),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Color.fromRGBO(255, 255, 255, 1.0),
            width: 0,
          ),
          color: isSelected
              ? colorScheme.primaryContainer
              : isAxisSelected
                  ? colorScheme.surface
                  : Color.fromRGBO(255, 255, 255, 1.0)
        ),
        child: Center(
          child: Text(
            value == 0 ? "" : value.toString(),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: isMisplaced
                    ? Color.fromRGBO(255, 0, 0, 1.0)
                    : colorScheme.onBackground),
          ),
        ),
      ),
    );
  }
}
