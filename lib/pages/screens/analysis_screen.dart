import 'package:flutter/material.dart';
import 'package:fitness/services/auth_service.dart';
import 'package:fitness/services/exercise_service.dart';
import 'package:fitness/models/exercise_history.dart';
import 'package:fitness/theme/theme.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:fitness/pages/loginsignup.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  final ExerciseService _exerciseService = ExerciseService();
  DateTime selectedDate = DateTime.now();
  List<ExerciseHistory> exerciseHistory = [];
  List<ExerciseHistory> currentDayExercises = [];
  int currentExerciseIndex = 0;
  ExerciseHistory? currentDayStats;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkToken();
    _loadExerciseData();
    // Désactiver le chargement après 10 secondes
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
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

  Future<void> _loadExerciseData() async {
    try {
      final token = await AuthService.getToken();
      if (token != null) {
        final data = await _exerciseService.getExerciseHistory(token);
        print('Raw data from API: $data');
        final history = _exerciseService.parseExerciseHistory(data);
        print('Parsed history length: ${history.length}');
        if (history.isNotEmpty) {
          print('First history item: ${history.first.toMap()}');
        }
        setState(() {
          exerciseHistory = history;
          _updateCurrentDayStats();
        });
      }
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
      print('Error loading exercise data: $e');
    }
  }

  void _updateCurrentDayStats() {
    final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    print('Searching for stats on: $formattedDate');
    print('Available history items: ${exerciseHistory.length}');
    
    try {
      currentDayExercises = exerciseHistory.where(
        (stats) {
          final exerciseDate = DateFormat('yyyy-MM-dd').format(DateTime.parse(stats.date));
          return exerciseDate == formattedDate;
        }
      ).toList();

      print('Found ${currentDayExercises.length} exercises for selected date');

      if (currentDayExercises.isEmpty) {
        print('No exercises found for selected date, creating empty stats');
        currentDayStats = ExerciseHistory(
          id: '',
          userId: '',
          waterLiter: '0',
          sleepHours: '0',
          calories: '0',
          bloodPressureBefore: '0/0',
          sensationBefore: '',
          heartRateBefore: '0',
          systolicPressureBefore: '0',
          diastolicPressureBefore: '0',
          systolicPressureAfter: '0',
          diastolicPressureAfter: '0',
          duration: '0',
          repetition: '0',
          caloriesBurned: '0',
          sensationAfter: '',
          sensationDuring: '',
          bloodPressureAfter: '0/0',
          heartRateAfter: '0',
          the_day: selectedDate.day.toString(),
          the_month: selectedDate.month.toString(),
          the_year: selectedDate.year.toString(),
          date: selectedDate.toIso8601String(),
          exerciseTypeName: '',
        );
        currentExerciseIndex = 0;
      } else {
        currentExerciseIndex = 0;
        currentDayStats = currentDayExercises[currentExerciseIndex];
        print('Selected exercise stats: ${currentDayStats?.toMap()}');
      }
      
      setState(() {});
    } catch (e) {
      print('Error updating current day stats: $e');
    }
  }

  void _nextExercise() {
    setState(() {
      if (currentDayExercises.length == 1) {
        // Si c'est un seul exercice, on vide la liste pour afficher le message
        currentDayExercises = [];
        currentDayStats = null;
      } else if (currentDayExercises.length > 1) {
        currentExerciseIndex = (currentExerciseIndex + 1) % currentDayExercises.length;
        currentDayStats = currentDayExercises[currentExerciseIndex];
      }
    });
  }

  Widget _buildDateSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('MMMM yyyy', 'fr_FR').format(selectedDate).replaceFirstMapped(RegExp(r'^\w'), (match) => match.group(0)!.toUpperCase()),
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            'Rapport d\'aujourd\'hui',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                10,
                (index) {
                  final date = DateTime.now().add(Duration(days: index - 5));
                  final isSelected = DateFormat('dd', 'fr_FR').format(date) == DateFormat('dd', 'fr_FR').format(selectedDate);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedDate = date;
                        _updateCurrentDayStats();
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.black : AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            DateFormat('E', 'fr_FR').format(date)[0].toUpperCase(),
                            style: GoogleFonts.poppins(color: Colors.white),
                          ),
                          Text(
                            DateFormat('dd', 'fr_FR').format(date),
                            style: GoogleFonts.poppins(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerContainer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        height: 100,
      ),
    );
  }

  Widget _buildPreExerciseIndicators() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Indicateurs avant exercice',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          if (isLoading)
            _buildShimmerContainer()
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Type d\'exercice: ${currentDayStats?.exerciseTypeName ?? 'Aucun'}',
                style: GoogleFonts.poppins(
                  color: Colors.green.shade900,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: isLoading
                    ? _buildShimmerContainer()
                    : Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Durée de sommeil', style: GoogleFonts.poppins(color: Colors.black, fontSize: 11.5),),
                            Text(
                              '${currentDayStats?.sleepHours ?? '0'}H',
                              style: GoogleFonts.poppins(color: Colors.black, fontSize: 27),
                            ),
                          ],
                        ),
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: isLoading
                    ? _buildShimmerContainer()
                    : Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.water_drop, color: Colors.blue),
                                Text('L\'eau', style: GoogleFonts.poppins(color: Colors.black, fontSize: 11.5),),
                              ],
                            ),
                            Text(
                              '${double.tryParse(currentDayStats?.waterLiter ?? '0')?.toStringAsFixed(1)}L',
                              style: GoogleFonts.poppins(color: Colors.black, fontSize: 27),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: isLoading
                    ? _buildShimmerContainer()
                    : Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.local_fire_department, color: Colors.orange),
                                Text('Calorie \n absorbée', style: GoogleFonts.poppins(color: Colors.black, fontSize: 11.5),),
                              ],
                            ),
                            Text(
                              '${double.tryParse(currentDayStats?.calories ?? '0')?.toStringAsFixed(0)}kcal',
                              style: GoogleFonts.poppins(color: Colors.black, fontSize: 27),
                            ),
                          ],
                        ),
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: isLoading
                    ? _buildShimmerContainer()
                    : Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Pression \n artérielle avant', style: GoogleFonts.poppins(color: Colors.black, fontSize: 11.5),),
                            Text(
                              currentDayStats?.bloodPressureBefore ?? '0/0',
                              style: GoogleFonts.poppins(color: Colors.black, fontSize: 27),
                            ),
                            Text('mmHg', style: GoogleFonts.poppins(color: Colors.black, fontSize: 11.5),),
                          ],
                        ),
                      ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: isLoading
                    ? _buildShimmerContainer()
                    : Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.local_fire_department, color: Colors.orange),
                                Text('Pression \n systolique \n avant', style: GoogleFonts.poppins(color: Colors.black, fontSize: 11.5),),
                              ],
                            ),
                            Text(
                              '${currentDayStats?.systolicPressureBefore ?? '0'}',
                              style: GoogleFonts.poppins(color: Colors.black, fontSize: 27),
                            ),
                          ],
                        ),
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: isLoading
                    ? _buildShimmerContainer()
                    : Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Pression \n diastolique \n avant', style: GoogleFonts.poppins(color: Colors.black, fontSize: 11.5),),
                            Text(
                              currentDayStats?.diastolicPressureBefore ?? '0',
                              style: GoogleFonts.poppins(color: Colors.black, fontSize: 27),
                            ),
                            Text('mmHg', style: GoogleFonts.poppins(color: Colors.black, fontSize: 11.5),),
                          ],
                        ),
                      ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: isLoading
                    ? _buildShimmerContainer()
                    : Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.local_fire_department, color: Colors.orange),
                                Text('Sensation avant', style: GoogleFonts.poppins(color: Colors.black, fontSize: 11.5),),
                              ],
                            ),
                            Text(
                              currentDayStats?.sensationBefore ?? '0/0',
                              style: GoogleFonts.poppins(color: Colors.black, fontSize: 15),
                            ),
                          ],
                        ),
                      ),
              ),
              
            ],
          ),
           const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: isLoading
                    ? _buildShimmerContainer()
                    : Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.local_fire_department, color: Colors.orange),
                                Text('Sensation après', style: GoogleFonts.poppins(color: Colors.black, fontSize: 11.5),),
                              ],
                            ),
                            Text(
                              currentDayStats?.sensationAfter ?? '0/0',
                              style: GoogleFonts.poppins(color: Colors.black, fontSize: 15),
                            ),
                          ],
                        ),
                      ),
              ),
              
            ],
          ),

          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: isLoading
                    ? _buildShimmerContainer()
                    : Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Fréquence \n cardiaque avant', style: GoogleFonts.poppins(color: Colors.black, fontSize: 11.5),),
                            Text(
                              currentDayStats?.heartRateBefore ?? '0/0',
                              style: GoogleFonts.poppins(color: Colors.black, fontSize: 27),
                            ),
                            Text('bpm', style: GoogleFonts.poppins(color: Colors.black, fontSize: 11.5),),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildPostExerciseIndicators() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
Text(
            'Indicateurs Pendant l\'exercice',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Row(
            children: [
              Expanded(
                child: isLoading
                    ? _buildShimmerContainer()
                    : Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Sensation pendant', style: GoogleFonts.poppins(color: Colors.black, fontSize: 11.5),),
                            Text(
                              currentDayStats?.sensationDuring ?? '0/0',
                              style: GoogleFonts.poppins(color: Colors.black, fontSize: 27),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Indicateurs après exercice',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: isLoading
                    ? _buildShimmerContainer()
                    : Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(' Durée(min)', style: GoogleFonts.poppins(color: Colors.black, fontSize: 11.5),),
                            Text(
                              _formatDuration(currentDayStats?.duration ?? '00:00'),
                              style: GoogleFonts.poppins(color: Colors.black, fontSize: 27),
                            ),
                          ],
                        ),
                      ),
              ),
              
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: isLoading
                    ? _buildShimmerContainer()
                    : Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.local_fire_department, color: Colors.orange),
                                Text('Calories \n brûlées', style: GoogleFonts.poppins(color: Colors.black, fontSize: 11.5),),
                              ],
                            ),
                            Text(
                              '${double.tryParse(currentDayStats?.caloriesBurned ?? '0')?.toStringAsFixed(0)}kcal',
                              style: GoogleFonts.poppins(color: Colors.black, fontSize: 27),
                            ),
                          ],
                        ),
                      ),
              ),
             
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: isLoading
                    ? _buildShimmerContainer()
                    : Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.local_fire_department, color: Colors.orange),
                                Text('Pression \n systolique \n après', style: GoogleFonts.poppins(color: Colors.black, fontSize: 11.5),),
                              ],
                            ),
                            Text(
                              '${currentDayStats?.systolicPressureAfter ?? '0'}',
                              style: GoogleFonts.poppins(color: Colors.black, fontSize: 27),
                            ),
                          ],
                        ),
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: isLoading
                    ? _buildShimmerContainer()
                    : Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Pression \n diastolique \n après', style: GoogleFonts.poppins(color: Colors.black, fontSize: 11.5),),
                            Text(
                              currentDayStats?.diastolicPressureAfter ?? '0',
                              style: GoogleFonts.poppins(color: Colors.black, fontSize: 27),
                            ),
                            Text('mmHg', style: GoogleFonts.poppins(color: Colors.black, fontSize: 11.5),),
                          ],
                        ),
                      ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: isLoading
                    ? _buildShimmerContainer()
                    : Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Pression \n artérielle après', style: GoogleFonts.poppins(color: Colors.black, fontSize: 11.5),),
                            Text(
                              currentDayStats?.bloodPressureAfter ?? '0/0',
                              style: GoogleFonts.poppins(color: Colors.black, fontSize: 27),
                            ),
                            Text('mmHg', style: GoogleFonts.poppins(color: Colors.black, fontSize: 11.5),),
                          ],
                        ),
                      ),
              ),
            ],
          ),
          const SizedBox(height: 16),
           Row(
            children: [
              Expanded(
                child: isLoading
                    ? _buildShimmerContainer()
                    : Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Fréquence \n cardiaque après', style: GoogleFonts.poppins(color: Colors.black, fontSize: 11.5),),
                            Text(
                              currentDayStats?.heartRateAfter ?? '0/0',
                              style: GoogleFonts.poppins(color: Colors.black, fontSize: 27),
                            ),
                            Text('mmHg', style: GoogleFonts.poppins(color: Colors.black, fontSize: 11.5),),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDateSelector(),
              _buildPreExerciseIndicators(),
              _buildPostExerciseIndicators(),
              if (currentDayExercises.isEmpty && !isLoading)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      'Il n\'y a plus d\'exercice pour ce jour',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              if (currentDayExercises.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _nextExercise,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      currentDayExercises.length > 1 ? 'Exercice suivant' : 'Exercice suivant',
                      style: GoogleFonts.poppins(color: Colors.black),
                    ),
                  ),
                ),
              if (currentDayExercises.length > 1)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Exercice ${currentExerciseIndex + 1}/${currentDayExercises.length}',
                    style: GoogleFonts.poppins(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
} 

 String _formatDuration(String duration) {
    final parts = duration.split(":");
    if (parts.length == 2) {
      final hours = int.tryParse(parts[0]) ?? 0;
      final minutes = int.tryParse(parts[1]) ?? 0;
      String result = "";
      if (hours > 0) result += "${hours}h ";
      if (minutes > 0 || hours == 0) result += "${minutes}min";
      return result.trim();
    }
    return duration;
  }