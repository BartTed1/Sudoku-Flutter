import 'package:flutter/material.dart';

class DigitButton extends StatelessWidget {
  const DigitButton({Key? key, required this.value, required this.callback, required this.usageCount})
      : super(key: key);

  final String value;
  final Function callback;
  final int usageCount;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => callback(value),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Color.fromRGBO(255, 255, 255, 1.0),
            width: 0,
          ),
          color: Color.fromRGBO(255, 255, 255, 1.0),
        ),
        child: Center(
          child: Text(
            usageCount == 9 ? " " : value.toString(),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
      ),
    );
  }
}