import "dart:io";
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:sudoku/enums/sudoku_difficulty.dart';
import 'package:sudoku/classes/Sudoku.dart';
import 'package:sudoku/components/GameCell.dart';
import 'package:sudoku/components/DigitButton.dart';
import 'package:sudoku/main.dart';
import 'package:sudoku/views/AfterSolveSummary.dart';
import 'package:fluttertoast/fluttertoast.dart';

class GameBoardView extends StatefulWidget {
  final SudokuDifficulty difficulty;
  final bool valueChecking;

  GameBoardView({
    Key? key,
    required this.difficulty,
    required this.valueChecking,
  }) : super(key: key);

  @override
  State<GameBoardView> createState() =>
      _GameBoardView(difficulty: difficulty, valueChecking: valueChecking);
}

class _GameBoardView extends State<GameBoardView> with WidgetsBindingObserver {
  AppLifecycleState? _lastLifecycleState;
  DateTime startTime = DateTime.now();
  int minutes = 0;
  int seconds = 0;
  String playTime = "00:00";
  SudokuDifficulty difficulty;
  bool valueChecking;
  late Sudoku sudoku;
  int selectedX = 0;
  int selectedY = 0;
  int selectedValue = 0;
  int mistakes = 0;
  List<List<int>> mistakeCoordinates = [];
  late List<int> digitUsage;

  _GameBoardView({required this.difficulty, required this.valueChecking}) {
    sudoku = Sudoku(id: 1, difficulty: difficulty, checkingValues: true, solvedCallback: _onSolved);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _lastLifecycleState = state;
    });
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      print("Paused");
    } else if (state == AppLifecycleState.resumed) {
      print("Resumed");
    } else if (state == AppLifecycleState.detached) {
      print("Detached");
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  String levelName() {
    switch (difficulty) {
      case SudokuDifficulty.veryEasy:
        return "Bardzo łatwy";
        break;
      case SudokuDifficulty.easy:
        return "Łatwy";
        break;
      case SudokuDifficulty.medium:
        return "Średni";
        break;
      case SudokuDifficulty.hard:
        return "Trudny";
        break;
    }
  }

  void _onSolved() {
    // push route without possibility to go back
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => AfterSolveSummary(difficulty: difficulty, playTime: playTime, mistakes: mistakes)), (route) => false);
  }

  void _updateTime() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (_lastLifecycleState == AppLifecycleState.paused || _lastLifecycleState == AppLifecycleState.inactive) {
        return;
      }
      int tmpMinutes = minutes;
      int tmpSeconds = seconds;
      if (tmpSeconds == 59) {
        tmpMinutes++;
        tmpSeconds = 0;
      } else {
        tmpSeconds++;
      }
      String twoDigits(int n) => n.toString().padLeft(2, "0");
      String twoDigitMinutes = twoDigits(minutes);
      String twoDigitSeconds = twoDigits(seconds);
      setState(() {
        minutes = tmpMinutes;
        seconds = tmpSeconds;
        playTime = "$twoDigitMinutes:$twoDigitSeconds";
      });
    });
  }

  bool _isMisplaced(List<List<int>> list, int x, int y) {
    for (int i = 0; i < list.length; i++) {
      if (list[i][0] == x && list[i][1] == y) return true;
    }
    return false;
  }

  void _onCellTap(int x, int y) {
    setState(() {
      selectedX = x;
      selectedY = y;
      selectedValue = sudoku.playingBoard[x][y];
    });
    print("x: $selectedX, y: $selectedY");
  }

  void _onDigitTap(String value) {
    // If selectedValue in playingBoard is not 0 and is the same as in solvedBoard then don't allow changes
    bool isSelectedValueInPlayingBoard = sudoku.playingBoard[selectedX][selectedY] != 0;
    bool isSelectedValueSameAsInSolved = sudoku.isSameNumberAsInSolved(selectedX, selectedY, selectedValue);
    if (isSelectedValueInPlayingBoard && isSelectedValueSameAsInSolved) return;

    bool isSameNumberAsInSolved = sudoku.isSameNumberAsInSolved(selectedX, selectedY, int.parse(value));
    if (!isSameNumberAsInSolved) setState(() {
      mistakes = mistakes + 1;
      mistakeCoordinates = [...mistakeCoordinates, [selectedX, selectedY]];
    });
    else setState(() {
      mistakeCoordinates = mistakeCoordinates.where((element) => element[0] != selectedX && element[1] != selectedY).toList();
    });
    setState(() {
      sudoku.insertDigit(selectedX, selectedY, int.parse(value));
      digitUsage = sudoku.getDigitUsage();
    });
    _onCellTap(selectedX, selectedY);
  }

  void _onRemove() {
    bool isRemoved = false;
    setState(() {
      isRemoved = sudoku.removeValueIfNotSameAsInSolved(selectedX, selectedY);
    });
    mistakeCoordinates = mistakeCoordinates.where((element) => element[0] != selectedX && element[1] != selectedY).toList();
    _onCellTap(selectedX, selectedY);
    if (!isRemoved) {
      Fluttertoast.showToast(
          msg: "Nie można usunąć tej wartości",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Theme.of(context).colorScheme.error,
          textColor: Theme.of(context).colorScheme.onError,
          fontSize: 16.0
      );
    }
  }

  Widget PlayingBoard(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return MaterialApp(
        home: Scaffold(
            body: SafeArea(
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(children: [
                                  Text("Czas gry",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall),
                                  Text('$playTime',
                                      style:
                                      Theme.of(context).textTheme.bodyLarge)
                                ]),
                                Column(children: [
                                  Text("Poziom",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall),
                                  Text(levelName(),
                                      style:
                                      Theme.of(context).textTheme.bodyLarge)
                                ]),
                                Column(children: [
                                  Text("  Błędy  ",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall),
                                  Text(mistakes.toString(),
                                      style:
                                      Theme.of(context).textTheme.bodyLarge)
                                ])
                              ]),
                          const SizedBox(height: 16),
                          Container(
                            width: width,
                            height: width - 32.0,
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: Color.fromRGBO(0, 0, 0, 1.0),
                                    width: 1
                                )
                            ),
                            // child playingBoard
                            child: GridView.count(
                              crossAxisCount: 3,
                              physics: const NeverScrollableScrollPhysics(),
                              children: sudoku.getPlayingBoard().map((section) {
                                return Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Color.fromRGBO(0, 0, 0, 1.0),
                                          width: 1)),
                                  child: GridView.count(
                                    crossAxisCount: 3,
                                    physics: const NeverScrollableScrollPhysics(),
                                    children: section.map((value) {
                                      return Container(
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Color.fromRGBO(
                                                      187, 187, 187, 1.0),
                                                  width: 0.5)),
                                          child: GameCell(
                                            x: value[1],
                                            y: value[2],
                                            selectedX: selectedX,
                                            selectedY: selectedY,
                                            value: value[0],
                                            selectedValue: selectedValue,
                                            callback: _onCellTap,
                                            isMisplaced: _isMisplaced(mistakeCoordinates, value[1], value[2]),
                                          )
                                      );
                                    }).toList(),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () => _onRemove(),
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.delete,
                                        size: 40.0,
                                        color: Color.fromRGBO(0, 0, 0, 1.0),
                                      ),
                                      Text("Usuń",
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Color.fromRGBO(
                                                  0, 0, 0, 1.0
                                              )
                                          )
                                      )
                                    ],
                                  ),
                                )
                              )
                            ]
                          ),
                          const SizedBox(height: 16),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                DigitButton(value: "1", callback: _onDigitTap, usageCount: digitUsage[0]),
                                DigitButton(value: "2", callback: _onDigitTap, usageCount: digitUsage[1]),
                                DigitButton(value: "3", callback: _onDigitTap, usageCount: digitUsage[2]),
                                DigitButton(value: "4", callback: _onDigitTap, usageCount: digitUsage[3]),
                                DigitButton(value: "5", callback: _onDigitTap, usageCount: digitUsage[4]),
                                DigitButton(value: "6", callback: _onDigitTap, usageCount: digitUsage[5]),
                                DigitButton(value: "7", callback: _onDigitTap, usageCount: digitUsage[6]),
                                DigitButton(value: "8", callback: _onDigitTap, usageCount: digitUsage[7]),
                                DigitButton(value: "9", callback: _onDigitTap, usageCount: digitUsage[8]),
                              ]),
                          /*const Text("DEBUG Plansza rozwiązana:", style: TextStyle(fontSize: 16)),
                        Expanded(
                            child: GridView.count(
                              crossAxisCount: 1,
                              children: [Container(
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondaryContainer,
                                        width: 2)),
                                child: GridView.count(
                                  crossAxisCount: 3,
                                  children: sudoku.getBoard().map((section) {
                                    return Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondaryContainer,
                                              width: 2)),
                                      child: GridView.count(
                                        crossAxisCount: 3,
                                        children: section.map((value) {
                                          return Container(
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .secondaryContainer,
                                                      width: 1)),
                                              child: Center(
                                                  child: Text(
                                                    value == 0 ? " " : value.toString(),
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyLarge,
                                                  )));
                                        }).toList(),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              )],
                            )
                        )*/
                        ])))));
  }

  Widget paused(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Icon(
            Icons.pause_circle_filled,
            size: 100,
            color: Theme.of(context).colorScheme.primary,
          )
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          systemNavigationBarColor: Theme.of(context).colorScheme.background,
          systemNavigationBarIconBrightness: Brightness.light));
    }
    if (_lastLifecycleState == AppLifecycleState.paused || _lastLifecycleState == AppLifecycleState.inactive) {
      return paused(context);
    }
    else {
      return PlayingBoard(context);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    sudoku.fillSectionsDiagonal();
    sudoku.fillRecurrent(0, 3, sudoku.board);
    sudoku.removeDigitsBasedOnDifficulty();
    digitUsage = sudoku.setDigitUsage();
    _onCellTap(0, 0);
    _updateTime(); // Start the timer when the widget is created
  }
}
