// lib/models/user_model.dart
class UserModel {
  final int id;
  final String nama;
  final String email;
  final String? noHp;
  final String? alamat;
  final String role; // 'admin' atau 'warga'
  final String? fotoProfile;
  final String status; // 'active' atau 'inactive'
  final DateTime? bergabungSejak;

  UserModel({
    required this.id,
    required this.nama,
    required this.email,
    this.noHp,
    this.alamat,
    required this.role,
    this.fotoProfile,
    required this.status,
    this.bergabungSejak,
  });

  // From JSON - FIXED UNTUK HANDLE NULL
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: int.parse(json['id'].toString()),
      nama: json['nama']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      noHp: json['no_hp']?.toString(), // Bisa null
      alamat: json['alamat']?.toString(), // Bisa null
      role: json['role']?.toString() ?? 'warga',
      fotoProfile: json['foto_profile']?.toString(), // Bisa null
      status: json['status']?.toString() ?? 'active',
      bergabungSejak: json['bergabung_sejak'] != null ? DateTime.tryParse(json['bergabung_sejak'].toString()) : null,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'email': email,
      'no_hp': noHp,
      'alamat': alamat,
      'role': role,
      'foto_profile': fotoProfile,
      'status': status,
      'bergabung_sejak': bergabungSejak?.toIso8601String(),
    };
  }

  // Check if Admin
  bool get isAdmin => role == 'admin';

  // Check if Warga
  bool get isWarga => role == 'warga';
}