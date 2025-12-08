import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../config/app_config.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';
import '../../utils/app_colors.dart';
import '../../widgets/glass_container.dart';
import '../auth/login_page.dart';
import '../surat/ajukan_surat_page.dart';
import '../surat/daftar_surat_page.dart';
import '../berita/daftar_berita_page.dart';
import '../berita/detail_berita_page.dart';
import '../aduan/ajukan_aduan_page.dart';
import '../aduan/daftar_aduan_page.dart';

class WargaDashboard extends StatefulWidget {
  const WargaDashboard({super.key});

  @override
  State<WargaDashboard> createState() => _WargaDashboardState();
}

class _WargaDashboardState extends State<WargaDashboard> with SingleTickerProviderStateMixin {
  Map<String, dynamic>? dashboardData;
  UserModel? currentUser;
  bool isLoading = true;
  bool isError = false;
  int _selectedIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isDateFormatInitialized = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Inisialisasi date formatting untuk locale Indonesia
      await initializeDateFormatting('id_ID', null);
      setState(() {
        _isDateFormatInitialized = true;
      });
      
      await _loadUserData();
      await _loadDashboard();
      
      if (mounted) {
        _animationController.forward();
      }
    } catch (e) {
      print('Error initializing app: $e');
      // Fallback: tetap load data meskipun date formatting gagal
      await _loadUserData();
      await _loadDashboard();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await AuthService.getCurrentUser();
      if (mounted) {
        setState(() => currentUser = user);
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> _loadDashboard() async {
    if (mounted) {
      setState(() {
        isLoading = true;
        isError = false;
      });
    }
    
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse(AppConfig.dashboardEndpoint),
        headers: {
          'Content-Type': 'application/json', 
          'Authorization': 'Bearer $token'
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          if (mounted) {
            setState(() {
              dashboardData = data['data'];
              isLoading = false;
            });
          }
          return;
        }
      }
      
      if (mounted) {
        setState(() {
          isError = true;
          isLoading = false;
        });
      }
      
    } catch (e) {
      if (mounted) {
        setState(() {
          isError = true;
          isLoading = false;
        });
      }
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 19) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  String _formatDate(DateTime date) {
    if (!_isDateFormatInitialized) {
      return '${date.day}/${date.month}/${date.year}';
    }
    
    try {
      return DateFormat('EEEE, d MMMM y', 'id_ID').format(date);
    } catch (e) {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatNewsDate(String? dateString) {
    if (dateString == null) return '';
    
    if (!_isDateFormatInitialized) {
      try {
        final date = DateTime.parse(dateString);
        return '${date.day}/${date.month}/${date.year}';
      } catch (e) {
        return '';
      }
    }
    
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('d MMMM y', 'id_ID').format(date);
    } catch (e) {
      return '';
    }
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Konfirmasi Logout', 
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text('Apakah Anda yakin ingin logout?',
            style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: GoogleFonts.poppins()),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await AuthService.logout();
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              }
            },
            child: Text('Logout', 
                style: GoogleFonts.poppins(color: const Color(0xFFFF6B6B))),
          ),
        ],
      ),
    );
  }

  int _getPendingSuratCount() {
    if (dashboardData?['surat_saya'] == null) return 0;
    final List<dynamic> suratList = dashboardData!['surat_saya'];
    return suratList.where((surat) => surat['status'] == 'pending').length;
  }

int _getTotalAduanCount() {
  try {
    if (dashboardData?['statistik'] == null) return 0;
    final statistik = dashboardData!['statistik'];
    final total = statistik['total_aduan'];
    if (total is int) return total;
    if (total is String) return int.tryParse(total) ?? 0;
    return 0;
  } catch (e) {
    print('Error parsing total aduan: $e');
    return 0;
  }
}

int _getPendingAduanCount() {
  try {
    if (dashboardData?['aduan_saya'] == null) return 0;
    final List<dynamic> aduanList = dashboardData!['aduan_saya'];
    
    int count = 0;
    for (var aduan in aduanList) {
      try {
        final status = aduan['status']?.toString() ?? '';
        if (status == 'diterima') count++;
      } catch (e) {
        print('Error checking aduan status: $e');
      }
    }
    return count;
  } catch (e) {
    print('Error parsing pending aduan: $e');
    return 0;
  }
}

  Widget _buildLoadingState(bool isSmallScreen) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: isSmallScreen ? 60 : 80,
              height: isSmallScreen ? 60 : 80,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: const Color(0xFF6C5CE7),
                backgroundColor: const Color(0xFF6C5CE7).withOpacity(0.1),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Memuat Dashboard...',
              style: GoogleFonts.poppins(
                fontSize: isSmallScreen ? 16 : 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2D3436),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Menyiapkan data terbaru untuk Anda',
              style: GoogleFonts.poppins(
                color: const Color(0xFF636E72),
                fontSize: isSmallScreen ? 13 : 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(bool isSmallScreen) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: isSmallScreen ? 60 : 80,
                color: const Color(0xFFFF6B6B),
              ),
              const SizedBox(height: 20),
              Text(
                'Gagal Memuat Data',
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 18 : 22,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2D3436),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Terjadi kesalahan saat memuat data dashboard.\nSilakan coba lagi.',
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 13 : 14,
                  color: const Color(0xFF636E72),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Container(
                height: isSmallScreen ? 48 : 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6C5CE7).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _loadDashboard,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: Text(
                    'COBA LAGI',
                    style: GoogleFonts.poppins(
                      fontSize: isSmallScreen ? 14 : 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    if (isLoading) return _buildLoadingState(isSmallScreen);
    if (isError) return _buildErrorState(isSmallScreen);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: _selectedIndex == 0
            ? _buildDashboard(isSmallScreen)
            : _buildProfile(isSmallScreen),
      ),
      bottomNavigationBar: _buildBottomNav(isSmallScreen),
    );
  }

  Widget _buildDashboard(bool isSmallScreen) {
    return RefreshIndicator(
      onRefresh: _loadDashboard,
      color: const Color(0xFF6C5CE7),
      backgroundColor: Colors.white,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildHeader(isSmallScreen),
          _buildWelcomeCard(isSmallScreen),
          _buildStatsGrid(isSmallScreen),
          _buildQuickActions(isSmallScreen),
          _buildNewsSection(isSmallScreen),
          _buildMySuratSection(isSmallScreen),
          const SliverToBoxAdapter(child: SizedBox(height: 30)),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isSmallScreen) {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.fromLTRB(20, isSmallScreen ? 20 : 30, 20, 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(),
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF636E72),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  currentUser?.nama.split(' ')[0] ?? 'Warga',
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 22 : 26,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2D3436),
                  ),
                ),
              ],
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
  onPressed: _loadDashboard, // 🔥 untuk refresh ulang data
  icon: const Icon(Icons.refresh_rounded), // 🔥 biar lebih jelas icon reload
  color: const Color(0xFF6C5CE7),
  iconSize: isSmallScreen ? 20 : 22,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(bool isSmallScreen) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6C5CE7),
              Color(0xFFA29BFE),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C5CE7).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: isSmallScreen ? 50 : 60,
              height: isSmallScreen ? 50 : 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  currentUser?.nama.isNotEmpty == true
                      ? currentUser!.nama.substring(0, 1).toUpperCase()
                      : 'W',
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 20 : 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF6C5CE7),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selamat datang!',
                    style: GoogleFonts.poppins(
                      fontSize: isSmallScreen ? 14 : 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currentUser?.nama ?? 'Warga',
                    style: GoogleFonts.poppins(
                      fontSize: isSmallScreen ? 16 : 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(DateTime.now()),
                    style: GoogleFonts.poppins(
                      fontSize: isSmallScreen ? 11 : 12,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(bool isSmallScreen) {
    final stats = [
      {
        'title': 'Total Surat',
        'value': dashboardData?['statistik']['total_surat']?.toString() ?? '0',
        'icon': Icons.description_rounded,
        'color': const Color(0xFF6C5CE7),
        'gradient': [const Color(0xFF6C5CE7), const Color(0xFFA29BFE)],
      },
      {
        'title': 'Pending',
        'value': _getPendingSuratCount().toString(),
        'icon': Icons.pending_actions_rounded,
        'color': const Color(0xFFFFA502),
        'gradient': [const Color(0xFFFFA502), const Color(0xFFFFB142)],
      },
      {
        'title': 'Total Aduan',
        'value': _getTotalAduanCount().toString(),
        'icon': Icons.report_problem_rounded,
        'color': const Color(0xFFFF6B6B),
        'gradient': [const Color(0xFFFF6B6B), const Color(0xFFFF8E8E)],
      },
      {
        'title': 'Aduan Pending',
        'value': _getPendingAduanCount().toString(),
        'icon': Icons.hourglass_empty_rounded,
        'color': const Color(0xFF00D2D3),
        'gradient': [const Color(0xFF00D2D3), const Color(0xFF26A69A)],
      },
    ];

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: isSmallScreen ? 1.3 : 1.4,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final stat = stats[index];
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _fadeAnimation,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: stat['gradient'] as List<Color>,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: (stat['color'] as Color).withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              stat['icon'] as IconData,
                              color: Colors.white,
                              size: isSmallScreen ? 18 : 20,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stat['value'] as String,
                            style: GoogleFonts.poppins(
                              fontSize: isSmallScreen ? 20 : 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            stat['title'] as String,
                            style: GoogleFonts.poppins(
                              fontSize: isSmallScreen ? 11 : 12,
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          childCount: stats.length,
        ),
      ),
    );
  }

  Widget _buildQuickActions(bool isSmallScreen) {
    final actions = [
      {
        'title': 'Ajukan Surat',
        'icon': Icons.mail_outline_rounded,
        'color': const Color(0xFF6C5CE7),
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AjukanSuratPage())),
      },
      {
        'title': 'Baca Berita',
        'icon': Icons.newspaper_rounded,
        'color': const Color(0xFF00D2D3),
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (context) => DaftarBeritaPage())),
      },
      {
        'title': 'Kirim Aduan',
        'icon': Icons.report_gmailerrorred_rounded,
        'color': const Color(0xFFFF6B6B),
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (context) => AjukanAduanPage())),
      },
      {
        'title': 'Aduan Saya',
        'icon': Icons.list_alt_rounded,
        'color': const Color(0xFFFFA502),
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (context) => DaftarAduanPage())),
      },
    ];

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Layanan Cepat',
              style: GoogleFonts.poppins(
                fontSize: isSmallScreen ? 16 : 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2D3436),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: actions.map((action) {
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: action['onTap'] as VoidCallback,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: isSmallScreen ? 40 : 48,
                                height: isSmallScreen ? 40 : 48,
                                decoration: BoxDecoration(
                                  color: (action['color'] as Color).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  action['icon'] as IconData,
                                  color: action['color'] as Color,
                                  size: isSmallScreen ? 20 : 22,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                action['title'] as String,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: isSmallScreen ? 10 : 11,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF2D3436),
                                ),
                                maxLines: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsSection(bool isSmallScreen) {
    final List<dynamic> beritaList = dashboardData?['berita_terbaru'] ?? [];

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Berita Terbaru',
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2D3436),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DaftarBeritaPage())),
                  child: Text(
                    'Lihat Semua',
                    style: GoogleFonts.poppins(
                      fontSize: isSmallScreen ? 11 : 12,
                      color: const Color(0xFF6C5CE7),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (beritaList.isNotEmpty)
              ...List.generate(
                beritaList.length > 3 ? 3 : beritaList.length,
                (index) {
                  final berita = beritaList[index];
                  int getSafeBeritaId() {
                    try {
                      if (berita['id'] == null) return 0;
                      if (berita['id'] is int) return berita['id'];
                      if (berita['id'] is String) return int.tryParse(berita['id']) ?? 0;
                      return 0;
                    } catch (e) {
                      return 0;
                    }
                  }
                  final beritaId = getSafeBeritaId();
                  
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            if (beritaId > 0) {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => DetailBeritaPage(beritaId: beritaId)));
                            }
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: GlassContainer(
                            blur: 10,
                            opacity: 0.08,
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    width: isSmallScreen ? 50 : 60,
                                    height: isSmallScreen ? 50 : 60,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.article_rounded, 
                                      color: Colors.white, 
                                      size: 24
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          berita['judul']?.toString() ?? 'Judul Berita',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                            fontSize: isSmallScreen ? 13 : 14,
                                            color: const Color(0xFF2D3436),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.calendar_today_rounded,
                                              size: 12,
                                              color: Colors.grey[500],
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              _formatNewsDate(berita['published_at']?.toString()),
                                              style: GoogleFonts.poppins(
                                                fontSize: isSmallScreen ? 10 : 11,
                                                color: const Color(0xFF636E72),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios_rounded, 
                                    size: 16, 
                                    color: Colors.grey[400]
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              )
            else
              FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.article_outlined, 
                          size: 40, 
                          color: Colors.grey[300]
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Belum ada berita',
                          style: GoogleFonts.poppins(
                            fontSize: 14, 
                            color: const Color(0xFF636E72),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Berita terbaru akan muncul di sini',
                          style: GoogleFonts.poppins(
                            fontSize: 12, 
                            color: const Color(0xFF636E72)
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMySuratSection(bool isSmallScreen) {
    final List<dynamic> suratList = dashboardData?['surat_saya'] ?? [];

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pengajuan Surat Terbaru',
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2D3436),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DaftarSuratPage())),
                  child: Text(
                    'Lihat Semua',
                    style: GoogleFonts.poppins(
                      fontSize: isSmallScreen ? 11 : 12,
                      color: const Color(0xFF6C5CE7),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (suratList.isNotEmpty)
              GlassContainer(
                blur: 10,
                opacity: 0.08,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: Column(
                    children: List.generate(
                      suratList.length > 3 ? 3 : suratList.length,
                      (index) {
                        final surat = suratList[index];
                        final isLast = index == (suratList.length > 3 ? 2 : suratList.length - 1);
                        
                        Color statusColor;
                        String statusText;
                        IconData statusIcon;
                        
                        switch (surat['status'] ?? 'pending') {
                          case 'pending':
                            statusColor = const Color(0xFFFFA502);
                            statusText = 'Pending';
                            statusIcon = Icons.pending_actions_rounded;
                            break;
                          case 'diproses':
                            statusColor = const Color(0xFF6C5CE7);
                            statusText = 'Diproses';
                            statusIcon = Icons.autorenew_rounded;
                            break;
                          case 'selesai':
                            statusColor = const Color(0xFF00D2D3);
                            statusText = 'Selesai';
                            statusIcon = Icons.check_circle_rounded;
                            break;
                          default:
                            statusColor = const Color(0xFFFF6B6B);
                            statusText = 'Ditolak';
                            statusIcon = Icons.cancel_rounded;
                        }
                        
                        return FadeTransition(
                          opacity: _fadeAnimation,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: isLast ? Colors.transparent : Colors.grey[100]!,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: isSmallScreen ? 40 : 48,
                                  height: isSmallScreen ? 40 : 48,
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    statusIcon,
                                    color: statusColor,
                                    size: isSmallScreen ? 18 : 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        surat['jenis_surat'] ?? 'Surat',
                                        style: GoogleFonts.poppins(
                                          fontSize: isSmallScreen ? 14 : 15,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF2D3436),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        surat['tanggal_pengajuan'] ?? '-',
                                        style: GoogleFonts.poppins(
                                          fontSize: isSmallScreen ? 11 : 12,
                                          color: const Color(0xFF636E72),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    statusText,
                                    style: GoogleFonts.poppins(
                                      fontSize: isSmallScreen ? 10 : 11,
                                      fontWeight: FontWeight.w600,
                                      color: statusColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              )
            else
              FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.description_outlined, 
                          size: 40, 
                          color: Colors.grey[300]
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Belum ada pengajuan surat',
                          style: GoogleFonts.poppins(
                            fontSize: 14, 
                            color: const Color(0xFF636E72),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ajukan surat pertama Anda',
                          style: GoogleFonts.poppins(
                            fontSize: 12, 
                            color: const Color(0xFF636E72)
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfile(bool isSmallScreen) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(isSmallScreen ? 25 : 30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: isSmallScreen ? 80 : 100,
                  height: isSmallScreen ? 80 : 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      currentUser?.nama.isNotEmpty == true
                          ? currentUser!.nama.substring(0, 1).toUpperCase()
                          : 'W',
                      style: GoogleFonts.poppins(
                        fontSize: isSmallScreen ? 32 : 40,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF6C5CE7),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  currentUser?.nama ?? 'Warga',
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 20 : 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  currentUser?.email ?? '',
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 13 : 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Warga Aktif',
                    style: GoogleFonts.poppins(
                      fontSize: isSmallScreen ? 11 : 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildProfileItem(
                  icon: Icons.phone_rounded,
                  label: 'No. Telepon',
                  value: currentUser?.noHp ?? '-',
                  isSmallScreen: isSmallScreen,
                ),
                const SizedBox(height: 12),
                _buildProfileItem(
                  icon: Icons.home_rounded,
                  label: 'Alamat',
                  value: currentUser?.alamat ?? '-',
                  isSmallScreen: isSmallScreen,
                ),
                const SizedBox(height: 12),
                _buildProfileItem(
                  icon: Icons.date_range_rounded,
                  label: 'Bergabung Sejak',
                  value: currentUser?.bergabungSejak != null ? DateFormat('dd MMMM yyyy').format(currentUser!.bergabungSejak!) : '2025',
                  isSmallScreen: isSmallScreen,
                ),
                const SizedBox(height: 30),
                Container(
                  width: double.infinity,
                  height: isSmallScreen ? 50 : 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF6B6B), Color(0xFFEC407A)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF6B6B).withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _logout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.logout_rounded, color: Colors.white, size: 20),
                        const SizedBox(width: 10),
                        Text(
                          'KELUAR DARI AKUN',
                          style: GoogleFonts.poppins(
                            fontSize: isSmallScreen ? 14 : 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 30)),
      ],
    );
  }

  Widget _buildProfileItem({
    required IconData icon,
    required String label,
    required String value,
    required bool isSmallScreen,
  }) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: isSmallScreen ? 45 : 50,
              height: isSmallScreen ? 45 : 50,
              decoration: BoxDecoration(
                color: const Color(0xFF6C5CE7).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF6C5CE7),
                size: isSmallScreen ? 20 : 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: isSmallScreen ? 12 : 13,
                      color: const Color(0xFF636E72),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: isSmallScreen ? 14 : 15,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2D3436),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(bool isSmallScreen) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: isSmallScreen ? 8 : 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                isActive: _selectedIndex == 0,
                onTap: () => setState(() => _selectedIndex = 0),
                isSmallScreen: isSmallScreen,
              ),
              _buildNavItem(
                icon: Icons.mail_rounded,
                label: 'Surat',
                isActive: false,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DaftarSuratPage())),
                isSmallScreen: isSmallScreen,
              ),
              _buildNavItem(
                icon: Icons.newspaper_rounded,
                label: 'Berita',
                isActive: false,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DaftarBeritaPage())),
                isSmallScreen: isSmallScreen,
              ),
              _buildNavItem(
                icon: Icons.person_rounded,
                label: 'Profile',
                isActive: _selectedIndex == 1,
                onTap: () => setState(() => _selectedIndex = 1),
                isSmallScreen: isSmallScreen,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    required bool isSmallScreen,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF6C5CE7).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? const Color(0xFF6C5CE7) : const Color(0xFF636E72),
              size: isSmallScreen ? 20 : 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: isSmallScreen ? 10 : 11,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? const Color(0xFF6C5CE7) : const Color(0xFF636E72),
              ),
            ),
          ],
        ),
      ),
    );
  }
}