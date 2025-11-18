// lib/models/berita_model.dart - Versi sederhana
import '../config/app_config.dart';

class BeritaModel {
  final int id;
  final String judul;
  final String konten;
  final String? gambar;
  final int penulisId;
  final String penulisNama;
  final int views;
  final DateTime publishedAt;

  BeritaModel({
    required this.id,
    required this.judul,
    required this.konten,
    this.gambar,
    required this.penulisId,
    required this.penulisNama,
    required this.views,
    required this.publishedAt,
  });

  factory BeritaModel.fromJson(Map<String, dynamic> json) {
    // Simple parsing - handle all cases
    return BeritaModel(
      id: _parseInt(json['id']),
      judul: json['judul']?.toString() ?? '',
      konten: json['konten']?.toString() ?? '',
      gambar: json['gambar']?.toString(),
      penulisId: _parseInt(json['penulis_id']),
      penulisNama: json['penulis_nama']?.toString() ?? '',
      views: _parseInt(json['views']),
      publishedAt: _parseDateTime(json['published_at']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'judul': judul,
      'konten': konten,
      'gambar': gambar,
      'penulis_id': penulisId,
      'penulis_nama': penulisNama,
      'views': views,
      'published_at': publishedAt.toIso8601String(),
    };
  }

  // ✅ URL untuk gambar berita
  String? get gambarUrl {
    if (gambar == null || gambar!.isEmpty) return null;
    return '${AppConfig.baseUrl}/berita.php?download=true&file_name=$gambar';
  }

  bool get hasGambar => gambar != null && gambar!.isNotEmpty;

  // ✅ Helper methods untuk tampilan
  String get formattedPublishedAt {
    return '${publishedAt.day}/${publishedAt.month}/${publishedAt.year}';
  }

  String get shortKonten {
    if (konten.length <= 100) return konten;
    return '${konten.substring(0, 100)}...';
  }

  String get viewsText {
    if (views < 1000) return '$views views';
    return '${(views / 1000).toStringAsFixed(1)}k views';
  }

  // ✅ Untuk preview di card
  String get previewText {
    final plainText = konten.replaceAll(RegExp(r'<[^>]*>'), '');
    if (plainText.length <= 150) return plainText;
    return '${plainText.substring(0, 150)}...';
  }
}