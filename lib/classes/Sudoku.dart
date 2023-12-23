import 'dart:math';
import 'package:sudoku/enums/sudoku_difficulty.dart';

class Sudoku {
  final int id;
  final SudokuDifficulty difficulty;
  final bool checkingValues;

  List<List<int>> board = [
    [0, 0, 0, 0, 0, 0, 0, 0, 0], // 0
    [0, 0, 0, 0, 0, 0, 0, 0, 0], // 1
    [0, 0, 0, 0, 0, 0, 0, 0, 0], // 2
    [0, 0, 0, 0, 0, 0, 0, 0, 0], // 3
    [0, 0, 0, 0, 0, 0, 0, 0, 0], // 4
    [0, 0, 0, 0, 0, 0, 0, 0, 0], // 5
    [0, 0, 0, 0, 0, 0, 0, 0, 0], // 6
    [0, 0, 0, 0, 0, 0, 0, 0, 0], // 7
    [0, 0, 0, 0, 0, 0, 0, 0, 0]  // 8
  ];
  List<List<int>> playingBoard = [];
  List<int> digitUsage = [0, 0, 0, 0, 0, 0, 0, 0, 0];

  Sudoku(
      {required this.id,
        required this.difficulty,
        required this.checkingValues});

  void fillSectionsDiagonal() {
    int j = 0;
    int k = 3;
    List<int> digitsToUse = [1, 2, 3, 4, 5, 6, 7, 8, 9];
    List<int> usedDigits = [];
    for (int i = 0; i < 9; i++) {
      while (j < k) {
        int index = Random().nextInt(digitsToUse.length);
        int digit = digitsToUse[index];
        digitsToUse.removeAt(index);
        board[i][j] = digit;
        usedDigits.add(digit);
        j++;
      }
      if (j == k && i < 2) {
        j = 0;
      } else if (j == k && i > 1 && i < 5) {
        j = 3;
      } else if (j == k && i > 4) {
        j = 6;
      }

      if (i == 2 || i == 5) {
        usedDigits.clear();
        digitsToUse = [1, 2, 3, 4, 5, 6, 7, 8, 9];
        k += 3;
      }
    }
  }

  void removeDigitsBasedOnDifficulty() {
    int digitsToRemove = 0;
    switch (difficulty) {
      case SudokuDifficulty.easy:
        digitsToRemove = Random().nextInt(6) + 30;
        break;
      case SudokuDifficulty.medium:
        digitsToRemove = Random().nextInt(6) + 40;
        break;
      case SudokuDifficulty.hard:
        digitsToRemove = Random().nextInt(6) + 50;
        break;
    }

    List<List<int>> tmpBoard = List<List<int>>.from(board.map((row) => List<int>.from(row)));
    int removedDigits = 0;
    List<List<int>> coordinates = [];

    while (digitsToRemove > removedDigits) {
      int row = Random().nextInt(9);
      int column = Random().nextInt(9);
      int originalValue = tmpBoard[row][column];

      if (originalValue == 0) continue;

      coordinates.add([row, column]);
      tmpBoard[row][column] = 0;
      List<List<int>> tmpPlayingBoard = List<List<int>>.from(tmpBoard.map((row) => List<int>.from(row)));
      bool isSolvable = fillRecurrent(row, column, tmpPlayingBoard);
      if (isSolvable) removedDigits++;
      else removedDigits--;
    }

    playingBoard = tmpBoard;
  }

  /**
   * Perform only after fillSectionsDiagonal()
   */
  bool fillRecurrent(int i, int j, List<List<int>> gameBoard) {
    if (i == 9) return true;
    else if (j == 9) return fillRecurrent(i + 1, 0, gameBoard);
    else if (gameBoard[i][j] != 0) return fillRecurrent(i, j + 1, gameBoard);

    for (int digit = 1; digit <= 9; digit++) {
      if (isCorrect(i, j, digit, gameBoard)) {
        gameBoard[i][j] = digit;
        if (fillRecurrent(i, j + 1, gameBoard)) {
          return true;
        }
        gameBoard[i][j] = 0;
      }
    }
    return false;
  }

  bool isCorrect(int row, int column, int digit, List<List<int>> gameBoard) {
    if (checkingValues) {
      if (checkRow(row, digit, gameBoard) &&
          checkColumn(column, digit, gameBoard) &&
          checkSection(row, column, digit, gameBoard)
      ) {
        return true;
      } else {
        return false;
      }
    } else {
      return true;
    }
  }

  bool isSameNumberAsInSolved(int row, int column, int digit) {
    if (board[row][column] == digit) {
      return true;
    } else {
      return false;
    }
  }

  bool checkRow(int row, int digit, List<List<int>> gameBoard) {
    for (int i = 0; i < 9; i++) {
      if (gameBoard[row][i] == digit) {
        return false;
      }
    }
    return true;
  }

  bool checkColumn(int column, int digit, List<List<int>> gameBoard) {
    for (int i = 0; i < 9; i++) {
      if (gameBoard[i][column] == digit) {
        print("W kolumnie $column w wierszu $i jest cyfra $digit");
        return false;
      }
    }
    print("W kolumnie $column nie ma cyfry $digit");
    return true;
  }

  bool checkSection(int row, int column, int digit, List<List<int>> gameBoard) {
    int sectionRow = row ~/ 3;
    int sectionColumn = column ~/ 3;
    for (int i = sectionRow * 3; i < sectionRow * 3 + 3; i++) {
      for (int j = sectionColumn * 3; j < sectionColumn * 3 + 3; j++) {
        if (gameBoard[i][j] == digit) {
          return false;
        }
      }
    }
    return true;
  }

  List<List<List<int>>> getPlayingBoard() {
    List<List<List<int>>> tmp = [
        [
          [playingBoard[0][0], 0, 0], [playingBoard[0][1], 0, 1], [playingBoard[0][2], 0, 2],
          [playingBoard[1][0], 1, 0], [playingBoard[1][1], 1, 1], [playingBoard[1][2], 1, 2],
          [playingBoard[2][0], 2, 0], [playingBoard[2][1], 2, 1], [playingBoard[2][2], 2, 2]
        ],
        [
          [playingBoard[0][3], 0, 3], [playingBoard[0][4], 0, 4], [playingBoard[0][5], 0, 5],
          [playingBoard[1][3], 1, 3], [playingBoard[1][4], 1, 4], [playingBoard[1][5], 1, 5],
          [playingBoard[2][3], 2, 3], [playingBoard[2][4], 2, 4], [playingBoard[2][5], 2, 5]
        ],
        [
          [playingBoard[0][6], 0, 6], [playingBoard[0][7], 0, 7], [playingBoard[0][8], 0, 8],
          [playingBoard[1][6], 1, 6], [playingBoard[1][7], 1, 7], [playingBoard[1][8], 1, 8],
          [playingBoard[2][6], 2, 6], [playingBoard[2][7], 2, 7], [playingBoard[2][8], 2, 8]
        ],
        [
          [playingBoard[3][0], 3, 0], [playingBoard[3][1], 3, 1], [playingBoard[3][2], 3, 2],
          [playingBoard[4][0], 4, 0], [playingBoard[4][1], 4, 1], [playingBoard[4][2], 4, 2],
          [playingBoard[5][0], 5, 0], [playingBoard[5][1], 5, 1], [playingBoard[5][2], 5, 2]
        ],
        [
          [playingBoard[3][3], 3, 3], [playingBoard[3][4], 3, 4], [playingBoard[3][5], 3, 5],
          [playingBoard[4][3], 4, 3], [playingBoard[4][4], 4, 4], [playingBoard[4][5], 4, 5],
          [playingBoard[5][3], 5, 3], [playingBoard[5][4], 5, 4], [playingBoard[5][5], 5, 5]
        ],
        [
          [playingBoard[3][6], 3, 6], [playingBoard[3][7], 3, 7], [playingBoard[3][8], 3, 8],
          [playingBoard[4][6], 4, 6], [playingBoard[4][7], 4, 7], [playingBoard[4][8], 4, 8],
          [playingBoard[5][6], 5, 6], [playingBoard[5][7], 5, 7], [playingBoard[5][8], 5, 8]
        ],
        [
          [playingBoard[6][0], 6, 0], [playingBoard[6][1], 6, 1], [playingBoard[6][2], 6, 2],
          [playingBoard[7][0], 7, 0], [playingBoard[7][1], 7, 1], [playingBoard[7][2], 7, 2],
          [playingBoard[8][0], 8, 0], [playingBoard[8][1], 8, 1], [playingBoard[8][2], 8, 2]
        ],
        [
          [playingBoard[6][3], 6, 3], [playingBoard[6][4], 6, 4], [playingBoard[6][5], 6, 5],
          [playingBoard[7][3], 7, 3], [playingBoard[7][4], 7, 4], [playingBoard[7][5], 7, 5],
          [playingBoard[8][3], 8, 3], [playingBoard[8][4], 8, 4], [playingBoard[8][5], 8, 5]
        ],
        [
          [playingBoard[6][6], 6, 6], [playingBoard[6][7], 6, 7], [playingBoard[6][8], 6, 8],
          [playingBoard[7][6], 7, 6], [playingBoard[7][7], 7, 7], [playingBoard[7][8], 7, 8],
          [playingBoard[8][6], 8, 6], [playingBoard[8][7], 8, 7], [playingBoard[8][8], 8, 8]
        ]
    ];
    return tmp;
  }

  List<List<int>> getBoard() {
    List<List<int>> board = [
      [
        this.board[0][0], this.board[0][1], this.board[0][2],
        this.board[1][0], this.board[1][1], this.board[1][2],
        this.board[2][0], this.board[2][1], this.board[2][2]
      ],
      [
        this.board[0][3], this.board[0][4], this.board[0][5],
        this.board[1][3], this.board[1][4], this.board[1][5],
        this.board[2][3], this.board[2][4], this.board[2][5]
      ],
      [
        this.board[0][6], this.board[0][7], this.board[0][8],
        this.board[1][6], this.board[1][7], this.board[1][8],
        this.board[2][6], this.board[2][7], this.board[2][8]
      ],
      [
        this.board[3][0], this.board[3][1], this.board[3][2],
        this.board[4][0], this.board[4][1], this.board[4][2],
        this.board[5][0], this.board[5][1], this.board[5][2]
      ],
      [
        this.board[3][3], this.board[3][4], this.board[3][5],
        this.board[4][3], this.board[4][4], this.board[4][5],
        this.board[5][3], this.board[5][4], this.board[5][5]
      ],
      [
        this.board[3][6], this.board[3][7], this.board[3][8],
        this.board[4][6], this.board[4][7], this.board[4][8],
        this.board[5][6], this.board[5][7], this.board[5][8]
      ],
      [
        this.board[6][0], this.board[6][1], this.board[6][2],
        this.board[7][0], this.board[7][1], this.board[7][2],
        this.board[8][0], this.board[8][1], this.board[8][2]
      ],
      [
        this.board[6][3], this.board[6][4], this.board[6][5],
        this.board[7][3], this.board[7][4], this.board[7][5],
        this.board[8][3], this.board[8][4], this.board[8][5]
      ],
      [
        this.board[6][6], this.board[6][7], this.board[6][8],
        this.board[7][6], this.board[7][7], this.board[7][8],
        this.board[8][6], this.board[8][7], this.board[8][8]
      ]
    ];
    return board;
  }

  void insertDigit(int x, int y, int digit) {
    playingBoard[x][y] = digit;
    digitUsage = setDigitUsage();
  }

  List<int> setDigitUsage() {
    List<int> tmpDigitUsage = [0, 0, 0, 0, 0, 0, 0, 0, 0];
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        if (playingBoard[i][j] != 0 && playingBoard[i][j] == board[i][j]) {
          tmpDigitUsage[playingBoard[i][j] - 1]++;
        }
      }
    }
    digitUsage = tmpDigitUsage;
    return tmpDigitUsage;
  }

  List<int> getDigitUsage() {
    return digitUsage;
  }
}