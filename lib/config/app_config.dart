// lib/config/app_config.dart
class AppConfig {
  // 🔥 BASE URL API (Ganti sesuai server kamu)
  static const String baseUrl = 'https://simade.miomihost.com/api/';
  
  // 🔥 API ENDPOINTS
  static const String loginEndpoint = '$baseUrl/login.php';
  static const String registerEndpoint = '$baseUrl/register.php';
  static const String dashboardEndpoint = '$baseUrl/dashboard.php';
  static const String suratEndpoint = '$baseUrl/surat.php'; 
  
  // 🔥 APP INFO
  static const String appName = 'SIMADE';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Sistem Informasi Masyarakat Desa';

  // 🔥 JENIS SURAT YANG TERSEDIA 
  static const List<Map<String, String>> jenisSuratList = [
    {'value': 'sktm', 'label': 'Surat Keterangan Tidak Mampu (SKTM)'},
    {'value': 'domisili', 'label': 'Surat Keterangan Domisili'},
    {'value': 'usaha', 'label': 'Surat Keterangan Usaha'},
    {'value': 'kelahiran', 'label': 'Surat Keterangan Kelahiran'},
    {'value': 'kematian', 'label': 'Surat Keterangan Kematian'},
    {'value': 'belum_menikah', 'label': 'Surat Keterangan Belum Menikah'},
    {'value': 'penghasilan', 'label': 'Surat Keterangan Penghasilan'},
    {'value': 'lainnya', 'label': 'Surat Keterangan Lainnya'},
  ];
}