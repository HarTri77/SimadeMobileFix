// lib/services/aduan_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/aduan_model.dart';
import '../models/kategori_aduan_model.dart';
import 'auth_service.dart';

class AduanService {
  // ✅ Get semua aduan
  static Future<List<AduanModel>> getAduan() async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/aduan.php'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> aduanList = data['data'];
          return aduanList.map((json) => AduanModel.fromJson(json)).toList();
        } else {
          throw Exception(data['message']);
        }
      } else {
        throw Exception('Failed to load aduan: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  // ✅ Get detail aduan
  static Future<AduanModel> getDetailAduan(int id) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/aduan.php?id=$id'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return AduanModel.fromJson(data['data']);
        } else {
          throw Exception(data['message']);
        }
      } else {
        throw Exception('Failed to load aduan detail: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  // ✅ Create aduan
  static Future<AduanModel> createAduan({
    required String judul,
    required String isiAduan,
    int? kategori,
    String prioritas = 'rendah',
    String? lokasi,
  }) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/aduan.php'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'judul': judul,
          'isi_aduan': isiAduan,
          'kategori': kategori,
          'prioritas': prioritas,
          'lokasi': lokasi,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return AduanModel.fromJson(data['data']);
        } else {
          throw Exception(data['message']);
        }
      } else {
        throw Exception('Failed to create aduan: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  // ✅ Update aduan
  static Future<AduanModel> updateAduan({
    required int id,
    String? judul,
    String? isiAduan,
    int? kategori,
    String? prioritas,
    String? lokasi,
    String? status,
    String? tanggapan,
  }) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.put(
        Uri.parse('${AppConfig.baseUrl}/aduan.php'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'id': id,
          'judul': judul,
          'isi_aduan': isiAduan,
          'kategori': kategori,
          'prioritas': prioritas,
          'lokasi': lokasi,
          'status': status,
          'tanggapan': tanggapan,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return AduanModel.fromJson(data['data']);
        } else {
          throw Exception(data['message']);
        }
      } else {
        throw Exception('Failed to update aduan: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  // ✅ Delete aduan
  static Future<void> deleteAduan(int id) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.delete(
        Uri.parse('${AppConfig.baseUrl}/aduan.php?id=$id'),
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
        throw Exception('Failed to delete aduan: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  // ✅ Get kategori aduan
  static Future<List<KategoriAduanModel>> getKategoriAduan() async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/aduan_kategori.php'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> kategoriList = data['data'];
          return kategoriList.map((json) => KategoriAduanModel.fromJson(json)).toList();
        } else {
          throw Exception(data['message']);
        }
      } else {
        throw Exception('Failed to load kategori: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }
}