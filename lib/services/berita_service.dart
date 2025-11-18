// lib/services/berita_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/berita_model.dart';
import 'auth_service.dart';
import 'package:file_picker/file_picker.dart';

class BeritaService {
  // ✅ Get semua berita
  static Future<List<BeritaModel>> getBerita() async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/berita.php'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> beritaList = data['data'];
          return beritaList.map((json) => BeritaModel.fromJson(json)).toList();
        } else {
          throw Exception(data['message']);
        }
      } else {
        throw Exception('Failed to load berita: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  // ✅ Get detail berita
  static Future<BeritaModel> getDetailBerita(int id) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/berita.php?id=$id'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return BeritaModel.fromJson(data['data']);
        } else {
          throw Exception(data['message']);
        }
      } else {
        throw Exception('Failed to load berita detail: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  // ✅ Create berita (admin only)
  static Future<BeritaModel> createBerita({
    required String judul,
    required String konten,
    String? gambar,
  }) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/berita.php'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'judul': judul,
          'konten': konten,
          'gambar': gambar,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return BeritaModel.fromJson(data['data']);
        } else {
          throw Exception(data['message']);
        }
      } else {
        throw Exception('Failed to create berita: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  // ✅ Update berita (admin only)
  static Future<BeritaModel> updateBerita({
    required int id,
    String? judul,
    String? konten,
    String? gambar,
  }) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.put(
        Uri.parse('${AppConfig.baseUrl}/berita.php'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'id': id,
          'judul': judul,
          'konten': konten,
          'gambar': gambar,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return BeritaModel.fromJson(data['data']);
        } else {
          throw Exception(data['message']);
        }
      } else {
        throw Exception('Failed to update berita: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  // ✅ Delete berita (admin only)
  static Future<void> deleteBerita(int id) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.delete(
        Uri.parse('${AppConfig.baseUrl}/berita.php?id=$id'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] != true) {
          throw Exception(data['message']);
        }
      } else {
        throw Exception('Failed to delete berita: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  // ✅ Upload gambar berita
  static Future<Map<String, dynamic>> uploadGambarBerita(PlatformFile file) async {
    try {
      final token = await AuthService.getToken();
      
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${AppConfig.baseUrl}/upload_berita.php'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      final fileBytes = file.bytes;
      if (fileBytes == null) {
        throw Exception('File bytes tidak tersedia');
      }

      final multipartFile = http.MultipartFile.fromBytes(
        'gambar',
        fileBytes,
        filename: file.name,
      );
      request.files.add(multipartFile);

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final data = json.decode(responseBody);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'],
          'file_name': data['data']['file_name'],
        };
      } else {
        throw Exception(data['message'] ?? 'Upload gagal');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }
}