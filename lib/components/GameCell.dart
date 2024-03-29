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
    required this.selectedValue,
    required this.callback,
    required this.isMisplaced,
  }) : super(key: key);

  final int x;
  final int y;
  final Function callback;
  final int value;
  final int selectedValue;
  final int selectedX;
  final int selectedY;
  final bool isMisplaced;

  @override
  Widget build(BuildContext context) {
    bool isSelected = (x == selectedX && y == selectedY);
    bool isAxisSelected = (x == selectedX || y == selectedY);
    bool isSameSquare = (x ~/ 3 == selectedX ~/ 3 && y ~/ 3 == selectedY ~/ 3);
    ColorScheme colorScheme = ColorScheme.fromSeed(seedColor: Colors.blueGrey);

    return GestureDetector(
      onTap: () => callback(x, y),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Color.fromRGBO(255, 255, 255, 1.0),
            width: 0,
          ),
          color: isSelected
              ? isMisplaced
                  ? colorScheme.error
                  : Color.fromRGBO(139, 201, 246, 1.0)
              : isAxisSelected || isSameSquare
                  ? Color.fromRGBO(139, 201, 246, 0.2)
                  : selectedValue == value && value != 0
                      ? Color.fromRGBO(210, 246, 139, 0.2)
                      : Color.fromRGBO(255, 255, 255, 1.0)
        ),
        child: Center(
          child: Text(
            value == 0 ? "" : value.toString(),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: isMisplaced
                    ? isSelected
                        ? colorScheme.onError
                        : colorScheme.error
                    : isSelected
                        ? Colors.black
                        : selectedValue == value && value != 0
                            ? Color.fromRGBO(76, 77, 46, 1.0)
                            : colorScheme.onSurface),
          ),
        ),
      ),
    );
  }
}
