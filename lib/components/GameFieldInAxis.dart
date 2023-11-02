class GameFieldInAxis {
  Map<String, int?> axis;

  GameFieldInAxis(this.axis);

  bool isValueExists(int value) {
    for (var element in axis.values) {
      if (element == value) return true;
    }
    return false;
  }
}