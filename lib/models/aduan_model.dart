// lib/models/aduan_model.dart
import '../config/app_config.dart';
import 'package:flutter/material.dart';

class AduanModel {
  final int id;
  final int userId;
  final String judul;
  final String isiAduan;
  final int? kategori;
  final String prioritas;
  final String status;
  final String? lokasi;
  final String? lampiran;
  final String? tanggapan;
  final int? diprosesOleh;
  final DateTime createdAt;
  final DateTime? tanggalDiproses;
  final DateTime? tanggalSelesai;
  final DateTime updatedAt;

  // Fields from joins
  final String? namaKategori;
  final String userNama;
  final String? adminNama;

  AduanModel({
    required this.id,
    required this.userId,
    required this.judul,
    required this.isiAduan,
    this.kategori,
    required this.prioritas,
    required this.status,
    this.lokasi,
    this.lampiran,
    this.tanggapan,
    this.diprosesOleh,
    required this.createdAt,
    this.tanggalDiproses,
    this.tanggalSelesai,
    required this.updatedAt,
    this.namaKategori,
    required this.userNama,
    this.adminNama,
  });

  factory AduanModel.fromJson(Map<String, dynamic> json) {
    // Safe parsing functions
    int safeParseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      if (value is double) return value.toInt();
      return 0;
    }

    DateTime? safeParseDateTime(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (e) {
          return null;
        }
      }
      return null;
    }

    String safeParseString(dynamic value) {
      if (value == null) return '';
      return value.toString();
    }

    return AduanModel(
      id: safeParseInt(json['id']),
      userId: safeParseInt(json['user_id']),
      judul: safeParseString(json['judul']),
      isiAduan: safeParseString(json['isi_aduan']),
      kategori: json['kategori'] != null ? safeParseInt(json['kategori']) : null,
      prioritas: safeParseString(json['prioritas'] ?? 'rendah'),
      status: safeParseString(json['status'] ?? 'diterima'),
      lokasi: json['lokasi']?.toString(),
      lampiran: json['lampiran']?.toString(),
      tanggapan: json['tanggapan']?.toString(),
      diprosesOleh: json['diproses_oleh'] != null ? safeParseInt(json['diproses_oleh']) : null,
      createdAt: safeParseDateTime(json['created_at']) ?? DateTime.now(),
      tanggalDiproses: safeParseDateTime(json['tanggal_diproses']),
      tanggalSelesai: safeParseDateTime(json['tanggal_selesai']),
      updatedAt: safeParseDateTime(json['updated_at']) ?? DateTime.now(),
      namaKategori: json['nama_kategori']?.toString(),
      userNama: safeParseString(json['user_nama']),
      adminNama: json['admin_nama']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'judul': judul,
      'isi_aduan': isiAduan,
      'kategori': kategori,
      'prioritas': prioritas,
      'status': status,
      'lokasi': lokasi,
      'lampiran': lampiran,
      'tanggapan': tanggapan,
      'diproses_oleh': diprosesOleh,
      'created_at': createdAt.toIso8601String(),
      'tanggal_diproses': tanggalDiproses?.toIso8601String(),
      'tanggal_selesai': tanggalSelesai?.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'nama_kategori': namaKategori,
      'user_nama': userNama,
      'admin_nama': adminNama,
    };
  }

  // Helper methods for UI
  String get statusText {
    switch (status) {
      case 'diterima': return 'Diterima';
      case 'diproses': return 'Diproses';
      case 'selesai': return 'Selesai';
      case 'ditolak': return 'Ditolak';
      default: return 'Diterima';
    }
  }

  Color get statusColor {
    switch (status) {
      case 'diterima': return Colors.orange;
      case 'diproses': return Colors.blue;
      case 'selesai': return Colors.green;
      case 'ditolak': return Colors.red;
      default: return Colors.orange;
    }
  }

  String get prioritasText {
    switch (prioritas) {
      case 'rendah': return 'Rendah';
      case 'sedang': return 'Sedang';
      case 'tinggi': return 'Tinggi';
      default: return 'Rendah';
    }
  }

  Color get prioritasColor {
    switch (prioritas) {
      case 'rendah': return Colors.green;
      case 'sedang': return Colors.orange;
      case 'tinggi': return Colors.red;
      default: return Colors.green;
    }
  }

  String get formattedCreatedAt {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  String? get formattedTanggalDiproses {
    if (tanggalDiproses == null) return null;
    return '${tanggalDiproses!.day}/${tanggalDiproses!.month}/${tanggalDiproses!.year}';
  }

  String? get formattedTanggalSelesai {
    if (tanggalSelesai == null) return null;
    return '${tanggalSelesai!.day}/${tanggalSelesai!.month}/${tanggalSelesai!.year}';
  }
}