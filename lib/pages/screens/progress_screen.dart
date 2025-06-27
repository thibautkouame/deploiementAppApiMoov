import 'package:fitness/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fitness/services/exercise_service.dart';
import 'package:fitness/services/auth_service.dart';
import 'package:fitness/models/exercise_history.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fitness/widgets/bottom_nav_widget.dart';
import 'package:fitness/pages/screens/home_screen.dart';
import 'package:fitness/pages/screens/stats_screen.dart';
import 'package:fitness/pages/screens/analysis_screen.dart';
import 'package:fitness/pages/screens/profile_screen.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final ExerciseService _exerciseService = ExerciseService();
  List<ExerciseHistory> allExercises = [];
  List<ExerciseHistory> filteredExercises = [];
  Map<String, int> exerciseStats = {};
  bool isLoading = true;
  late String selectedMonth;

  @override
  void initState() {
    super.initState();
    selectedMonth = _getCurrentMonth();
    _loadExerciseData();
    print("selectedMonth: $selectedMonth");
  }

  String _getCurrentMonth() {
    final months = ExerciseHistory.monthToNumber.keys.toList();
    final currentMonth = DateTime.now().month - 1; // 0 pour janvier, 11 pour décembre
    return months[currentMonth];
  }

  void _navigateToNextMonth() {
    final months = ExerciseHistory.monthToNumber.keys.toList();
    final currentIndex = months.indexOf(selectedMonth);
    final nextIndex = (currentIndex + 1) % months.length;
    
    setState(() {
      selectedMonth = months[nextIndex];
      _filterExercisesByMonth(selectedMonth);
    });
  }

  void _navigateToPreviousMonth() {
    final months = ExerciseHistory.monthToNumber.keys.toList();
    final currentIndex = months.indexOf(selectedMonth);
    final prevIndex = (currentIndex - 1 + months.length) % months.length;
    setState(() {
      selectedMonth = months[prevIndex];
      _filterExercisesByMonth(selectedMonth);
    });
  }

  Future<void> _loadExerciseData() async {
    try {
      final token = await AuthService.getToken();
      if (token != null) {
        final data = await _exerciseService.getExerciseHistory(token);
        print("dasssssssssssta: $data");
        setState(() {
          allExercises = _exerciseService.parseExerciseHistory(data);
          _filterExercisesByMonth(selectedMonth);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  void _filterExercisesByMonth(String month) {
    filteredExercises = allExercises
        .where((exercise) =>
            exercise.the_month == ExerciseHistory.monthToNumber[month])
        .toList();

    exerciseStats = {};
    for (var exercise in filteredExercises) {
      exerciseStats[exercise.exerciseTypeName] =
          (exerciseStats[exercise.exerciseTypeName] ?? 0) + 1;
    }
    setState(() {});
  }

  Map<String, double> calculateHealthStats() {
    if (filteredExercises.isEmpty) return {};

    double waterIntake = 0;
    double sleepHours = 0;
    double calories = 0;
    double heartRateImprovement = 0;
    int count = 0;

    for (var exercise in filteredExercises) {
      count++;
      waterIntake += double.parse(exercise.waterLiter);
      sleepHours += double.parse(exercise.sleepHours);
      calories += double.parse(exercise.calories);

      double heartRateBefore = double.parse(exercise.heartRateBefore);
      double heartRateAfter = double.parse(exercise.heartRateAfter);
      heartRateImprovement += (heartRateAfter - heartRateBefore);
    }

    if (count == 0) return {};

    return {
      'Consommation d\'eau (L)': waterIntake / count,
      'Heures de sommeil': sleepHours / count,
      'Calories consommées': calories / count,
      'Amélioration du rythme cardiaque': heartRateImprovement / count,
      'Nombre d\'exercices': count.toDouble(),
    };
  }

  Map<String, double> calculateSensationStats() {
    if (filteredExercises.isEmpty) return {};

    Map<String, int> sensationCounts = {'Bon': 0, 'Moyen': 0, 'Mauvais': 0};
    int totalExercises = filteredExercises.length;

    for (var exercise in filteredExercises) {
      sensationCounts[exercise.sensationBefore] =
          (sensationCounts[exercise.sensationBefore] ?? 0) + 1;
      sensationCounts[exercise.sensationDuring] =
          (sensationCounts[exercise.sensationDuring] ?? 0) + 1;
      sensationCounts[exercise.sensationAfter] =
          (sensationCounts[exercise.sensationAfter] ?? 0) + 1;
    }

    return {
      'Sensation Bonne':
          (sensationCounts['Bon'] ?? 0) / (totalExercises * 3) * 100,
      'Sensation Moyenne':
          (sensationCounts['Moyen'] ?? 0) / (totalExercises * 3) * 100,
      'Sensation Mauvaise':
          (sensationCounts['Mauvais'] ?? 0) / (totalExercises * 3) * 100,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(5.0),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      // En-tête fixe
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const Text(
                            'Mon profil',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          const CircleAvatar(
                            backgroundColor: AppColors.primary,
                            child: Icon(LucideIcons.user, color: Colors.white),
                          ),
                        ],
                      ),
                      // Contenu défilable
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  const Text(
                                    'Historiques de mon évolution',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 0),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      border:
                                          Border.all(color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    child: DropdownButton<String>(
                                      dropdownColor: Colors.white,
                                      value: selectedMonth,
                                      items: ExerciseHistory.monthToNumber.keys
                                          .map((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(
                                            value,
                                            style: const TextStyle(fontSize: 12),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) {
                                        if (newValue != null) {
                                          setState(() {
                                            selectedMonth = newValue;
                                            _filterExercisesByMonth(newValue);
                                          });
                                        }
                                      },
                                      underline: Container(),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                height: 200,
                                child: BarChart(
                                  BarChartData(
                                    alignment: BarChartAlignment.spaceAround,
                                    maxY: 90,
                                    minY: 0,
                                    barGroups: _createExerciseTypeBarGroups(),
                                    titlesData: FlTitlesData(
                                      show: true,
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          getTitlesWidget: (value, meta) {
                                            final titles =
                                                exerciseStats.keys.toList();
                                            if (value.toInt() < titles.length) {
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 8.0),
                                                child: Text(
                                                  titles[value.toInt()],
                                                  style: const TextStyle(
                                                      fontSize: 10),
                                                  textAlign: TextAlign.center,
                                                ),
                                              );
                                            }
                                            return const Text('');
                                          },
                                        ),
                                      ),
                                      leftTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 30,
                                          interval: 5,
                                          getTitlesWidget: (value, meta) {
                                            if (value == 0) return const Text('');
                                            return Text(
                                              value.toInt().toString(),
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      topTitles: const AxisTitles(
                                        sideTitles: SideTitles(showTitles: false),
                                      ),
                                      rightTitles: const AxisTitles(
                                        sideTitles: SideTitles(showTitles: false),
                                      ),
                                    ),
                                    gridData: FlGridData(
                                      show: true,
                                      drawVerticalLine: false,
                                      horizontalInterval: 5,
                                      getDrawingHorizontalLine: (value) {
                                        return FlLine(
                                          color: Colors.grey.withOpacity(0.2),
                                          strokeWidth: 1,
                                        );
                                      },
                                    ),
                                    borderData: FlBorderData(show: false),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 60),
                              SizedBox(
                                height: 200,
                                child: BarChart(
                                  BarChartData(
                                    alignment: BarChartAlignment.spaceAround,
                                    maxY: 90,
                                    minY: 0,
                                    barGroups: _createSensationBarGroups(),
                                    titlesData: FlTitlesData(
                                      show: true,
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          getTitlesWidget: (value, meta) {
                                            const titles = [
                                              'Sensation Bonne',
                                              'Sensation\nMoyenne',
                                              'Sensation\nMauvaise'
                                            ];
                                            if (value.toInt() < titles.length) {
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 8.0),
                                                child: Text(
                                                  titles[value.toInt()],
                                                  style: const TextStyle(
                                                      fontSize: 10),
                                                  textAlign: TextAlign.center,
                                                ),
                                              );
                                            }
                                            return const Text('');
                                          },
                                        ),
                                      ),
                                      leftTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 30,
                                          interval: 5,
                                          getTitlesWidget: (value, meta) {
                                            if (value == 0) return const Text('');
                                            return Text(
                                              value.toInt().toString(),
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      topTitles: const AxisTitles(
                                        sideTitles: SideTitles(showTitles: false),
                                      ),
                                      rightTitles: const AxisTitles(
                                        sideTitles: SideTitles(showTitles: false),
                                      ),
                                    ),
                                    gridData: FlGridData(
                                      show: true,
                                      drawVerticalLine: false,
                                      horizontalInterval: 5,
                                      getDrawingHorizontalLine: (value) {
                                        return FlLine(
                                          color: Colors.grey.withOpacity(0.2),
                                          strokeWidth: 1,
                                        );
                                      },
                                    ),
                                    borderData: FlBorderData(show: false),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 30),
                              SizedBox(
                                width: double.infinity,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: _navigateToPreviousMonth,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: const Text(
                                          'Mois précédent',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: _navigateToNextMonth,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: const Text(
                                          'Mois suivant',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavWidget(
        selectedIndex: 3,
        onItemSelected: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const StatsScreen()),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AnalysisScreen()),
            );
          } else if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          }
        },
      ),
    );
  }

  List<BarChartGroupData> _createExerciseTypeBarGroups() {
    final List<Color> colors = [
      Colors.orange,
      Colors.black,
      Colors.red,
      Colors.brown,
      Colors.blue,
      Colors.indigo,
      Colors.yellow,
      Colors.lightGreenAccent,
    ];

    return exerciseStats.entries.map((entry) {
      int index = exerciseStats.keys.toList().indexOf(entry.key);
      return createBarData(
        index.toDouble(),
        entry.value.toDouble(),
        colors[index % colors.length],
      );
    }).toList();
  }

  List<BarChartGroupData> _createHealthBarGroups() {
    final healthStats = calculateHealthStats();
    return healthStats.entries.map((entry) {
      int index = healthStats.keys.toList().indexOf(entry.key);
      return createBarData(
        index.toDouble(),
        entry.value,
        const Color(0xFF4CD964),
      );
    }).toList();
  }

  List<BarChartGroupData> _createSensationBarGroups() {
    final sensationStats = calculateSensationStats();
    return sensationStats.entries.map((entry) {
      int index = sensationStats.keys.toList().indexOf(entry.key);
      return createBarData(
        index.toDouble(),
        entry.value,
        const Color(0xFF4CD964),
      );
    }).toList();
  }

  BarChartGroupData createBarData(double x, double y, Color color) {
    return BarChartGroupData(
      x: x.toInt(),
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 16,
          borderRadius: const BorderRadius.all(Radius.circular(4)),
        ),
      ],
    );
  }
}
