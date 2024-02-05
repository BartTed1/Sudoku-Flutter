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
import 'package:sudoku/classes/CircleClipper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameBoardView extends StatefulWidget {
  final SudokuDifficulty difficulty;
  final bool valueChecking;
  final List<List<int>>? board;
  final List<List<int>>? playingBoard;
  final int mistakes;
  final List<List<int>> mistakeCoordinates;
  final int hints;
  final String playTime;
  final int minutes;
  final int seconds;

  GameBoardView({
    Key? key,
    required this.difficulty,
    required this.valueChecking,
    this.board,
    this.playingBoard,
    this.mistakes = 0,
    this.mistakeCoordinates = const [],
    this.hints = 0,
    this.playTime = "00:00",
    this.minutes = 0,
    this.seconds = 0
  }) : super(key: key);

  static GameBoardView gameFromJson(Map<String, dynamic> json) {
    return GameBoardView(
        difficulty: SudokuDifficultyExtension.fromString(json['difficulty'].split('.').last),
        valueChecking: json['checkingValues'],
        board: convertDynamicListToListOfLists(json['board']),
        playingBoard: convertDynamicListToListOfLists(json['playingBoard']),
        mistakes: json['mistakes'],
        mistakeCoordinates: convertDynamicListToListOfLists(json['mistakeCoordinates']),
        hints: json['hints'],
        playTime: json['playTime'],
        minutes: json['minutes'],
        seconds: json['seconds']
    );
  }

  static List<List<int>> convertDynamicListToListOfLists(List<dynamic> dynamicList) {
    return dynamicList.map<List<int>>((dynamic sublist) {
      if (sublist is List) {
        // Cast each element in the sublist to int
        return sublist.cast<int>().toList();
      } else {
        // Handle cases where sublist is not a List
        throw ArgumentError('Invalid sublist type: ${sublist.runtimeType}');
      }
    }).toList();
  }

  @override
  State<GameBoardView> createState() =>
      _GameBoardView(
          difficulty: difficulty,
          valueChecking: valueChecking,
          board: board,
          playingBoard: playingBoard,
          mistakes: mistakes,
          mistakeCoordinates: mistakeCoordinates,
          hints: hints,
          playTime: playTime,
          minutes: minutes,
          seconds: seconds
      );
}

class _GameBoardView extends State<GameBoardView> with WidgetsBindingObserver {
  AppLifecycleState? _lastLifecycleState;
  DateTime startTime = DateTime.now();
  int minutes;
  int seconds;
  String playTime;
  SudokuDifficulty difficulty;
  bool valueChecking;
  late Sudoku sudoku;
  int selectedX = 0;
  int selectedY = 0;
  int selectedValue = 0;
  int mistakes;
  int hints;
  List<List<int>> mistakeCoordinates;
  late List<int> digitUsage;

  _GameBoardView({
    required this.difficulty,
    required this.valueChecking,
    required List<List<int>>? board,
    required List<List<int>>? playingBoard,
    required this.mistakes,
    required this.mistakeCoordinates,
    required this.hints,
    required this.playTime,
    required this.minutes,
    required this.seconds
  }) {
    if (board != null && playingBoard != null) {
      sudoku = Sudoku.fromSavedGame(
          id: 1,
          difficulty: difficulty,
          board: board,
          playingBoard: playingBoard,
          checkingValues: valueChecking,
          solvedCallback: _onSolved
      );
      print(sudoku);
    } else {
      sudoku = Sudoku(id: 1,
          difficulty: difficulty,
          checkingValues: true,
          solvedCallback: _onSolved);
      sudoku.fillSectionsDiagonal();
      sudoku.fillRecurrent(0, 3, sudoku.board);
      sudoku.removeDigitsBasedOnDifficulty();
    }
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

  Future<void> _onSolved() async {
    // remove solved game from memory
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("sudoku");

    // save stats to memory
    await _saveStatsToMemory();

    // push route without possibility to go back
    Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => AfterSolveSummary(difficulty: difficulty, playTime: playTime, mistakes: mistakes, hints: hints),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                return ClipOval(
                  clipper: CircleClipper(animation.value),
                  child: child,
                );
              },
              child: child,
            );
          },
          transitionDuration: Duration(milliseconds: 200),
        ),
            (route) => false
    );
  }

  Future<void> _saveStatsToMemory() async {
    String sudokuDifficulty = difficulty.name;
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // get stats from memory
    String playTime = await _retrieveStatsFromMemory(sudokuDifficulty, "playTime");
    String mistakes = await _retrieveStatsFromMemory(sudokuDifficulty, "mistakes");
    String hints = await _retrieveStatsFromMemory(sudokuDifficulty, "hints");

    // calculate average time
    if (playTime == "") prefs.setString("sudoku$sudokuDifficulty$playTime", playTime);
    else {
      int playSeconds = int.parse(playTime.split(":")[0]) * 60 + int.parse(playTime.split(":")[1]);
      int currentSeconds = minutes * 60 + seconds;
      int avgSeconds = (playSeconds + currentSeconds) ~/ 2;
      String avgTime = "${(avgSeconds / 60).floor()}:${avgSeconds % 60}";
      prefs.setString("sudoku$sudokuDifficulty$playTime", avgTime);
    }

    // calculate average mistakes
    if (mistakes == "") prefs.setString("sudoku$sudokuDifficulty$mistakes", mistakes);
    else {
      int avgMistakes = (int.parse(mistakes) + int.parse(mistakes)) ~/ 2;
      prefs.setString("sudoku$sudokuDifficulty$mistakes", avgMistakes.toString());
    }

    // calculate average hints
    if (hints == "") prefs.setString("sudoku$sudokuDifficulty$hints", hints);
    else {
      int avgHints = (int.parse(hints) + int.parse(hints)) ~/ 2;
      prefs.setString("sudoku$sudokuDifficulty$hints", avgHints.toString());
    }
  }

  Future<String> _retrieveStatsFromMemory(String difficulty, String stat) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? stats = prefs.getString("sudoku$difficulty$stat");
    if (stats != null) return stats;
    return "";
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
    sudoku.saveToMemory(playTime: playTime, minutes: minutes, seconds: seconds, mistakes: mistakes, mistakeCoordinates: mistakeCoordinates, hints: hints);
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
          msg: "Nie można usunąć poprawnej wartości",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 2,
          backgroundColor: Theme.of(context).colorScheme.error,
          textColor: Theme.of(context).colorScheme.onError,
          fontSize: 16.0
      );
    }
    sudoku.saveToMemory(playTime: playTime, minutes: minutes, seconds: seconds, mistakes: mistakes, mistakeCoordinates: mistakeCoordinates, hints: hints);
  }

  void _onHint() {
    if (sudoku.playingBoard[selectedX][selectedY] == sudoku.board[selectedX][selectedY]) return; // jezeli dobrze rozwiązane to nie dawaj podpowiedzi
    setState(() {
      sudoku.insertDigit(selectedX, selectedY, sudoku.board[selectedX][selectedY]);
      digitUsage = sudoku.getDigitUsage();
    });
    hints = hints + 1;
    mistakeCoordinates = mistakeCoordinates.where((element) => element[0] != selectedX && element[1] != selectedY).toList();
    _onCellTap(selectedX, selectedY);
    sudoku.saveToMemory(playTime: playTime, minutes: minutes, seconds: seconds, mistakes: mistakes, mistakeCoordinates: mistakeCoordinates, hints: hints);
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
                                ]),
                                Column(children: [
                                  Text("  Podpowiedzi  ",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall),
                                  Text(hints.toString(),
                                      style:
                                      Theme.of(context).textTheme.bodyLarge)
                                ]),
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
                          const SizedBox(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              GestureDetector(
                                onTap: () => _onRemove(),
                                child: Container(
                                  width: 90,
                                  height: 90,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.delete_outline,
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
                              ),
                              GestureDetector(
                                  onTap: () => _onHint(),
                                  child: Container(
                                    width: 90,
                                    height: 90,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.lightbulb_outline,
                                          size: 40.0,
                                          color: Color.fromRGBO(0, 0, 0, 1.0),
                                        ),
                                        Text("Podpowiedź",
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
                              ),
                            ]
                          ),
                          const SizedBox(height: 64),
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
            color: Color.fromRGBO(139, 201, 246, 1.0),
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
    digitUsage = sudoku.setDigitUsage();
    _onCellTap(0, 0);
    _updateTime(); // Start the timer when the widget is created
  }
}
