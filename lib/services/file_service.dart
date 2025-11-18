// lib/services/file_service.dart - FIXED VERSION
import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import 'auth_service.dart';

class FileService {

  // Tambahkan method ini di FileService class
static Future<String> getBeritaImageUrl(String fileName) async {
  try {
    final encodedFileName = Uri.encodeComponent(fileName);
    String baseUrl = AppConfig.baseUrl;
    
    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }
    
    final url = '$baseUrl/berita.php?download=true&file_name=$encodedFileName';
    return url;
  } catch (e) {
    print('Error generating berita image URL: $e');
    throw 'Gagal membuat URL gambar berita';
  }
}

  // ✅ PICK FILE DARI DEVICE
  static Future<FilePickerResult?> pickFile({
    List<String>? allowedExtensions,
    String? fileType,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions ?? ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
        allowMultiple: false,
      );

      return result;
    } catch (e) {
      throw Exception('Gagal memilih file: $e');
    }
  }

  // ✅ UPLOAD FILE KE SERVER
  static Future<Map<String, dynamic>> uploadFile({
    required PlatformFile file,
    required String fileType, // 'pendukung' or 'hasil'
    int? suratId,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${AppConfig.baseUrl}/file_upload.php'),
      );

      // Add headers
      request.headers['Authorization'] = 'Bearer $token';

      // Add file
      final fileBytes = file.bytes;
      if (fileBytes == null) {
        throw Exception('File bytes tidak tersedia');
      }

      final multipartFile = http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: file.name,
      );
      request.files.add(multipartFile);

      // Add other fields
      request.fields['file_type'] = fileType;
      if (suratId != null) {
        request.fields['surat_id'] = suratId.toString();
      }

      // Send request
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
    } on http.ClientException catch (e) {
      throw Exception('Koneksi error: $e');
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  // ✅ FIXED: DOWNLOAD FILE - SOLUSI UTAMA
  static Future<String> getDownloadUrl(String fileName, String fileType) async {
    try {
      // ✅ PERBAIKAN 1: Encode fileName untuk handle karakter khusus
      final encodedFileName = Uri.encodeComponent(fileName);
      
      // ✅ PERBAIKAN 2: Gunakan baseUrl yang konsisten
      String baseUrl = AppConfig.baseUrl;
      
      // ✅ PERBAIKAN 3: Pastikan tidak ada double slash
      if (baseUrl.endsWith('/')) {
        baseUrl = baseUrl.substring(0, baseUrl.length - 1);
      }
      
      // ✅ PERBAIKAN 4: Buat URL download yang benar
      final downloadUrl = '$baseUrl/surat.php?download=true&file_name=$encodedFileName&file_type=$fileType';
      
      // Debug logging
      print('🔗 Generated Download URL: $downloadUrl');
      
      return downloadUrl;
    } catch (e) {
      print('❌ Error generating download URL: $e');
      throw 'Gagal membuat URL download: $e';
    }
  }

  // ✅ ALTERNATIVE: Download dengan token (jika diperlukan)
  static Future<String> getDownloadUrlWithToken(String fileName, String fileType) async {
    try {
      final token = await AuthService.getToken();
      final encodedFileName = Uri.encodeComponent(fileName);
      
      String baseUrl = AppConfig.baseUrl;
      if (baseUrl.endsWith('/')) {
        baseUrl = baseUrl.substring(0, baseUrl.length - 1);
      }
      
      if (token != null) {
        final downloadUrl = '$baseUrl/surat.php?download=true&file_name=$encodedFileName&file_type=$fileType&token=$token';
        print('🔗 Download URL with Token: $downloadUrl');
        return downloadUrl;
      } else {
        // Fallback ke tanpa token
        return getDownloadUrl(fileName, fileType);
      }
    } catch (e) {
      print('❌ Error generating download URL with token: $e');
      return getDownloadUrl(fileName, fileType);
    }
  }

  // ✅ VALIDATE FILE SIZE (Max 5MB)
  static bool validateFileSize(PlatformFile file) {
    const maxSize = 5 * 1024 * 1024; // 5MB
    return file.size <= maxSize;
  }

  // ✅ VALIDATE FILE EXTENSION
  static bool validateFileExtension(PlatformFile file) {
    final allowedExtensions = ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'];
    final extension = getFileExtension(file.name);
    return allowedExtensions.contains(extension);
  }

  // ✅ COMPREHENSIVE FILE VALIDATION
  static Map<String, dynamic> validateFile(PlatformFile file) {
    final errors = <String, String>{};
    
    // Check size
    if (!validateFileSize(file)) {
      errors['size'] = 'Ukuran file maksimal 5MB';
    }
    
    // Check extension
    if (!validateFileExtension(file)) {
      errors['extension'] = 'Format file tidak didukung. Gunakan PDF, JPG, PNG, DOC, DOCX';
    }
    
    return {
      'isValid': errors.isEmpty,
      'errors': errors,
    };
  }

  // ✅ GET FILE EXTENSION
  static String getFileExtension(String fileName) {
    final parts = fileName.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : '';
  }

  // ✅ GET FILE TYPE ICON (Improved)
  static IconData getFileTypeIcon(String fileName) {
    final extension = getFileExtension(fileName);
    
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      case 'doc':
      case 'docx':
        return Icons.description;
      default:
        return Icons.insert_drive_file;
    }
  }

  // ✅ GET FILE TYPE NAME
  static String getFileTypeName(String fileName) {
    final extension = getFileExtension(fileName);
    
    switch (extension) {
      case 'pdf':
        return 'PDF Document';
      case 'jpg':
      case 'jpeg':
        return 'JPEG Image';
      case 'png':
        return 'PNG Image';
      case 'doc':
        return 'Word Document';
      case 'docx':
        return 'Word Document';
      default:
        return 'File';
    }
  }

  // ✅ FORMAT FILE SIZE
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / 1048576).toStringAsFixed(1)} MB';
  }

  // ✅ CHECK IF FILE IS IMAGE
  static bool isImageFile(String fileName) {
    final imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];
    final extension = getFileExtension(fileName);
    return imageExtensions.contains(extension);
  }

  // ✅ GET MIME TYPE
  static String getMimeType(String fileName) {
    final extension = getFileExtension(fileName);
    
    switch (extension) {
      case 'pdf':
        return 'application/pdf';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      default:
        return 'application/octet-stream';
    }
  }
}