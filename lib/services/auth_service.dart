import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:fitness/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'https://apimoov-back-rea7v.ondigitalocean.app/api';
  static const String baseUrlImage = 'https://apimoov-back-rea7v.ondigitalocean.app';

  // static const String baseUrl = 'http://192.168.1.8:3000/api';
  // static const String baseUrlImage = 'http://192.168.1.8:3000';

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

      if (response.statusCode == 401) {
        throw Exception('Token invalide');
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        // print('Response data parsed: $responseData');
        // print('Response data keys: ${responseData.keys}');

        if (responseData.isEmpty) {
          throw Exception('Aucune donnée utilisateur reçue');
        }

        final user = User.fromJson(responseData);
        print('User object created: ${user.username}');
        return user;
      } else {
        throw Exception(
            'Erreur lors de la récupération des informations utilisateur: ${response.body}');
      }
    } catch (e) {
      print('Erreur détaillée: $e');
      throw Exception('Erreur lors de la connexion au serveur: $e');
    }
  }

  Future<Map<String, dynamic>> requestOtp({
    required String email,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/request-reset'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            'Erreur lors de la réinitialisation du mot de passe: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la réinitialisation du mot de passe: $e');
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
    File? profilePicture,
  }) async {
    try {
      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('$baseUrl/user/update-profile'),
      );

      // Add authorization header
      request.headers['Authorization'] = 'Bearer $token';

      // Add text fields
      request.fields['f_name'] = firstName;
      request.fields['l_name'] = lastName;
      request.fields['email'] = email;
      request.fields['username'] = username;
      request.fields['sex'] = sex;
      request.fields['age'] = age;
      request.fields['weight'] = weight;
      request.fields['height'] = height;
      request.fields['actual_level'] = actual_level;
      request.fields['daily_training_type'] = daily_training_type;

      // Add profile picture if provided
      if (profilePicture != null) {
        final fileStream = http.ByteStream(profilePicture.openRead());
        final fileLength = await profilePicture.length();

        final multipartFile = http.MultipartFile(
          'profile_picture',
          fileStream,
          fileLength,
          filename: profilePicture.path.split('/').last,
          contentType: MediaType('image', 'jpeg'),
        );

        request.files.add(multipartFile);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return User.fromJson(responseData);
      } else {
        throw Exception(
            'Erreur lors de la mise à jour du profil: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la connexion au serveur: $e');
    }
  }

  Future<Map<String, dynamic>> verifyOtpAndChangePassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'otp': otp,
          'newPassword': newPassword,
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            'Erreur lors de la vérification du code OTP: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la vérification du code OTP: $e');
    }
  }

  Future<Map<String, dynamic>> requestDeleteAccount({
    required String token,
    required String f_name,
    required String l_name,
    required String email,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/request-delete'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'f_name': f_name,
          'l_name': l_name,
          'email': email,
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print(
            'Erreur lors de la suppression du compte: ${response.body.toString()}');
        throw Exception('Erreur lors de la suppression du compte');
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
