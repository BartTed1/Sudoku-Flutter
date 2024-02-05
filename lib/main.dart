import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sudoku/components/GameLevelSelectorCard.dart';
import 'package:sudoku/views/GameBoardView.dart';
import 'package:sudoku/enums/sudoku_difficulty.dart';
import 'package:sudoku/views/LoadingView.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:sudoku/views/StatsView.dart';

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
  bool isUnsolvedGame = false;
  late GameBoardView previousGame;
  String? sudokuJsonVal = "";

  Future<void> checkUnsolvedGames() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? sudokuJson = prefs.getString("sudoku");
    sudokuJsonVal = sudokuJson;
    if (sudokuJson != null) {
      Map<String, dynamic> sudokuMap = jsonDecode(sudokuJson);
      previousGame = GameBoardView.gameFromJson(sudokuMap);
      setState(() {
        isUnsolvedGame = true;
      });
      return;
    }
    setState(() {
      isUnsolvedGame = false;
    });
    return;
  }

  @override
  Widget build(BuildContext context) {
    checkUnsolvedGames();
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  height: 45.0,
                  width: 45.0,
                ),
                const SizedBox(width: 16),
                Text(
                  widget.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
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
                        title: "Twoje wyniki",
                        callback: () => Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => StatsView())),
                        color: Color.fromRGBO(255, 255, 255, 1.0),
                      ),
                      const SizedBox(height: 32),
                      Text("Nowa gra:", style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 16),
                      GameLevelSelectorCard(
                          title: "Bardzo łatwy",
                          callback: () => Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => LoadingView(difficulty: SudokuDifficulty.veryEasy, valueChecking: true)))),
                      const SizedBox(height: 16),
                      GameLevelSelectorCard(
                          title: "Łatwy",
                          callback: () => Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => LoadingView(difficulty: SudokuDifficulty.easy, valueChecking: true)))),
                      const SizedBox(height: 16),
                      GameLevelSelectorCard(
                          title: "Średni",
                          callback: () => Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => LoadingView(difficulty: SudokuDifficulty.medium, valueChecking: true)))),
                      const SizedBox(height: 16),
                      GameLevelSelectorCard(
                          title: "Trudny",
                          callback: () => Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => LoadingView(difficulty: SudokuDifficulty.hard, valueChecking: true)))),
                      const SizedBox(height: 32),
                      isUnsolvedGame ?
                          Text("Lub wznów grę:", style: Theme.of(context).textTheme.titleLarge)
                          : const SizedBox(),
                      const SizedBox(height: 16),
                      Text(sudokuJsonVal ?? "", style: Theme.of(context).textTheme.labelSmall),
                      isUnsolvedGame
                          ? GameLevelSelectorCard(
                              title: "Wznów grę",
                              callback: () => Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => previousGame
                              )),
                              color: Color.fromRGBO(210, 246, 139, 1.0))
                          : const SizedBox(),
            ],
          ))),
    );
  }
}
