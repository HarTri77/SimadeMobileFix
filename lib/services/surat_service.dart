// lib/services/surat_service.dart - UPDATED WITH FILE UPLOAD FEATURES
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import '../config/app_config.dart';
import '../models/surat_model.dart';
import 'auth_service.dart';

class SuratService {
  static List<SuratModel>? _cachedSuratList;
  static DateTime? _lastCacheTime;
  
  // ✅ ENHANCEMENT: FILE UPLOAD SERVICE INTEGRATION
  static Future<Map<String, dynamic>> _uploadFile({
    required PlatformFile file,
    required String fileType,
    int? suratId,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${AppConfig.baseUrl}/file_upload.php'),
      );

      request.headers['Authorization'] = 'Bearer $token';

// di method _uploadFile() - baris 48
final fileBytes = file.bytes;
if (fileBytes == null) {
  throw Exception('File bytes tidak tersedia. File mungkin korup atau terlalu besar.');
}

      final multipartFile = http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: file.name,
      );
      request.files.add(multipartFile);

      request.fields['file_type'] = fileType;
      if (suratId != null) {
        request.fields['surat_id'] = suratId.toString();
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final data = json.decode(responseBody);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'],
          'data': data['data'],
        };
      } else {
        throw Exception(data['message'] ?? 'Upload gagal');
      }
    } catch (e) {
      throw Exception('Upload file gagal: $e');
    }
  }

  // ✅ ENHANCEMENT: AJUKAN SURAT DENGAN FILE
  static Future<SuratModel> ajukanSuratWithFile({
    required String jenisSurat,
    required String keperluan,
    PlatformFile? filePendukung,
  }) async {
    try {
      String? uploadedFileName;
      
      // Upload file pendukung jika ada
      if (filePendukung != null) {
        final uploadResult = await _uploadFile(
          file: filePendukung,
          fileType: 'pendukung',
        );
        
        if (uploadResult['success'] == true) {
          uploadedFileName = uploadResult['data']['file_name'];
        } else {
          throw Exception('Gagal upload file pendukung');
        }
      }

      // Ajukan surat dengan file
      return await ajukanSurat(
        jenisSurat: jenisSurat,
        keperluan: keperluan,
        filePendukung: uploadedFileName,
      );
    } catch (e) {
      throw Exception('Gagal mengajukan surat dengan file: $e');
    }
  }

  // ✅ ENHANCEMENT: UPDATE STATUS DENGAN FILE HASIL
  static Future<SuratModel> updateStatusWithFile({
    required int suratId,
    required String status,
    required String catatanAdmin,
    PlatformFile? fileHasil,
  }) async {
    try {
      String? uploadedFileName;
      
      // Upload file hasil jika ada
      if (fileHasil != null) {
        final uploadResult = await _uploadFile(
          file: fileHasil,
          fileType: 'hasil',
          suratId: suratId,
        );
        
        if (uploadResult['success'] == true) {
          uploadedFileName = uploadResult['data']['file_name'];
        } else {
          throw Exception('Gagal upload file hasil');
        }
      }

      // Update status dengan file hasil
      return await updateStatusSurat(
        suratId: suratId,
        status: status,
        catatanAdmin: catatanAdmin,
        fileHasil: uploadedFileName,
      );
    } catch (e) {
      throw Exception('Gagal update status dengan file: $e');
    }
  }

  // ✅ ENHANCEMENT: VALIDATE FILE BEFORE UPLOAD
  static Map<String, dynamic> validateFile(PlatformFile file) {
    final errors = <String, String>{};
    
    // Validate file size (max 5MB)
    const maxSize = 5 * 1024 * 1024;
    if (file.size > maxSize) {
      errors['size'] = 'Ukuran file maksimal 5MB';
    }
    
    // Validate file extension
    final allowedExtensions = ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'];
    final extension = file.name.split('.').last.toLowerCase();
    if (!allowedExtensions.contains(extension)) {
      errors['extension'] = 'Format file tidak didukung. Gunakan: PDF, JPG, PNG, DOC';
    }
    
    return {
      'isValid': errors.isEmpty,
      'errors': errors,
    };
  }

  // ✅ ENHANCEMENT: GET FILE DOWNLOAD URL
  static String getFileDownloadUrl(String fileName, String fileType) {
    return '${AppConfig.baseUrl}/surat.php?download=true&file_name=$fileName&file_type=$fileType';
  }

  // ========== EXISTING METHODS (TETAP SAMA) ========== //
  
  // Get semua surat milik user
  static Future<List<SuratModel>> getSuratSaya() async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/surat.php'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> suratList = data['data'];
          return suratList.map((json) => SuratModel.fromJson(json)).toList();
        } else {
          throw Exception(data['message'] ?? 'Gagal memuat data surat');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Sesi telah berakhir, silakan login kembali');
      } else {
        throw Exception('HTTP ${response.statusCode}: Gagal memuat data surat');
      }
    } on TimeoutException catch (e) {
      throw Exception('Timeout: $e');
    } on http.ClientException catch (e) {
      throw Exception('Koneksi jaringan error: $e');
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  // Get detail surat by ID
  static Future<SuratModel> getDetailSurat(int suratId) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/surat.php?id=$suratId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return SuratModel.fromJson(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Gagal memuat detail surat');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Sesi telah berakhir, silakan login kembali');
      } else {
        throw Exception('HTTP ${response.statusCode}: Gagal memuat detail surat');
      }
    } on TimeoutException catch (e) {
      throw Exception('Timeout: $e');
    } on http.ClientException catch (e) {
      throw Exception('Koneksi jaringan error: $e');
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  // Ajukan surat baru
  static Future<SuratModel> ajukanSurat({
    required String jenisSurat,
    required String keperluan,
    String? filePendukung,
  }) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/surat.php'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'jenis_surat': jenisSurat,
          'keperluan': keperluan,
          'file_pendukung': filePendukung,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          clearCache();
          return SuratModel.fromJson(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Gagal mengajukan surat');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Gagal mengajukan surat');
      }
    } on TimeoutException catch (e) {
      throw Exception('Timeout: $e');
    } on http.ClientException catch (e) {
      throw Exception('Koneksi jaringan error: $e');
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  // Batalkan surat (hanya untuk status pending)
  static Future<void> batalkanSurat(int suratId) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.delete(
        Uri.parse('${AppConfig.baseUrl}/surat.php?id=$suratId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        clearCache();
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Gagal membatalkan surat');
      }
    } on TimeoutException catch (e) {
      throw Exception('Timeout: $e');
    } on http.ClientException catch (e) {
      throw Exception('Koneksi jaringan error: $e');
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  // ========== ADMIN METHODS ========== //

  // ADMIN: Get semua surat (untuk admin)
  static Future<List<SuratModel>> getAllSurat() async {
    if (_cachedSuratList != null && 
        _lastCacheTime != null && 
        DateTime.now().difference(_lastCacheTime!).inSeconds < 30) {
      return _cachedSuratList!;
    }

    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/surat.php?all=true'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> suratList = data['data'];
          _cachedSuratList = suratList.map((json) => SuratModel.fromJson(json)).toList();
          _lastCacheTime = DateTime.now();
          return _cachedSuratList!;
        } else {
          throw Exception(data['message'] ?? 'Gagal memuat data surat');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Sesi telah berakhir, silakan login kembali');
      } else if (response.statusCode == 403) {
        throw Exception('Akses ditolak. Hanya admin yang dapat mengakses fitur ini');
      } else {
        throw Exception('HTTP ${response.statusCode}: Gagal memuat data surat');
      }
    } on TimeoutException catch (e) {
      if (_cachedSuratList != null) {
        return _cachedSuratList!;
      }
      throw Exception('Timeout: $e');
    } on http.ClientException catch (e) {
      if (_cachedSuratList != null) {
        return _cachedSuratList!;
      }
      throw Exception('Koneksi jaringan error: $e');
    } catch (e) {
      if (_cachedSuratList != null) {
        return _cachedSuratList!;
      }
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  // ADMIN: Update status surat
  static Future<SuratModel> updateStatusSurat({
    required int suratId,
    required String status,
    required String catatanAdmin,
    String? fileHasil,
  }) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.put(
        Uri.parse('${AppConfig.baseUrl}/surat.php'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'id': suratId,
          'status': status,
          'catatan_admin': catatanAdmin,
          'file_hasil': fileHasil,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          clearCache();
          return SuratModel.fromJson(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Gagal update status surat');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Sesi telah berakhir, silakan login kembali');
      } else if (response.statusCode == 403) {
        throw Exception('Akses ditolak. Hanya admin yang dapat mengupdate status surat');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Gagal update status surat');
      }
    } on TimeoutException catch (e) {
      throw Exception('Timeout: $e');
    } on http.ClientException catch (e) {
      throw Exception('Koneksi jaringan error: $e');
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  // ADMIN: Get statistics untuk dashboard admin
  static Future<Map<String, dynamic>> getAdminStats() async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/surat.php?stats=true'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['data'];
        } else {
          throw Exception(data['message'] ?? 'Gagal memuat statistik');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Sesi telah berakhir, silakan login kembali');
      } else if (response.statusCode == 403) {
        throw Exception('Akses ditolak. Hanya admin yang dapat mengakses statistik');
      } else {
        throw Exception('HTTP ${response.statusCode}: Gagal memuat statistik');
      }
    } on TimeoutException catch (e) {
      throw Exception('Timeout: $e');
    } on http.ClientException catch (e) {
      throw Exception('Koneksi jaringan error: $e');
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  // Clear cache
  static void clearCache() {
    _cachedSuratList = null;
    _lastCacheTime = null;
  }
}