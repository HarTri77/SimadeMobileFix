// lib/models/surat_model.dart - FIXED VERSION
import '../config/app_config.dart';

class SuratModel {
  final int id;
  final int userId;
  final String jenisSurat;
  final String keperluan;
  final String? filePendukung;
  final String status;
  final String? catatanAdmin;
  final String? fileHasil;
  final DateTime tanggalPengajuan;
  final DateTime? tanggalDiproses;
  final DateTime? tanggalSelesai;
  final int? diprosesOleh;
  
  // ✅ ADDED: Fields for admin view
  final String? namaPemohon;
  final String? email;
  final String? noHp;
  final String? alamat;

  SuratModel({
    required this.id,
    required this.userId,
    required this.jenisSurat,
    required this.keperluan,
    this.filePendukung,
    required this.status,
    this.catatanAdmin,
    this.fileHasil,
    required this.tanggalPengajuan,
    this.tanggalDiproses,
    this.tanggalSelesai,
    this.diprosesOleh,
    
    // ✅ ADDED: Admin fields
    this.namaPemohon,
    this.email,
    this.noHp,
    this.alamat,
  });

  factory SuratModel.fromJson(Map<String, dynamic> json) {
    return SuratModel(
      id: int.parse(json['id'].toString()),
      userId: int.parse(json['user_id'].toString()),
      jenisSurat: json['jenis_surat'] ?? '',
      keperluan: json['keperluan'] ?? '',
      filePendukung: json['file_pendukung'],
      status: json['status'] ?? 'pending',
      catatanAdmin: json['catatan_admin'],
      fileHasil: json['file_hasil'],
      tanggalPengajuan: DateTime.parse(json['tanggal_pengajuan']),
      tanggalDiproses: json['tanggal_diproses'] != null 
          ? DateTime.parse(json['tanggal_diproses']) 
          : null,
      tanggalSelesai: json['tanggal_selesai'] != null 
          ? DateTime.parse(json['tanggal_selesai']) 
          : null,
      diprosesOleh: json['diproses_oleh'] != null 
          ? int.parse(json['diproses_oleh'].toString()) 
          : null,
      
      // ✅ ADDED: Parse admin fields
      namaPemohon: json['nama_pemohon'],
      email: json['email'],
      noHp: json['no_hp'],
      alamat: json['alamat'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'jenis_surat': jenisSurat,
      'keperluan': keperluan,
      'file_pendukung': filePendukung,
      'status': status,
      'catatan_admin': catatanAdmin,
      'file_hasil': fileHasil,
      'tanggal_pengajuan': tanggalPengajuan.toIso8601String(),
      'tanggal_diproses': tanggalDiproses?.toIso8601String(),
      'tanggal_selesai': tanggalSelesai?.toIso8601String(),
      'diproses_oleh': diprosesOleh,
      
      // ✅ ADDED: Admin fields
      'nama_pemohon': namaPemohon,
      'email': email,
      'no_hp': noHp,
      'alamat': alamat,
    };
  }

  // ✅ FIXED: FILE URL METHODS - Use FileService instead of direct URL
  String? get filePendukungUrl {
    if (filePendukung == null || filePendukung!.isEmpty) return null;
    return filePendukung!; // Let FileService handle URL construction
  }

  String? get fileHasilUrl {
    if (fileHasil == null || fileHasil!.isEmpty) return null;
    return fileHasil!; // Let FileService handle URL construction
  }

  bool get hasFilePendukung => filePendukung != null && filePendukung!.isNotEmpty;
  bool get hasFileHasil => fileHasil != null && fileHasil!.isNotEmpty;

  // ✅ FIXED: FILE TYPE HELPERS - Better file type detection
  String get filePendukungType {
    if (!hasFilePendukung) return '';
    return _getFileTypeDisplayName(filePendukung!);
  }

  String get fileHasilType {
    if (!hasFileHasil) return '';
    return _getFileTypeDisplayName(fileHasil!);
  }

  String _getFileTypeDisplayName(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf': return 'PDF Document';
      case 'jpg': 
      case 'jpeg': return 'JPEG Image';
      case 'png': return 'PNG Image';
      case 'doc': return 'Word Document';
      case 'docx': return 'Word Document';
      case 'gif': return 'GIF Image';
      case 'bmp': return 'Bitmap Image';
      default: return 'File';
    }
  }

  // ✅ FIXED: STATUS HELPERS - More descriptive
  String get statusText {
    switch (status) {
      case 'pending': return 'Menunggu';
      case 'diproses': return 'Diproses';
      case 'selesai': return 'Selesai';
      case 'ditolak': return 'Ditolak';
      default: return 'Menunggu';
    }
  }

  String get statusDescription {
    switch (status) {
      case 'pending': return 'Surat menunggu diproses admin';
      case 'diproses': return 'Surat sedang diproses';
      case 'selesai': return 'Surat telah selesai';
      case 'ditolak': return 'Surat ditolak';
      default: return 'Status tidak diketahui';
    }
  }

  bool get isPending => status == 'pending';
  bool get isDiproses => status == 'diproses';
  bool get isSelesai => status == 'selesai';
  bool get isDitolak => status == 'ditolak';

  // ✅ FIXED: CANCELABLE CHECK
  bool get canCancel => isPending;

  // ✅ FIXED: STATUS COLOR - Return Color instead of String
  int get statusColorValue {
    switch (status) {
      case 'pending': return 0xFFFF9800; // Orange
      case 'diproses': return 0xFF2196F3; // Blue
      case 'selesai': return 0xFF4CAF50; // Green
      case 'ditolak': return 0xFFF44336; // Red
      default: return 0xFF9E9E9E; // Grey
    }
  }

  // ✅ ADDED: Helper for duration calculation
  Duration get processingDuration {
    if (tanggalSelesai != null && tanggalPengajuan != null) {
      return tanggalSelesai!.difference(tanggalPengajuan);
    } else if (tanggalDiproses != null && tanggalPengajuan != null) {
      return tanggalDiproses!.difference(tanggalPengajuan);
    }
    return Duration.zero;
  }

  String get processingTimeText {
    final duration = processingDuration;
    if (duration.inDays > 0) {
      return '${duration.inDays} hari';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} jam';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes} menit';
    }
    return 'Beberapa saat';
  }

  // ✅ ADDED: Check if file is image for preview
  bool get isFilePendukungImage {
    if (!hasFilePendukung) return false;
    final ext = filePendukung!.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp'].contains(ext);
  }

  bool get isFileHasilImage {
    if (!hasFileHasil) return false;
    final ext = fileHasil!.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp'].contains(ext);
  }

  // ✅ ADDED: Get file size text (placeholder - would need actual file size from API)
  String get filePendukungSizeText => hasFilePendukung ? 'File' : '';
  String get fileHasilSizeText => hasFileHasil ? 'File' : '';

  // ✅ ADDED: Admin view helpers
  bool get hasPemohonInfo => namaPemohon != null && namaPemohon!.isNotEmpty;
  
  String get pemohonInfo {
    if (!hasPemohonInfo) return 'Tidak ada info pemohon';
    return '$namaPemohon${email != null ? ' • $email' : ''}';
  }

  // ✅ ADDED: Format dates for display
  String get formattedTanggalPengajuan {
    return '${tanggalPengajuan.day}/${tanggalPengajuan.month}/${tanggalPengajuan.year}';
  }

  String get formattedWaktuPengajuan {
    return '${tanggalPengajuan.hour.toString().padLeft(2, '0')}:${tanggalPengajuan.minute.toString().padLeft(2, '0')}';
  }
}