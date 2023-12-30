import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sudoku/components/GameLevelSelectorCard.dart';
import 'package:sudoku/views/GameBoardView.dart';
import 'package:sudoku/enums/sudoku_difficulty.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sudoku',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Sudoku'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  // constructor
  const MyHomePage({super.key, required this.title});

  // fields
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          systemNavigationBarColor: Theme.of(context).colorScheme.background,
          systemNavigationBarIconBrightness: Brightness.light));
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Center(
            child: Text(
              widget.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ),
      ),
      body: Padding(
          padding: const EdgeInsets.all(12),
          child: SingleChildScrollView(
              child: Column(
            children: [
              GameLevelSelectorCard(
                  title: "Bardzo łatwy",
                  callback: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => GameBoardView(difficulty: SudokuDifficulty.veryEasy, valueChecking: true)))),
              const SizedBox(height: 16),
              GameLevelSelectorCard(
                  title: "Łatwy",
                  callback: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => GameBoardView(difficulty: SudokuDifficulty.easy, valueChecking: true)))),
              const SizedBox(height: 16),
              GameLevelSelectorCard(
                  title: "Średni",
                  callback: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => GameBoardView(difficulty: SudokuDifficulty.medium, valueChecking: true)))),
              const SizedBox(height: 16),
              GameLevelSelectorCard(
                  title: "Trudny",
                  callback: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => GameBoardView(difficulty: SudokuDifficulty.hard, valueChecking: true)))),
    ],
          ))),
    );
  }
}
