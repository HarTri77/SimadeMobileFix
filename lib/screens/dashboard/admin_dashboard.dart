// lib/screens/dashboard/admin_dashboard.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../config/app_config.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';
import '../../utils/app_colors.dart';
import '../../widgets/glass_container.dart';
import '../auth/login_page.dart';
import '../admin/admin_kelola_surat_page.dart';
import '../admin/admin_kelola_berita_page.dart';
import '../admin/admin_kelola_aduan_page.dart';
import '../admin/admin_profile_page.dart';
import '../admin/admin_tambah_berita_page.dart';
import 'package:intl/date_symbol_data_local.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> with SingleTickerProviderStateMixin {
  Map<String, dynamic>? dashboardData;
  UserModel? currentUser;
  bool isLoading = true;
  bool isRefreshing = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int _selectedIndex = 0;
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
      setState(() => isLoading = true);
    }
    
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse(AppConfig.dashboardEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          if (mounted) {
            setState(() {
              dashboardData = data['data'];
              isLoading = false;
            });
          }
        }
      } else {
        if (mounted) {
          setState(() => isLoading = false);
        }
        _showErrorSnackbar('Gagal memuat dashboard: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
      }
      _showErrorSnackbar('Gagal memuat dashboard: $e');
    }
  }

  Future<void> _refreshData() async {
    setState(() => isRefreshing = true);
    await _loadDashboard();
    if (mounted) {
      setState(() => isRefreshing = false);
    }
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFFF6B6B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 19) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  String _formatDate(DateTime date) {
    if (!_isDateFormatInitialized) {
      // Fallback format jika date formatting belum siap
      return '${date.day}/${date.month}/${date.year}';
    }
    
    try {
      return DateFormat('EEEE, d MMMM y', 'id_ID').format(date);
    } catch (e) {
      // Fallback format jika ada error
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatDateTime(String dateString) {
    if (!_isDateFormatInitialized) {
      // Fallback format jika date formatting belum siap
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    }
    
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (e) {
      // Fallback format jika ada error
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
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
                color: const Color(0xFF00D2D3),
                backgroundColor: const Color(0xFF00D2D3).withOpacity(0.1),
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

  Widget _buildHeader(bool isSmallScreen) {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.fromLTRB(20, isSmallScreen ? 40 : 50, 20, 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF00D2D3),
              Color(0xFF26A69A),
            ],
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00D2D3).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getGreeting(),
                      style: GoogleFonts.poppins(
                        fontSize: isSmallScreen ? 16 : 18,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentUser?.nama ?? 'Admin',
                      style: GoogleFonts.poppins(
                        fontSize: isSmallScreen ? 22 : 26,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: _refreshData,
                    icon: Icon(
                      isRefreshing ? Icons.refresh : Icons.refresh_rounded,
                      color: Colors.white,
                      size: isSmallScreen ? 20 : 24,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _formatDate(DateTime.now()),
              style: GoogleFonts.poppins(
                fontSize: isSmallScreen ? 13 : 14,
                color: Colors.white.withOpacity(0.8),
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
        'color': const Color(0xFF00D2D3),
        'gradient': [const Color(0xFF00D2D3), const Color(0xFF26A69A)],
      },
      {
        'title': 'Pending',
        'value': dashboardData?['statistik']['surat_pending']?.toString() ?? '0',
        'icon': Icons.pending_actions_rounded,
        'color': const Color(0xFFFFA502),
        'gradient': [const Color(0xFFFFA502), const Color(0xFFFFB142)],
      },
      {
        'title': 'Total Warga',
        'value': dashboardData?['statistik']['total_warga']?.toString() ?? '0',
        'icon': Icons.people_rounded,
        'color': const Color(0xFF6C5CE7),
        'gradient': [const Color(0xFF6C5CE7), const Color(0xFFA29BFE)],
      },
      {
        'title': 'Aduan Baru',
        'value': dashboardData?['statistik']['aduan_saya']?.toString() ?? '0',
        'icon': Icons.report_problem_rounded,
        'color': const Color(0xFFFF6B6B),
        'gradient': [const Color(0xFFFF6B6B), const Color(0xFFFF8E8E)],
      },
    ];

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      sliver: SliverGrid(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    childAspectRatio: isSmallScreen ? 0.85 : 1.1,
    crossAxisSpacing: 15,
    mainAxisSpacing: 15,
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
                    borderRadius: BorderRadius.circular(20),
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
  mainAxisSize: MainAxisSize.min,
  children: [
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            stat['icon'] as IconData,
            color: Colors.white,
            size: isSmallScreen ? 20 : 24,
          ),
        ),
      ],
    ),

    SizedBox(height: isSmallScreen ? 10 : 12),

    Text(
      stat['value'] as String,
      style: GoogleFonts.poppins(
        fontSize: isSmallScreen ? 22 : 28,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    ),
    const SizedBox(height: 4),
    Text(
      stat['title'] as String,
      style: GoogleFonts.poppins(
        fontSize: isSmallScreen ? 12 : 13,
        color: Colors.white.withOpacity(0.9),
        fontWeight: FontWeight.w500,
      ),
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
        'title': 'Tambah Berita',
        'icon': Icons.add_rounded,
        'color': const Color(0xFF00D2D3),
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AdminTambahBeritaPage()),
        ),
      },
      {
        'title': 'Kelola Surat',
        'icon': Icons.mail_outline_rounded,
        'color': const Color(0xFF6C5CE7),
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AdminKelolaSuratPage()),
        ),
      },
      {
        'title': 'Lihat Aduan',
        'icon': Icons.report_gmailerrorred_rounded,
        'color': const Color(0xFFFFA502),
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AdminKelolaAduanPage()),
        ),
      },
    ];

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Aksi Cepat',
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
                          padding: const EdgeInsets.all(16),
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
                                width: isSmallScreen ? 40 : 50,
                                height: isSmallScreen ? 40 : 50,
                                decoration: BoxDecoration(
                                  color: (action['color'] as Color).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  action['icon'] as IconData,
                                  color: action['color'] as Color,
                                  size: isSmallScreen ? 20 : 24,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                action['title'] as String,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: isSmallScreen ? 11 : 12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF2D3436),
                                ),
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

  Widget _buildMenuSection(bool isSmallScreen) {
final menus = [
  {
    'title': 'Kelola Surat',
    'subtitle': 'Manajemen surat masuk & keluar',
    'icon': Icons.mail_rounded,
    'color': const Color(0xFF6C5CE7),
    'count': dashboardData?['statistik']['surat_pending']?.toString() ?? '',
    'onTap': () => Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AdminKelolaSuratPage()),
    ),
  },
  {
    'title': 'Kelola Berita',
    'subtitle': 'Publikasi berita & pengumuman',
    'icon': Icons.newspaper_rounded,
    'color': const Color(0xFF00D2D3),
    'count': dashboardData?['statistik']['total_berita']?.toString() ?? '',
    'onTap': () => Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AdminKelolaBeritaPage()),
    ),
  },
  {
    'title': 'Kelola Aduan',
    'subtitle': 'Monitor & respon aduan warga',
    'icon': Icons.report_problem_rounded,
    'color': const Color(0xFFFF6B6B),
    'count': dashboardData?['statistik']['aduan_baru']?.toString() ?? '',
    'onTap': () => Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AdminKelolaAduanPage()),
    ),
  },
];

return SliverToBoxAdapter(
  child: Padding(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Menu Utama',
          style: GoogleFonts.poppins(
            fontSize: isSmallScreen ? 16 : 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2D3436),
          ),
        ),
        const SizedBox(height: 16),
        ...menus.map((menu) {
          final count = (menu['count'] as String?) ?? '';

          return FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: menu['onTap'] as VoidCallback,
                  borderRadius: BorderRadius.circular(16),
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
                          width: isSmallScreen ? 50 : 60,
                          height: isSmallScreen ? 50 : 60,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                (menu['color'] as Color),
                                (menu['color'] as Color).withOpacity(0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            menu['icon'] as IconData,
                            color: Colors.white,
                            size: isSmallScreen ? 24 : 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                menu['title'] as String,
                                style: GoogleFonts.poppins(
                                  fontSize: isSmallScreen ? 15 : 16,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF2D3436),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                menu['subtitle'] as String,
                                style: GoogleFonts.poppins(
                                  fontSize: isSmallScreen ? 12 : 13,
                                  color: const Color(0xFF636E72),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // === FIX: SEMBUNYIKAN BADGE JIKA COUNT KOSONG ===
                        if (count.isNotEmpty && count != '0')
  Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: (menu['color'] as Color).withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      count,
      style: GoogleFonts.poppins(
        fontSize: isSmallScreen ? 12 : 13,
        fontWeight: FontWeight.w700,
        color: menu['color'] as Color,
                              ),
                            ),
                          ),

                        const SizedBox(width: 12),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: Colors.grey[400],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ],
    ),
  ),
);
  }

  Widget _buildActivitiesSection(bool isSmallScreen) {
    final activities = dashboardData?['surat_terbaru'] as List? ?? [];

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Aktivitas Terbaru',
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2D3436),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (activities.isNotEmpty)
              GlassContainer(
                blur: 15,
                opacity: 0.08,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: Column(
                    children: List.generate(
                      activities.length > 3 ? 3 : activities.length,
                      (index) {
                        final activity = activities[index];
                        final isLast = index == (activities.length > 3 ? 2 : activities.length - 1);
                        return _buildActivityItem(
                          activity: activity,
                          isLast: isLast,
                          isSmallScreen: isSmallScreen,
                        );
                      },
                    ),
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
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
                        Icons.inbox_rounded,
                        size: 50,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Belum ada aktivitas',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: const Color(0xFF636E72),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Aktivitas terbaru akan muncul di sini',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: const Color(0xFF636E72),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem({required dynamic activity, required bool isLast, required bool isSmallScreen}) {
    final status = activity['status'] ?? 'pending';
    final jenisSurat = activity['jenis_surat'] ?? 'Surat';
    final namaPemohon = activity['nama_pemohon'] ?? 'Warga';
    final tanggal = activity['created_at'] ?? '';

    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (status) {
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

    return Container(
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
                  jenisSurat,
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 14 : 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D3436),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  namaPemohon,
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 12 : 13,
                    color: const Color(0xFF636E72),
                  ),
                ),
                if (tanggal.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    _formatDateTime(tanggal),
                    style: GoogleFonts.poppins(
                      fontSize: isSmallScreen ? 10 : 11,
                      color: const Color(0xFF636E72),
                    ),
                  ),
                ],
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                isActive: true,
                onTap: () {},
                isSmallScreen: isSmallScreen,
              ),
              _buildNavItem(
                icon: Icons.mail_rounded,
                label: 'Surat',
                isActive: false,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminKelolaSuratPage()),
                  );
                },
                isSmallScreen: isSmallScreen,
              ),
              _buildNavItem(
                icon: Icons.newspaper_rounded,
                label: 'Berita',
                isActive: false,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AdminKelolaBeritaPage()),
                  );
                },
                isSmallScreen: isSmallScreen,
              ),
              _buildNavItem(
                icon: Icons.person_rounded,
                label: 'Profile',
                isActive: false,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AdminProfilePage()),
                  );
                },
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
          color: isActive ? const Color(0xFF00D2D3).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? const Color(0xFF00D2D3) : const Color(0xFF636E72),
              size: isSmallScreen ? 20 : 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: isSmallScreen ? 10 : 11,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? const Color(0xFF00D2D3) : const Color(0xFF636E72),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    if (isLoading) return _buildLoadingState(isSmallScreen);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          color: const Color(0xFF00D2D3),
          backgroundColor: Colors.white,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildHeader(isSmallScreen),
              _buildStatsGrid(isSmallScreen),
              _buildQuickActions(isSmallScreen),
              _buildMenuSection(isSmallScreen),
              _buildActivitiesSection(isSmallScreen),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(isSmallScreen),
    );
  }
}