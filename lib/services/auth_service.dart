// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/user_model.dart';

class AuthService {
  // 🔥 LOGIN
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(AppConfig.loginEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      print('🔥 Response status: ${response.statusCode}');
      print('🔥 Response body: ${response.body}');

      final data = json.decode(response.body);

      if (data['success'] == true) {
        // Clean user data sebelum parse
        final userData = Map<String, dynamic>.from(data['user']);
        
        // Ensure all fields are properly typed
        final cleanUserData = {
          'id': userData['id']?.toString() ?? '0',
          'nama': userData['nama']?.toString() ?? '',
          'email': userData['email']?.toString() ?? '',
          'no_hp': userData['no_hp']?.toString(),
          'alamat': userData['alamat']?.toString(),
          'role': userData['role']?.toString() ?? 'warga',
          'foto_profile': userData['foto_profile']?.toString(),
          'status': userData['status']?.toString() ?? 'active',
        };

        print('🔥 Clean user data: $cleanUserData');

        // Save token & user data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token'].toString());
        await prefs.setString('user', json.encode(cleanUserData));

        return {
          'success': true,
          'message': data['message']?.toString() ?? 'Login berhasil',
          'user': UserModel.fromJson(cleanUserData),
          'token': data['token'].toString(),
        };
      } else {
        return {
          'success': false,
          'message': data['message']?.toString() ?? 'Login gagal',
        };
      }
    } catch (e) {
      print('🔥 Error: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // 🔥 REGISTER
  static Future<Map<String, dynamic>> register({
    required String nama,
    required String email,
    required String password,
    required String noHp,
    required String alamat,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(AppConfig.registerEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'nama': nama,
          'email': email,
          'password': password,
          'no_hp': noHp,
          'alamat': alamat,
        }),
      );

      final data = json.decode(response.body);

      return {
        'success': data['success'] ?? false,
        'message': data['message'] ?? 'Registrasi gagal',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // 🔥 LOGOUT
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // 🔥 GET CURRENT USER
  static Future<UserModel?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userString = prefs.getString('user');
      if (userString != null) {
        final userData = json.decode(userString);
        return UserModel.fromJson(userData);
      }
    } catch (e) {
      print('🔥 Error getting current user: $e');
      return null;
    }
    return null;
  }

  // 🔥 CHECK IF LOGGED IN
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') != null;
  }

  // 🔥 GET TOKEN
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}