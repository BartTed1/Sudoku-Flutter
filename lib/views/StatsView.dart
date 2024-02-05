import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StatsView extends StatefulWidget {
  @override
  _StatsViewState createState() => _StatsViewState();
}

class _StatsViewState extends State<StatsView> {
  late Future<List<Map<String, dynamic>>> statsData;

  @override
  void initState() {
    super.initState();
    statsData = retrieveStatsData();
  }

  Future<List<Map<String, dynamic>>> retrieveStatsData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> stats = [];

    for (var difficulty in ['veryEasy', 'easy', 'medium', 'hard']) {
      String? playTime = prefs.getString('sudoku$difficulty' + 'playTime');
      String? mistakes = prefs.getString('sudoku$difficulty' + 'mistakes');
      String? hints = prefs.getString('sudoku$difficulty' + 'hints');

      if (playTime != null && mistakes != null && hints != null) {
        stats.add({
          'difficulty': getDifficultyName(difficulty),
          'playTime': playTime,
          'mistakes': mistakes,
          'hints': hints,
        });
      }
      else {
        stats.add({
          'difficulty': getDifficultyName(difficulty),
          'playTime': '-',
          'mistakes': '-',
          'hints': '-',
        });
      }
    }

    return stats;
  }
  
  String getDifficultyName(String difficulty) {
    switch (difficulty) {
      case 'veryEasy':
        return 'Bardzo łatwy';
      case 'easy':
        return 'Łatwy';
      case 'medium':
        return 'Średni';
      case 'hard':
        return 'Trudny';
      default:
        return 'Bardzo łatwy';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Statystyki gier'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: statsData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 24.0,
                columns: const <DataColumn>[
                  DataColumn(
                    label: Text(
                      'Poziom trudności',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Czas gry',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Błędy',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Podpowiedzi',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
                rows: snapshot.data!.map<DataRow>((row) {
                  return DataRow(
                    cells: <DataCell>[
                      DataCell(Text(row['difficulty'])),
                      DataCell(Text(row['playTime'])),
                      DataCell(Text(row['mistakes'])),
                      DataCell(Text(row['hints'])),
                    ],
                  );
                }).toList(),
              ),
            );
          }
        },
      ),
    );
  }
}