import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fitness/models/exercise_stats.dart';
import 'package:fitness/services/auth_service.dart';

class StatsService {
  static Future<Map<String, dynamic>> fetchStats() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('Token not found');
      }

      final response = await http.get(
        Uri.parse('${AuthService.baseUrl}/user/exercises/history'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        print('les données sont : $data');
        
        // Vérifier la structure de la réponse
        if (data is! Map<String, dynamic>) {
          throw Exception('Invalid response format');
        }

        if (data['status'] != 'success') {
          throw Exception('API returned non-success status');
        }

        final history = data['history'] as Map<String, dynamic>?;
        final statistics = data['statistics'] as Map<String, dynamic>?;

        if (history == null || statistics == null) {
          throw Exception('Missing required data in response');
        }

        return {
          'history': history,
          'statistics': statistics,
        };
      } else {
        throw Exception('Failed to load stats: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in fetchStats: $e');
      throw Exception('Error fetching stats: $e');
    }
  }

  // static Future<Map<String, dynamic>> fetchStatistics() async {
  //   try {
  //     final token = await AuthService.getToken();
  //     if (token == null) {
  //       throw Exception('Token not found');
  //     }

  //     final response = await http.get(
  //       Uri.parse('${AuthService.baseUrl}/user/statistics'),
  //       headers: {
  //         'Authorization': 'Bearer $token',
  //         'Content-Type': 'application/json',
  //       },
  //     );

  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);
  //       return data['statistics'] as Map<String, dynamic>;
  //     }
  //     throw Exception('Failed to load statistics');
  //   } catch (e) {
  //     throw Exception('Error fetching statistics: $e');
  //   }
  // }

  // static Future<Map<String, dynamic>> fetchPredictions() async {
  //   try {
  //     final token = await AuthService.getToken();
  //     if (token == null) {
  //       throw Exception('Token not found');
  //     }

  //     final response = await http.get(
  //       Uri.parse('${AuthService.baseUrl}/user/predictions'),
  //       headers: {
  //         'Authorization': 'Bearer $token',
  //         'Content-Type': 'application/json',
  //       },
  //     );

  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);
  //       return data['predictions'] as Map<String, dynamic>;
  //     }
  //     throw Exception('Failed to load predictions');
  //   } catch (e) {
  //     throw Exception('Error fetching predictions: $e');
  //   }
  // }
} 