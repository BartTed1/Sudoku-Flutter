import "dart:io";
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:sudoku/enums/sudoku_difficulty.dart';
import 'package:sudoku/classes/Sudoku.dart';

class GameBoardView extends StatefulWidget {
  final SudokuDifficulty difficulty;
  final bool valueChecking;

  GameBoardView({
    Key? key,
    required this.difficulty,
    required this.valueChecking,
  }) : super(key: key);

  @override
  State<GameBoardView> createState() => _GameBoardView(difficulty: difficulty, valueChecking: valueChecking);
}

class _GameBoardView extends State<GameBoardView> {
  DateTime startTime = DateTime.now();
  String playTime = "00:00";
  SudokuDifficulty difficulty;
  bool valueChecking;
  late Sudoku sudoku;

  _GameBoardView({required this.difficulty, required this.valueChecking}) {
    sudoku = Sudoku(id: 1, difficulty: difficulty, checkingValues: true);
  }

  String levelName() {
    switch (difficulty) {
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

  void _updateTime() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      Duration diff = DateTime.now().difference(startTime);
      String twoDigits(int n) => n.toString().padLeft(2, "0");
      String twoDigitMinutes = twoDigits(diff.inMinutes.remainder(60));
      String twoDigitSeconds = twoDigits(diff.inSeconds.remainder(60));
      setState(() {
        playTime = "$twoDigitMinutes:$twoDigitSeconds";
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          systemNavigationBarColor: Theme.of(context).colorScheme.background,
          systemNavigationBarIconBrightness: Brightness.light));
    }
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
                                  style: Theme.of(context).textTheme.bodySmall),
                              Text('$playTime',
                                  style: Theme.of(context).textTheme.bodyLarge)
                            ]),
                            Column(children: [
                              Text("Poziom",
                                  style: Theme.of(context).textTheme.bodySmall),
                              Text(levelName(),
                                  style: Theme.of(context).textTheme.bodyLarge)
                            ]),
                            Column(children: [
                              Text("  Błędy  ",
                                  style: Theme.of(context).textTheme.bodySmall),
                              Text("0",
                                  style: Theme.of(context).textTheme.bodyLarge)
                            ])
                          ]),
                        const SizedBox(height: 16),
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
                                  children: sudoku.getPlayingBoard().map((section) {
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
                        ),
                        const Text("DEBUG Plansza rozwiązana:", style: TextStyle(fontSize: 16)),
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
                        )
                    ])))));
  }

  @override
  void initState() {
    super.initState();
    _updateTime(); // Start the timer when the widget is created
    sudoku.fillSectionsDiagonal();
    sudoku.fillRecurrent(0, 3, sudoku.board);
    sudoku.removeDigitsBasedOnDifficulty();
  }
}
