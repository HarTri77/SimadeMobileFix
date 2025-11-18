// lib/models/kategori_aduan_model.dart
import 'package:flutter/material.dart';

class KategoriAduanModel {
  final int id;
  final String namaKategori;
  final String? deskripsi;
  final String warna;
  final String icon;
  final bool aktif;

  KategoriAduanModel({
    required this.id,
    required this.namaKategori,
    this.deskripsi,
    required this.warna,
    required this.icon,
    required this.aktif,
  });

  factory KategoriAduanModel.fromJson(Map<String, dynamic> json) {
    return KategoriAduanModel(
      id: int.parse(json['id'].toString()),
      namaKategori: json['nama_kategori'] ?? '',
      deskripsi: json['deskripsi'],
      warna: json['warna'] ?? '#3366CC',
      icon: json['icon'] ?? 'report',
      aktif: json['aktif'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_kategori': namaKategori,
      'deskripsi': deskripsi,
      'warna': warna,
      'icon': icon,
      'aktif': aktif ? 1 : 0,
    };
  }

  // Helper untuk mendapatkan IconData dari string icon
  IconData get iconData {
    switch (icon) {
      case 'construction': return Icons.construction;
      case 'cleaning_services': return Icons.cleaning_services;
      case 'security': return Icons.security;
      case 'description': return Icons.description;
      case 'help': return Icons.help;
      default: return Icons.report;
    }
  }

  Color get color {
    return Color(int.parse(warna.replaceFirst('#', '0xFF')));
  }
}