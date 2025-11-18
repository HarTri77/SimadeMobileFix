// lib/screens/dashboard/admin_dashboard.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
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

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> with SingleTickerProviderStateMixin {
  Map<String, dynamic>? dashboardData;
  UserModel? currentUser;
  bool isLoading = true;
  late AnimationController _animationController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
    _loadUserData();
    _loadDashboard();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final user = await AuthService.getCurrentUser();
    if (mounted) {
      setState(() => currentUser = user);
    }
  }

  Future<void> _loadDashboard() async {
    setState(() => isLoading = true);
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
          setState(() {
            dashboardData = data['data'];
            isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF6C5CE7),
                ),
              )
            : RefreshIndicator(
                onRefresh: _loadDashboard,
                color: const Color(0xFF6C5CE7),
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    _buildHeader(),
                    _buildProfileSection(),
                    _buildStatsGrid(),
                    _buildMenuSection(),
                    _buildActivitiesSection(),
                    const SliverToBoxAdapter(child: SizedBox(height: 30)),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                isActive: true,
                onTap: () {},
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
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? const Color(0xFF6C5CE7) : const Color(0xFF636E72),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dashboard',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2D3436),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Selamat datang kembali!',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: const Color(0xFF636E72),
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
                onPressed: _logout,
                icon: const Icon(Icons.logout_rounded),
                color: const Color(0xFFFF6B6B),
                iconSize: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6C5CE7),
              Color(0xFFA29BFE),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C5CE7).withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  (currentUser?.nama ?? 'A')[0].toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF6C5CE7),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentUser?.nama ?? 'Admin',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    currentUser?.email ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Admin',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    final stats = [
      {
        'title': 'Total Surat',
        'value': dashboardData?['statistik']['total_surat']?.toString() ?? '0',
        'icon': Icons.description_rounded,
        'color': const Color(0xFF6C5CE7),
        'bgColor': const Color(0xFFF0EBFF),
      },
      {
        'title': 'Pending',
        'value': dashboardData?['statistik']['surat_pending']?.toString() ?? '0',
        'icon': Icons.hourglass_empty_rounded,
        'color': const Color(0xFFFFA502),
        'bgColor': const Color(0xFFFFF3E0),
      },
      {
        'title': 'Total Warga',
        'value': dashboardData?['statistik']['total_warga']?.toString() ?? '0',
        'icon': Icons.people_rounded,
        'color': const Color(0xFF00D2D3),
        'bgColor': const Color(0xFFE0F7FA),
      },
      {
        'title': 'Aduan Baru',
        'value': dashboardData?['statistik']['aduan_baru']?.toString() ?? '0',
        'icon': Icons.notifications_active_rounded,
        'color': const Color(0xFFFF6B6B),
        'bgColor': const Color(0xFFFFEBEE),
      },
    ];

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final stat = stats[index];
            return FadeTransition(
              opacity: _animationController,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: stat['bgColor'] as Color,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            stat['icon'] as IconData,
                            color: stat['color'] as Color,
                            size: 20,
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
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2D3436),
                          ),
                        ),
                        Text(
                          stat['title'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: const Color(0xFF636E72),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
          childCount: stats.length,
        ),
      ),
    );
  }

  Widget _buildMenuSection() {
    final menus = [
      {
        'title': 'Kelola Surat',
        'subtitle': 'Manajemen surat masuk & keluar',
        'icon': Icons.mail_rounded,
        'color': const Color(0xFF6C5CE7),
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminKelolaSuratPage())),
      },
      {
        'title': 'Kelola Berita',
        'subtitle': 'Publikasi berita & pengumuman',
        'icon': Icons.newspaper_rounded,
        'color': const Color(0xFF00D2D3),
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (context) => AdminKelolaBeritaPage())),
      },
      {
        'title': 'Kelola Aduan',
        'subtitle': 'Monitor & respon aduan warga',
        'icon': Icons.report_problem_rounded,
        'color': const Color(0xFFFF6B6B),
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (context) => AdminKelolaAduanPage())),
      },
    ];

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Menu Utama',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2D3436),
              ),
            ),
            const SizedBox(height: 12),
            ...menus.map((menu) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: menu['onTap'] as Function(),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
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
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: (menu['color'] as Color).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              menu['icon'] as IconData,
                              color: menu['color'] as Color,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  menu['title'] as String,
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF2D3436),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  menu['subtitle'] as String,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: const Color(0xFF636E72),
                                  ),
                                ),
                              ],
                            ),
                          ),
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
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitiesSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Aktivitas Terbaru',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2D3436),
              ),
            ),
            const SizedBox(height: 12),
            if (dashboardData?['surat_terbaru'] != null && (dashboardData!['surat_terbaru'] as List).isNotEmpty)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: List.generate(
                    (dashboardData!['surat_terbaru'] as List).length > 5 ? 5 : (dashboardData!['surat_terbaru'] as List).length,
                    (index) {
                      final surat = dashboardData!['surat_terbaru'][index];
                      final isLast = index == ((dashboardData!['surat_terbaru'] as List).length > 5 ? 4 : (dashboardData!['surat_terbaru'] as List).length - 1);
                      return _buildActivityItem(
                        title: surat['jenis_surat'] ?? 'Surat',
                        subtitle: surat['nama_pemohon'] ?? 'Warga',
                        status: surat['status'] ?? 'pending',
                        isLast: isLast,
                      );
                    },
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
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
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem({
    required String title,
    required String subtitle,
    required String status,
    required bool isLast,
  }) {
    Color statusColor;
    String statusText;

    switch (status) {
      case 'pending':
        statusColor = const Color(0xFFFFA502);
        statusText = 'Pending';
        break;
      case 'diproses':
        statusColor = const Color(0xFF6C5CE7);
        statusText = 'Diproses';
        break;
      case 'selesai':
        statusColor = const Color(0xFF00D2D3);
        statusText = 'Selesai';
        break;
      default:
        statusColor = const Color(0xFFFF6B6B);
        statusText = 'Ditolak';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isLast ? Colors.transparent : Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D3436),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFF636E72),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              statusText,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}