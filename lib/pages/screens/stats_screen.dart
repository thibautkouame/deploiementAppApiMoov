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
import 'package:fitness/services/auth_service.dart';
import 'package:fitness/pages/loginsignup.dart';
import 'package:fitness/widgets/bottom_nav_widget.dart';
import 'package:fitness/pages/screens/profile_screen.dart';

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
    _checkToken();
    _fetchData();
  }

  Future<void> _checkToken() async {
    final token = await AuthService.getToken();
    if (token == null || token.isEmpty) {
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginSignupPage()),
          (route) => false,
        );
      }
    }
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
      if (e.toString().contains('401') || e.toString().toLowerCase().contains('unauthorized')) {
        await AuthService.removeToken();
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginSignupPage()),
            (route) => false,
          );
        }
        return;
      }
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Color> getExerciseColors(String exerciseType) {
    // Générer une couleur unique basée sur le nom de l'exercice
    final hash = exerciseType.hashCode;
    final hue = (hash % 360).toDouble(); // Valeur entre 0 et 360 pour le teinte
    final saturation = 0.7; // Saturation fixe à 70%
    final lightness = 0.5; // Luminosité fixe à 50%

    // Convertir HSL en RGB
    final h = hue / 360;
    final s = saturation;
    final l = lightness;

    double r, g, b;

    if (s == 0) {
      r = g = b = l;
    } else {
      final hue2rgb = (double p, double q, double t) {
        if (t < 0) t += 1;
        if (t > 1) t -= 1;
        if (t < 1/6) return p + (q - p) * 6 * t;
        if (t < 1/2) return q;
        if (t < 2/3) return p + (q - p) * (2/3 - t) * 6;
        return p;
      };

      final q = l < 0.5 ? l * (1 + s) : l + s - l * s;
      final p = 2 * l - q;

      r = hue2rgb(p, q, h + 1/3);
      g = hue2rgb(p, q, h);
      b = hue2rgb(p, q, h - 1/3);
    }

    final color = Color.fromRGBO(
      (r * 255).round(),
      (g * 255).round(),
      (b * 255).round(),
      1,
    );

    return [color, color.withOpacity(0.5)];
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
                  Center(child: Text('Erreur ici : $_error'))
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
      // bottomNavigationBar: BottomNavWidget(
      //   selectedIndex: 1,
      //   onItemSelected: (index) {
      //     if (index == 0) {
      //       Navigator.pushReplacement(
      //         context,
      //         MaterialPageRoute(builder: (context) => const HomeScreen()),
      //       );
      //     } else if (index == 1) {
      //       Navigator.pushReplacement(
      //         context,
      //         MaterialPageRoute(builder: (context) => const StatsScreen()),
      //       );
      //     } else if (index == 2) {
      //       Navigator.pushReplacement(
      //         context,
      //         MaterialPageRoute(builder: (context) => const AnalysisScreen()),
      //       );
      //     } else if (index == 3) {
      //       Navigator.pushReplacement(
      //         context,
      //         MaterialPageRoute(builder: (context) => const ProfileScreen()),
      //       );
      //     }
      //   },
      // ),
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
    final scoreAnalysis = _statistics['score_analysis'] as Map<String, dynamic>?;
    final currentTotalScore = scoreAnalysis?['current_total_score'] ?? 0;
    final targetTotalScore = scoreAnalysis?['target_score'] ?? 0;
    final estimatedCompletionDate = scoreAnalysis?['estimated_completion_date'] ?? '';
    final progressPercentage = scoreAnalysis?['progress_percentage'] ?? 0;
    final totalEndurance = _statistics['total_endurance'] ?? 0;
    final totalRegularity = _statistics['total_regularity'] ?? 0;
    final averageAbility = _statistics['average_ability'] ?? 0;
    final averageEndurance = _statistics['average_endurance'] ?? 0;
    final averageRegularity = _statistics['average_regularity'] ?? 0;
    final estimated_months_to_target = scoreAnalysis?['estimated_months_to_target'] ?? 'Reviens plus tard';

    String getEstimatedMonth() {
      if (estimatedCompletionDate.isEmpty || estimatedCompletionDate == '0') {
        // Ajouter 3 mois à la date actuelle
        final now = DateTime.now();
        // Gérer le cas où l'addition des mois dépasse 12
        int newMonth = now.month + 3;
        int newYear = now.year;
        if (newMonth > 12) {
          newYear += (newMonth ~/ 12);
          newMonth = newMonth % 12;
          if (newMonth == 0) newMonth = 12;
        }
        final futureDate = DateTime(newYear, newMonth, now.day);
        return DateFormat('MMMM', 'fr_FR').format(futureDate);
      }
      return _formatDate(estimatedCompletionDate).split(' ')[1];
    }

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
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                targetTotalScore == null || targetTotalScore == 0
                  ? 'Commence un exercice pour estimer ton évolution !'
                  : 'Vous trouverez ci-joint votre évolution. Maintenez cette fréquence pour une progression constante !',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Text('Votre progression actuelle',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
        
              _buildStatRow('Moyenne Capacité', '${averageAbility}/10'),
              const SizedBox(height: 12),
              _buildStatRow('Moyenne Endurance', '${averageEndurance}/10'),
              const SizedBox(height: 12),
              _buildStatRow('Moyenne Régularité', '${averageRegularity}/10'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: const Color(0xFF232B34), // fond sombre
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: 2,
                minY: 0,
                maxY: [averageAbility, averageEndurance, averageRegularity].reduce((a, b) => a > b ? a : b) * 1.3 + 10,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.white.withOpacity(0.08),
                    strokeWidth: 1,
                  ),
                  getDrawingVerticalLine: (value) => FlLine(
                    color: Colors.white.withOpacity(0.08),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const Text('0', style: TextStyle(color: Colors.white70, fontSize: 12));
                        if (value >= 1000) return Text('${(value/1000).toStringAsFixed(0)}k', style: const TextStyle(color: Colors.white70, fontSize: 12));
                        return Text(value.toInt().toString(), style: const TextStyle(color: Colors.white70, fontSize: 12));
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        switch (value.toInt()) {
                          case 0:
                            // return const Text('Régularité', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold));
                          case 1:
                            // return const Text('Capacité', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold));
                          case 2:
                            // return const Text('Endurance', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold));
                          default:
                            return const SizedBox.shrink();
                        }
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      FlSpot(0, averageRegularity is num ? averageRegularity.toDouble() : 0.0),
                      FlSpot(1, averageAbility is num ? averageAbility.toDouble() : 0.0),
                      FlSpot(2, averageEndurance is num ? averageEndurance.toDouble() : 0.0),
                    ],
                    isCurved: true,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00C6FB), Color(0xFF005BEA)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    barWidth: 5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF00C6FB).withOpacity(0.3),
                          const Color(0xFF005BEA).withOpacity(0.1),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMMM yyyy', 'fr_FR').format(date);
    } catch (e) {
      return dateStr;
    }
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
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child:
            (mostFrequentExercise == null || mostFrequentExercise.isEmpty)
              ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Image.asset(
                          'assets/images/training_2.png',
                          height: 150,
                          width: 150,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Faites un exercice pour voir',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                      ),
                    ],
                  )
                )
              : RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Nous avons remarqué que tu as effectué un grand nombre d\'exercices axés sur ',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                      ),
                      TextSpan(
                        text: mostFrequentExercise,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: Colors.black87,
                          height: 1.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: ' ! Pour un entraînement équilibré, nous vous suggérons d\'ajouter d\'autres types d\'exercices à ta routine.',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                      ),
                    ],
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