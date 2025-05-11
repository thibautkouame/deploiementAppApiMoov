import 'package:flutter/material.dart';
import 'package:fitness/theme/theme.dart';
import 'package:fitness/widgets/button_widget.dart';
import 'package:fitness/pages/screens/stats_screen.dart';
import 'package:fitness/pages/screens/analysis_screen.dart';
import 'package:fitness/pages/screens/profile_screen.dart';
import 'package:fitness/pages/screens/exercise_detail_screen.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:fitness/models/exercise_type.dart';
import 'package:fitness/services/auth_service.dart';
import 'package:fitness/widgets/selector_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:fitness/widgets/space_widget.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeContent(),
    const StatsScreen(),
    const AnalysisScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(LucideIcons.home, 'Accueil', 0),
            _buildNavItem(LucideIcons.rocket, 'Statistiques', 1),
            _buildNavItem(LucideIcons.barChartBig, 'Analyse', 2),
            _buildNavItem(LucideIcons.user2, 'Profil', 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: _selectedIndex == index ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: _selectedIndex == index ? Colors.black : Colors.white,
            ),
            if (_selectedIndex == index) const SizedBox(width: 4),
            if (_selectedIndex == index)
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 12,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  List<ExerciseType> _exercises = [];
  bool _isLoading = true;
  bool _showValidation = false;
  bool _showShimmer = true;
  Timer? _shimmerTimer;

  final TextEditingController _waterLiterController = TextEditingController();
  final TextEditingController _sleepHoursController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _bloodPressureController = TextEditingController();
  final TextEditingController _heartRateController = TextEditingController();
  final TextEditingController _systolicPressureBeforeController = TextEditingController();
  final TextEditingController _diastolicPressureBeforeController = TextEditingController();
  String? _sensationBefore;

  @override
  void initState() {
    super.initState();
    _fetchExercises();
    _startShimmerTimer();
  }

  void _startShimmerTimer() {
    _shimmerTimer = Timer(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _showShimmer = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _shimmerTimer?.cancel();
    _waterLiterController.dispose();
    _sleepHoursController.dispose();
    _caloriesController.dispose();
    _bloodPressureController.dispose();
    _heartRateController.dispose();
    _systolicPressureBeforeController.dispose();
    _diastolicPressureBeforeController.dispose();
    super.dispose();
  }

  Future<void> _fetchExercises() async {
    try {
      final response = await http.get(Uri.parse('${AuthService.baseUrl}/exercise-types'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        print('les types d\'exercices : $data');
        setState(() {
          _exercises = (data['exerciseTypes'] as List)
              .map((exercise) => ExerciseType.fromJson(exercise))
              .toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load exercises');
      }
    } catch (e) {
      print('erreur : $e');
      setState(() {
        _isLoading = false;
      });
      print('Error fetching exercises: ${e.toString()}');
    }
  }

  bool _areAllFieldsFilled() {
    return _waterLiterController.text.isNotEmpty &&
        _sleepHoursController.text.isNotEmpty &&
        _caloriesController.text.isNotEmpty &&
        _systolicPressureBeforeController.text.isNotEmpty &&
        _diastolicPressureBeforeController.text.isNotEmpty &&
        _heartRateController.text.isNotEmpty &&
        _sensationBefore != null;
  }

  void _showValidationSnackbar() {
    setState(() {
      _showValidation = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Veuillez tout remplir.'),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
              child: const Text(
                'OK',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.redAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: Text(
                  'Exercices',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Container(
              height: 350,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/images/image_01.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  SpaceWidget.height16,
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 210,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: _buildIndicator('Qté eau', Icons.water_drop, AppColors.primary, 'Litre', _waterLiterController)),
                                Expanded(child: _buildIndicator('Sommeil', Icons.nightlight_rounded, AppColors.primary, 'Heure', _sleepHoursController)),
                                Expanded(child: _buildIndicator('Calorie\nAbsorbée', Icons.local_fire_department, AppColors.primary, 'Kcal', _caloriesController)),
                              ],
                            ),
                          ),
                          SpaceWidget.height10,
                           Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: _buildIndicator('Pression systolique avant', Icons.water_drop, AppColors.primary, 'MmHg', _systolicPressureBeforeController)),
                                  Expanded(child: _buildIndicator('Pression diastolique avant', Icons.nightlight_rounded, AppColors.primary, 'MmHg', _diastolicPressureBeforeController)),
                              ],
                            ),
                          ),
                          SpaceWidget.height10,
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: _buildIndicator('Pression\nartérielle avant', Icons.favorite, AppColors.primary, 'MmHg', _bloodPressureController)),
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: _showValidation && _sensationBefore == null 
                                            ? Colors.red 
                                            : Colors.transparent,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: SensationSelect(
                                      label: 'Sensation avant',
                                      value: _sensationBefore,
                                      onChanged: (value) {
                                        setState(() => _sensationBefore = value);
                                      },
                                    ),
                                  ),
                                ),
                                Expanded(child: _buildIndicator('Frequence\ncardiaque avant', Icons.monitor_heart, AppColors.primary, 'Bpm', _heartRateController)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ButtonWidget(
                borderRadius: BorderRadius.circular(20),
                width: 290,
                height: 50,
                text: 'Enregistrer',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                onPressed: () {
                  if (!_areAllFieldsFilled()) {
                    _showValidationSnackbar();
                    return;
                  }
                  if (_exercises.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No exercises available')),
                    );
                    return;
                  }
                  final exercise = _exercises.first;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ExerciseDetailScreen(
                        exercise: exercise,
                        waterLiter: _waterLiterController.text,
                        sleepHours: _sleepHoursController.text,
                        calories: _caloriesController.text,
                        bloodPressureBefore: _bloodPressureController.text,
                        sensationBefore: _sensationBefore,
                        heartRateBefore: _heartRateController.text,
                        systolicPressureBefore: _systolicPressureBeforeController.text,
                        diastolicPressureBefore: _diastolicPressureBeforeController.text,
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_isLoading || _showShimmer)
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Column(
                  children: List.generate(3, (index) => _buildShimmerItem()),
                ),
              )
            else if (_exercises.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: _exercises.length,
                itemBuilder: (context, index) {
                  final exercise = _exercises[index];
                  print('exercice : $exercise');
                  return _buildExerciseItem(exercise);
                },
              )
            else
              const Center(
                child: Text('Aucun exercice disponible'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicator(String label, IconData icon, Color color, String placeholder, TextEditingController controller) {
    bool _isFieldEmpty(TextEditingController controller) {
      return controller.text.isEmpty;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.black, size: 20),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 9,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: 50,
                  height: 30,
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: _showValidation && _isFieldEmpty(controller) ? Colors.red : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: _showValidation && _isFieldEmpty(controller) ? Colors.red : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: _showValidation && _isFieldEmpty(controller) ? Colors.red : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      hintText: placeholder,
                    ),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseItem(ExerciseType exercise) {
    return GestureDetector(
      onTap: () {
        if (!_areAllFieldsFilled()) {
          _showValidationSnackbar();
          return;
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExerciseDetailScreen(
              exercise: exercise,
              waterLiter: _waterLiterController.text,
              sleepHours: _sleepHoursController.text,
              calories: _caloriesController.text,
              bloodPressureBefore: _bloodPressureController.text,
              sensationBefore: _sensationBefore,
              heartRateBefore: _heartRateController.text,
              systolicPressureBefore: _systolicPressureBeforeController.text,
              diastolicPressureBefore: _diastolicPressureBeforeController.text,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  Image.network(
                    'http://192.168.1.5:3000${exercise.imageCover}',
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        padding: const EdgeInsets.all(1),
                        child: Icon(
                          Icons.play_arrow,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    exercise.description,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    exercise.duration,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerItem() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 100,
              height: 100,
              color: Colors.grey[300],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 18,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  height: 12,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 8),
                Container(
                  width: 100,
                  height: 12,
                  color: Colors.grey[300],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
