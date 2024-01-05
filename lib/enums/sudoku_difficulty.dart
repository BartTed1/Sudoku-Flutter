enum SudokuDifficulty { veryEasy, easy, medium, hard }

extension SudokuDifficultyExtension on SudokuDifficulty {
  String get name {
    switch (this) {
      case SudokuDifficulty.veryEasy:
        return "Bardzo łatwy";
      case SudokuDifficulty.easy:
        return "Łatwy";
      case SudokuDifficulty.medium:
        return "Średni";
      case SudokuDifficulty.hard:
        return "Trudny";
      default:
        return "Bardzo łatwy";
    }
  }

  String get nameToSudokuPL {
    switch (this) {
      case SudokuDifficulty.veryEasy:
        return "bardzo łatwe";
      case SudokuDifficulty.easy:
        return "łatwe";
      case SudokuDifficulty.medium:
        return "średnio skomplikowane";
      case SudokuDifficulty.hard:
        return "trudne";
      default:
        return "bardzo łatwe";
    }
  }
}