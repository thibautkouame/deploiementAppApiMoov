import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fitness/models/exercise_history.dart';
import 'package:fitness/services/auth_service.dart';

class ExerciseService {
  static const String baseUrl = AuthService.baseUrl;

  Future<Map<String, dynamic>> getExerciseHistory(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/exercises/history'),
        headers: { 
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print('Raw API response: $data');
        return data;
      } else {
        throw Exception('Erreur lors de la récupération de l\'historique: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la connexion au serveur: $e');
    }
  }

  List<ExerciseHistory> parseExerciseHistory(Map<String, dynamic> data) {
    List<ExerciseHistory> exercises = [];
    try {
      if (data['status'] == 'success' && data['history'] != null) {
        final Map<String, dynamic> history = data['history'];
        
        history.forEach((dateStr, exerciseList) {
          if (exerciseList is List) {
            for (var exercise in exerciseList) {
              if (exercise is Map<String, dynamic>) {
                try {
                  final exerciseHistory = ExerciseHistory.fromJson(exercise);
                  exercises.add(exerciseHistory);
                  print('Parsed exercise for date $dateStr: ${exerciseHistory.toMap()}');
                } catch (e) {
                  print('Error parsing exercise for date $dateStr: $e');
                }
              }
            }
          }
        });
      }
      print('Successfully parsed ${exercises.length} exercises');
      return exercises;
    } catch (e) {
      print('Error parsing exercise history: $e');
      return [];
    }
  }

  Map<String, int> getExerciseTypeStatistics(Map<String, dynamic> data) {
    if (data['status'] == 'success' && 
        data['statistics'] != null && 
        data['statistics']['exercise_types'] != null) {
      return Map<String, int>.from(data['statistics']['exercise_types']);
    }
    return {};
  }
} 