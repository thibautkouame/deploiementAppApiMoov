import 'package:fitness/widgets/button_widget.dart';
import 'package:fitness/widgets/space_widget.dart';
import 'package:flutter/material.dart';
import 'package:fitness/models/exercise_type.dart';
import 'package:fitness/theme/theme.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fitness/widgets/selector_widget.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fitness/services/auth_service.dart';
import 'package:fitness/widgets/bottom_nav_widget.dart';
import 'package:fitness/pages/screens/home_screen.dart';
import 'package:fitness/pages/screens/stats_screen.dart';
import 'package:fitness/pages/screens/analysis_screen.dart';
import 'package:fitness/pages/screens/profile_screen.dart';

class ExerciseDetailScreen extends StatefulWidget {
  final ExerciseType exercise;
  final String waterLiter;
  final String sleepHours;
  final String calories;
  final String bloodPressureBefore;
  final String? sensationBefore;
  final String heartRateBefore;
  final String systolicPressureBefore;
  final String diastolicPressureBefore;

  const ExerciseDetailScreen({
    super.key,
    required this.exercise,
    required this.waterLiter,
    required this.sleepHours,
    required this.calories,
    required this.bloodPressureBefore,
    required this.sensationBefore,
    required this.heartRateBefore,
    required this.systolicPressureBefore,
    required this.diastolicPressureBefore,
  });

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;
  bool _isInitialized = false;
  String? _error;
  int repetitions = 5;
  bool _showValidation = false;
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _bloodPressureController =
      TextEditingController();
  final TextEditingController _heartRateController = TextEditingController();
  final TextEditingController _waterLiterController = TextEditingController();
  final TextEditingController _sleepHoursController = TextEditingController();
  final TextEditingController _caloriesBurnedController =
      TextEditingController();
  final TextEditingController _bloodPressureAfterController =
      TextEditingController();
  final TextEditingController _heartRateAfterController =
      TextEditingController();
  final TextEditingController _systolicPressureBeforeController =
      TextEditingController();
  final TextEditingController _diastolicPressureBeforeController =
      TextEditingController();
  final TextEditingController _systolicPressureAfterController =
      TextEditingController();
  final TextEditingController _diastolicPressureAfterController =
      TextEditingController();
  String? _sensationAfter;
  String? _sensationDuring;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    final videoUrl = '${AuthService.baseUrlImage}${widget.exercise.videoUrl}';
    print('DEBUG - URL de la vidéo: $videoUrl');

    try {
      // Vérifier d'abord si la vidéo est accessible
      final response = await http.head(Uri.parse(videoUrl));
      print('DEBUG - Test vidéo - Status: ${response.statusCode}');
      print('DEBUG - Test vidéo - Headers: ${response.headers}');

      if (response.statusCode != 200) {
        throw Exception('Vidéo non accessible (${response.statusCode})');
      }

      _controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));

      await _controller.initialize();
      print('DEBUG - Vidéo initialisée avec succès');
      print('DEBUG - Durée: ${_controller.value.duration}');
      print('DEBUG - Taille: ${_controller.value.size}');

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      print('DEBUG - Erreur lors de l\'initialisation: $e');
      setState(() {
        _error = e.toString();
      });
    }
  }

  bool _areAllFieldsFilled() {
    return _caloriesBurnedController.text.isNotEmpty &&
        _bloodPressureAfterController.text.isNotEmpty &&
        _heartRateAfterController.text.isNotEmpty &&
        _systolicPressureAfterController.text.isNotEmpty &&
        _diastolicPressureAfterController.text.isNotEmpty &&
        _sensationAfter != null &&
        _sensationDuring != null;
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

  Future<void> _saveExerciseData() async {
    if (!_areAllFieldsFilled()) {
      _showValidationSnackbar();
      return;
    }

    // Création de l'objet de données
    final exerciseData = {
      'exercise_type_id': widget.exercise.id,
      'water_liter':
          widget.waterLiter.isNotEmpty ? double.parse(widget.waterLiter) : null,
      'sleep_hours':
          widget.sleepHours.isNotEmpty ? double.parse(widget.sleepHours) : null,
      'calories':
          widget.calories.isNotEmpty ? double.parse(widget.calories) : null,
      'blood_pressure_before': widget.bloodPressureBefore,
      'sensation_before': widget.sensationBefore,
      'heart_rate_before': widget.heartRateBefore.isNotEmpty
          ? int.parse(widget.heartRateBefore)
          : null,
      'duration': widget.exercise.duration,
      'repetition': repetitions,
      'calories_burned': _caloriesBurnedController.text.isNotEmpty
          ? double.parse(_caloriesBurnedController.text)
          : null,
      'sensation_after': _sensationAfter,
      'sensation_during': _sensationDuring,
      'blood_pressure_after': _bloodPressureAfterController.text,
      'heart_rate_after': _heartRateAfterController.text.isNotEmpty
          ? int.parse(_heartRateAfterController.text)
          : null,
      'systolic_pressure_before': widget.systolicPressureBefore,
      'diastolic_pressure_before': widget.diastolicPressureBefore,
      'systolic_pressure_after': _systolicPressureAfterController.text,
      'diastolic_pressure_after': _diastolicPressureAfterController.text,
    };

    // Affichage des données dans la console
    print('Données à envoyer à l\'API:');
    exerciseData.forEach((key, value) {
      print('$key: $value');
    });

    try {
      // Récupération du token
      final token = await AuthService.getToken();
      print('Token utilisé: $token');

      final response = await http.post(
        Uri.parse('${AuthService.baseUrl}/user/new-exercise'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(exerciseData),
      );

      print('Réponse de l\'API: ${response.statusCode}');
      print('Corps de la réponse: ${response.body}');

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                    'Votre session d\'entraînement \n a été enregistrée  avec succès.'),
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
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          ),
        );
        Navigator.pop(context);
      } else {
        throw Exception(
            'Failed to save exercise data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de l\'envoi des données: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _caloriesController.dispose();
    _bloodPressureController.dispose();
    _heartRateController.dispose();
    _waterLiterController.dispose();
    _sleepHoursController.dispose();
    _caloriesBurnedController.dispose();
    _bloodPressureAfterController.dispose();
    _heartRateAfterController.dispose();
    _systolicPressureBeforeController.dispose();
    _diastolicPressureBeforeController.dispose();
    _systolicPressureAfterController.dispose();
    _diastolicPressureAfterController.dispose();
    super.dispose();
  }

  Widget _buildCalendar() {
    final now = DateTime.now();
    final daysInWeek = List.generate(7, (index) {
      final date = now.subtract(Duration(days: now.weekday - index - 1));
      return date;
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            '${DateFormat('MMMM', 'fr_FR').format(now)[0].toUpperCase()}${DateFormat('MMMM', 'fr_FR').format(now).substring(1)} ${now.year}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 65,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: daysInWeek.length,
            itemBuilder: (context, index) {
              final date = daysInWeek[index];
              final isToday = date.day == now.day;
              return Column(
                children: [
                  Container(
                    width: 45,
                    height: 45,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: isToday ? Colors.black : AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat(
                            'E',
                            'fr_FR',
                          ).format(date)[0].toUpperCase(),
                          style: TextStyle(
                            color: isToday ? Colors.white : Colors.black,
                            fontSize: 14,
                            fontWeight:
                                isToday ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          date.day.toString(),
                          style: TextStyle(
                            color: isToday ? Colors.white : Colors.black,
                            fontSize: 16,
                            fontWeight:
                                isToday ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isToday) ...[
                    const SizedBox(height: 4),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVideoPlayer() {
    if (_error != null) {
      return Center(
        child: Text('Erreur: $_error', style: TextStyle(color: Colors.red)),
      );
    }

    if (!_isInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: VideoPlayer(_controller),
        ),
        IconButton(
          icon: Icon(
            _isPlaying ? Icons.pause_circle : Icons.play_circle,
            size: 50,
            color: Colors.white,
          ),
          onPressed: () {
            setState(() {
              if (_isPlaying) {
                _controller.pause();
              } else {
                _controller.play();
              }
              _isPlaying = !_isPlaying;
            });
          },
        ),
      ],
    );
  }

  Widget _buildExerciseDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 15),
        AspectRatio(
          aspectRatio: 16 / 9,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              color: Colors.black,
              child: _buildVideoPlayer(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.exercise.name,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                widget.exercise.details,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary, width: 1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildDuration()),
                        Expanded(child: _buildRepetitionCounter()),
                        Expanded(
                          child: _buildIndicator(
                            'Calories brulées',
                            'Kcal',
                            _caloriesBurnedController,
                          ),
                        ),
                      ],
                    ),
                    SpaceWidget.height10,
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color:
                                    _showValidation && _sensationAfter == null
                                        ? Colors.red
                                        : Colors.transparent,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: SensationSelect(
                              label: 'Sensation après',
                              labelColor: Colors.black,
                              value: _sensationAfter,
                              labelSize: 11.5,
                              onChanged: (value) =>
                                  setState(() => _sensationAfter = value),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color:
                                    _showValidation && _sensationDuring == null
                                        ? Colors.red
                                        : Colors.transparent,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: SensationSelect(
                              labelColor: Colors.black,
                              label: 'Sensation pendant',
                              labelSize: 11.5,
                              value: _sensationDuring,
                              onChanged: (value) =>
                                  setState(() => _sensationDuring = value),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SpaceWidget.height10,
                    Row(
                      children: [
                        Expanded(
                          child: _buildIndicator(
                            'Pression artérielle après',
                            'MmHg',
                            _bloodPressureAfterController,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: _buildIndicator(
                            'Fréquence cardique après',
                            'Bpm',
                            _heartRateAfterController,
                          ),
                        ),
                      ],
                    ),
                    SpaceWidget.height10,
                    Row(
                      children: [
                        Expanded(
                          child: _buildIndicator(
                            'Pression systolique après',
                            'MmHg',
                            _systolicPressureAfterController,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: _buildIndicator(
                            'Pression diastolique après',
                            'MmHg',
                            _diastolicPressureAfterController,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ButtonWidget(
                  borderRadius: BorderRadius.circular(20),
                  width: 290,
                  height: 50,
                  text: 'Enregistrer',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  onPressed: _saveExerciseData,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIndicator(
      String label, String placeholder, TextEditingController controller) {
    bool _isFieldEmpty(TextEditingController controller) {
      return controller.text.isEmpty;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.black, fontSize: 11),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: double.infinity,
                  height: 30,
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 4,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: _showValidation && _isFieldEmpty(controller)
                              ? Colors.red
                              : Colors.grey[300]!,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: _showValidation && _isFieldEmpty(controller)
                              ? Colors.red
                              : Colors.grey[300]!,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: _showValidation && _isFieldEmpty(controller)
                              ? Colors.red
                              : AppColors.primary,
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

  Widget _buildRepetitionCounter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Nbre de répétition',
                  style: TextStyle(color: Colors.black, fontSize: 11),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  height: 30,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () {
                          if (repetitions > 0) {
                            setState(() => repetitions--);
                          }
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            '-',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          '$repetitions',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          setState(() => repetitions++);
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            '+',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDuration() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.timer_outlined,
              color: Colors.black,
              size: 20,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Durée',
                  style: TextStyle(color: Colors.black, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  widget.exercise.duration,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('DEBUG - Build appelé');
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Entraînement',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [_buildCalendar(), _buildExerciseDetails()],
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
}
