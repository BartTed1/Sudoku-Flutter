import 'package:flutter/material.dart';
import 'package:sudoku/enums/sudoku_difficulty.dart';
import 'package:sudoku/main.dart';
import 'package:sudoku/components/GameLevelSelectorCard.dart';

class AfterSolveSummary extends StatelessWidget {
  final SudokuDifficulty difficulty;
  final String playTime;
  final int mistakes;
  final int hints;

  const AfterSolveSummary({Key? key, required this.difficulty, required this.playTime, required this.mistakes, required this.hints}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(139, 201, 246, 1.0),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Center(
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
              Text("Liczba wykorzystanych podpowiedzi: $hints", style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 48),
              GameLevelSelectorCard(title: "Powrót do menu", color: Colors.white, callback: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const MyApp()))),
            ],
          ),
        ),
      )
    );
  }
}