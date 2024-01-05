import 'package:flutter/material.dart';
import 'package:sudoku/enums/sudoku_difficulty.dart';
import 'package:sudoku/views/GameBoardView.dart';

class LoadingView extends StatefulWidget {
  final SudokuDifficulty difficulty;
  final bool valueChecking;

  const LoadingView({Key? key, required this.difficulty, required this.valueChecking}) : super(key: key);

  @override
  _LoadingViewState createState() => _LoadingViewState(difficulty: difficulty, valueChecking: valueChecking);
}

class _LoadingViewState extends State<LoadingView> {
  final SudokuDifficulty difficulty;
  final bool valueChecking;

  _LoadingViewState({required this.difficulty, required this.valueChecking}) : super();

  @override
  void initState() {
    super.initState();
    _loadGameBoardView();
  }

  Future<void> _loadGameBoardView() async {
    await Future.delayed(Duration(milliseconds: 500));
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => GameBoardView(
          difficulty: widget.difficulty,
          valueChecking: widget.valueChecking,
        ),
      ), (route) => false
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
            child: Text(
              "Ładowanie...",
              style: Theme.of(context).textTheme.headlineMedium,
            )
        ),
      ),
    );
  }
}