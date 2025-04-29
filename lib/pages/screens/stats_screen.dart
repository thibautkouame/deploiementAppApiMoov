import 'package:flutter/material.dart';
import 'package:fitness/models/exercise_stats.dart';
import 'package:fitness/services/stats_service.dart';
import 'package:fitness/theme/theme.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:fitness/pages/screens/home_screen.dart';
import 'package:fitness/pages/screens/analysis_screen.dart';
import 'package:google_fonts/google_fonts.dart';
class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  Map<String, List<dynamic>> _history = {};
  Map<String, dynamic> _statistics = {};
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('fr_FR');
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final response = await StatsService.fetchStats();
      
      setState(() {
        _history = (response['history'] as Map<String, dynamic>?)?.map(
          (key, value) => MapEntry(key, value as List<dynamic>)
        ) ?? {};
        _statistics = (response['statistics'] as Map<String, dynamic>?) ?? {};
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Color> getExerciseColors(String exerciseType) {
    switch (exerciseType.toLowerCase()) {
      case 'jogging':
        return [Colors.blue, Colors.blue.withOpacity(0.5)];
      case 'marcher':
        return [Colors.green, Colors.green.withOpacity(0.5)];
      case 'tirer':
        return [Colors.red, Colors.red.withOpacity(0.5)];
      case 'saut':
        return [Colors.orange, Colors.orange.withOpacity(0.5)];
      default:
        return [Colors.purple, Colors.purple.withOpacity(0.5)];
    }
  }

  List<LineChartBarData> _generateLineBars() {
    final now = DateTime.now();
    final dateStr = DateFormat('yyyy-MM-dd').format(now);
    
    if (!_history.containsKey(dateStr)) {
      return [];
    }

    final dayStats = _history[dateStr]!;
    final exerciseTypeCounts = <String, int>{};
    
    // Compter le nombre de fois que chaque type d'exercice apparaît
    for (var stat in dayStats) {
      final type = stat['exercise_type_name'] as String;
      exerciseTypeCounts[type] = (exerciseTypeCounts[type] ?? 0) + 1;
    }

    // Créer les lignes empilées
    double previousValue = 0;
    return exerciseTypeCounts.entries.map((entry) {
      final colors = getExerciseColors(entry.key);
      final value = entry.value.toDouble();

      return LineChartBarData(
        spots: [
          FlSpot(0, previousValue),
          FlSpot(1, previousValue),
          FlSpot(2, previousValue + value),
          FlSpot(3, previousValue + value),
          FlSpot(4, previousValue),
        ],
        isCurved: true,
        gradient: LinearGradient(colors: colors),
        barWidth: 0,
        isStrokeCapRound: true,
        dotData: FlDotData(show: false),
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            colors: colors.map((color) => color.withOpacity(0.5)).toList(),
          ),
        ),
      );
    }).toList().reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
               Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
                    },
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Text(
                    'Statistiques d\'activité',
                    style: GoogleFonts.poppins(
                      fontSize: 20, 
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              
                const SizedBox(height: 24),
                Text(
                  'Aujourd\'hui',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (_error.isNotEmpty)
                  Center(child: Text(_error))
                else
                  Column(
                    children: [
                      Container(
                        height: 300,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(show: true),
                            minY: 0,
                            maxY: 10, // Ajusté pour le nombre d'exercices
                            minX: 0,
                            maxX: 4,
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    if (value % 1 == 0 && value >= 0 && value <= 10) {
                                      return Text(
                                        value.toInt().toString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      );
                                    }
                                    return const Text('');
                                  },
                                  reservedSize: 30,
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            lineBarsData: _generateLineBars(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildExerciseLegend(),
                      const SizedBox(height: 32),
                      _buildPredictionSection(),
                      // const SizedBox(height: 32),
                      _buildAdviceSection(),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseLegend() {
    final now = DateTime.now();
    final dateStr = DateFormat('yyyy-MM-dd').format(now);
    if (!_history.containsKey(dateStr)) return const SizedBox.shrink();

    final dayStats = _history[dateStr]!;
    final exerciseTypes = <String>{};
    for (var stat in dayStats) {
      exerciseTypes.add(stat['exercise_type_name'] as String);
    }

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: exerciseTypes.map((type) {
        final colors = getExerciseColors(type);
        return _buildLegendItem(type, colors.first);
      }).toList(),
    );
  }

  Widget _buildLegendItem(String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildPredictionSection() {
    final exerciseTypes = _statistics['exercise_types'] as Map<String, dynamic>?;
    int totalExercises = 0;
    
    if (exerciseTypes != null) {
      exerciseTypes.forEach((type, count) {
        totalExercises += count as int;
      });
    }
    
    final monthsToReach = _statistics['months_to_reach'] ?? 5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Prédiction',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Vous atteindrez un niveau d\'endurance de $totalExercises d\'ici $monthsToReach mois. Essayez de maintenir votre fréquence pour voir ce résultat !',
          style: GoogleFonts.poppins(
            fontSize: 15,
            color: Colors.black87,
                          height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
          ),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: [
                    const FlSpot(0, 20),
                    const FlSpot(1, 25),
                    const FlSpot(2, 35),
                    const FlSpot(3, 40),
                    const FlSpot(4, 50),
                    const FlSpot(5, 60),
                    FlSpot(6, totalExercises.toDouble()),
                  ],
                  isCurved: true,
                  gradient: LinearGradient(
                    colors: [Colors.orange, Colors.red],
                  ),
                  barWidth: 4,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        Colors.orange.withOpacity(0.3),
                        Colors.red.withOpacity(0.3),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdviceSection() {
    final exerciseTypes = _statistics['exercise_types'] as Map<String, dynamic>?;
    String mostFrequentExercise = '';
    int maxCount = 0;

    if (exerciseTypes != null) {
      exerciseTypes.forEach((type, count) {
        if (count > maxCount) {
          maxCount = count;
          mostFrequentExercise = type;
        }
      });
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 150,
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(16),
          
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
                color: AppColors.primary,
            ),
            child: Text(
               textAlign: TextAlign.center,
              'Nos Conseils',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          // padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            
          ),
          child: Text(
            'Nous avons remarqué que tu as effectué un grand nombre d\'exercices axés sur $mostFrequentExercise ! Pour un entraînement équilibré, nous vous suggérons d\'ajouter d\'autres types d\'exercices à ta routine.',
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        ),

        const SizedBox(height: 16),
         Center(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AnalysisScreen ()),
              );
            },
            child: Container(
              width: 150,
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: AppColors.primary,
              ),
              child: Text(
                'Suivant',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
} 