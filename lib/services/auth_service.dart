import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fitness/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'http://192.168.1.3:3000/api';
  static const String _tokenKey = 'auth_token';

  Future<Map<String, dynamic>> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String username,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'f_name': firstName,
          'l_name': lastName,
          'email': email,
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erreur lors de l\'inscription: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la connexion au serveur: $e');
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['token'] != null) {
          await saveToken(responseData['token']);
        }
        return responseData;
      } else {
        throw Exception('Erreur lors de la connexion: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la connexion au serveur: $e');
    }
  }

  Future<User> getUserInfo(String token) async {
    try {
      print('Token utilisé: $token');
      final response = await http.get(
        Uri.parse('$baseUrl/user/profile'),
        headers: {'Authorization': 'Bearer $token'},
      );

      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        print('Response data parsed: $responseData');
        print('Response data keys: ${responseData.keys}');
        
        if (responseData.isEmpty) {
          throw Exception('Aucune donnée utilisateur reçue');
        }
          
        final user = User.fromJson(responseData);
        print('User object created: ${user.username}');
        return user;
      } else {
        throw Exception('Erreur lors de la récupération des informations utilisateur: ${response.body}');
      }
    } catch (e) {
      print('Erreur détaillée: $e');
      throw Exception('Erreur lors de la connexion au serveur: $e');
    }
  }

  Future<User> updateProfile({
    required String token,
    required String firstName,
    required String lastName,
    required String email,
    required String username,
    required String sex,
    required String age,
    required String weight,
    required String height,
    required String actual_level,
    required String daily_training_type,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/user/update-profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'f_name': firstName,
          'l_name': lastName,
          'email': email,
          'username': username,
          'sex': sex,
          'age': age,
          'weight': weight,
          'height': height,
          'actual_level': actual_level,
          'daily_training_type': daily_training_type,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return User.fromJson(responseData);
      } else {
        throw Exception('Erreur lors de la mise à jour du profil: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la connexion au serveur: $e');  
    }
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}