import 'package:flutter/material.dart';
import 'package:sudoku/enums/sudoku_difficulty.dart';
import 'package:sudoku/main.dart';

class AfterSolveSummary extends StatelessWidget {
  final SudokuDifficulty difficulty;
  final String playTime;
  final int mistakes;

  const AfterSolveSummary({Key? key, required this.difficulty, required this.playTime, required this.mistakes}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Gratulacje!", style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 16),
            Text("Udało Ci się rozwiązać ${difficulty.nameToSudokuPL} Sudoku!", style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            Text("Twój czas: $playTime", style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            Text("Liczba błędów: $mistakes", style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => MyHomePage(title: "Sudoku")), (route) => false),
              child: Text("Powrót do menu"),
            )
          ],
        ),
      ),
    );
  }

}