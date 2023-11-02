import 'package:sudoku/errors/ValueExistsException.dart';

class GameFieldSection {
  final Map<String, int?> section;

  const GameFieldSection (this.section);

  isValueExists(int value) {
    for (var element in section.values) {
      if (element == value) return true;
    }
    return false;
  }
}