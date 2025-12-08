// lib/screens/admin/admin_kelola_surat_page.dart - MODERN CLEAN DESIGN
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/surat_model.dart';
import '../../services/surat_service.dart';
import '../../utils/app_colors.dart';
import '../../widgets/glass_container.dart';
import 'admin_detail_surat_page.dart';

class AdminKelolaSuratPage extends StatefulWidget {
  const AdminKelolaSuratPage({super.key});

  @override
  State<AdminKelolaSuratPage> createState() => _AdminKelolaSuratPageState();
}

class _AdminKelolaSuratPageState extends State<AdminKelolaSuratPage> with SingleTickerProviderStateMixin {
  List<SuratModel> _allSuratList = [];
  List<SuratModel> _filteredSuratList = [];
  bool _isLoading = true;
  bool _isError = false;
  
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'semua';
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> _filterOptions = [
    {'value': 'semua', 'label': 'Semua Status', 'color': Color(0xFF636E72)},
    {'value': 'pending', 'label': 'Menunggu', 'color': Color(0xFFFFA502)},
    {'value': 'diproses', 'label': 'Diproses', 'color': Color(0xFF6C5CE7)},
    {'value': 'selesai', 'label': 'Selesai', 'color': Color(0xFF00D2D3)},
    {'value': 'ditolak', 'label': 'Ditolak', 'color': Color(0xFFFF6B6B)},
  ];

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    
    _loadAllSurat();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _applyFilters();
  }

  void _applyFilters() {
    String searchQuery = _searchController.text.toLowerCase();
    
    setState(() {
      _filteredSuratList = _allSuratList.where((surat) {
        bool statusMatch = _selectedFilter == 'semua' || surat.status == _selectedFilter;
        bool searchMatch = searchQuery.isEmpty ||
            surat.jenisSurat.toLowerCase().contains(searchQuery) ||
            surat.keperluan.toLowerCase().contains(searchQuery) ||
            surat.statusText.toLowerCase().contains(searchQuery);
        
        return statusMatch && searchMatch;
      }).toList();
    });
  }

  Future<void> _loadAllSurat() async {
    setState(() {
      _isLoading = true;
      _isError = false;
    });

    try {
      final surat = await SuratService.getAllSurat();
      if (mounted) {
        setState(() {
          _allSuratList = surat;
          _filteredSuratList = surat;
        });
        _animationController.forward(from: 0.0);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isError = true);
        _showSnackBar('Gagal memuat data surat: $e', false);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, bool success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              success ? Icons.check_circle_rounded : Icons.error_rounded,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: success ? const Color(0xFF00D2D3) : const Color(0xFFFF6B6B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return const Color(0xFFFFA502);
      case 'diproses': return const Color(0xFF6C5CE7);
      case 'selesai': return const Color(0xFF00D2D3);
      case 'ditolak': return const Color(0xFFFF6B6B);
      default: return const Color(0xFFFFA502);
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending': return Icons.schedule_rounded;
      case 'diproses': return Icons.autorenew_rounded;
      case 'selesai': return Icons.check_circle_rounded;
      case 'ditolak': return Icons.cancel_rounded;
      default: return Icons.schedule_rounded;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600;
    final maxWidth = isTablet ? 800.0 : double.infinity;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: const Color(0xFF2D3436),
            size: isSmallScreen ? 20 : 22,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Kelola Surat Warga',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2D3436),
            fontSize: isSmallScreen ? 16 : 18,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh_rounded,
              color: const Color(0xFF6C5CE7),
              size: isSmallScreen ? 22 : 24,
            ),
            onPressed: _loadAllSurat,
            tooltip: 'Refresh',
          ),
          SizedBox(width: isSmallScreen ? 4 : 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Column(
            children: [
              // Header Stats Card
              _buildHeaderStats(isSmallScreen),
              
              // Search & Filter Section
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 16 : 20,
                  vertical: isSmallScreen ? 12 : 16,
                ),
                child: _buildSearchAndFilter(isSmallScreen),
              ),
              
              // Main Content
              Expanded(
                child: _isLoading
                    ? _buildLoadingState(isSmallScreen)
                    : _isError
                        ? _buildErrorState(isSmallScreen)
                        : _filteredSuratList.isEmpty
                            ? _buildEmptyState(isSmallScreen)
                            : _buildSuratList(isSmallScreen),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderStats(bool isSmallScreen) {
    final pendingCount = _allSuratList.where((s) => s.status == 'pending').length;
    final diprosesCount = _allSuratList.where((s) => s.status == 'diproses').length;
    final selesaiCount = _allSuratList.where((s) => s.status == 'selesai').length;

    return Container(
      margin: EdgeInsets.all(isSmallScreen ? 16 : 20),
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [ Color(0xFF00D2D3), Color(0xFFA29BFE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00D2D3).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.dashboard_rounded,
                color: Colors.white,
                size: isSmallScreen ? 22 : 24,
              ),
              SizedBox(width: isSmallScreen ? 8 : 12),
              Text(
                'Statistik Surat',
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 15 : 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 14 : 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  label: 'Menunggu',
                  count: pendingCount,
                  icon: Icons.schedule_rounded,
                  isSmallScreen: isSmallScreen,
                ),
              ),
              SizedBox(width: isSmallScreen ? 10 : 12),
              Expanded(
                child: _buildStatItem(
                  label: 'Diproses',
                  count: diprosesCount,
                  icon: Icons.autorenew_rounded,
                  isSmallScreen: isSmallScreen,
                ),
              ),
              SizedBox(width: isSmallScreen ? 10 : 12),
              Expanded(
                child: _buildStatItem(
                  label: 'Selesai',
                  count: selesaiCount,
                  icon: Icons.check_circle_rounded,
                  isSmallScreen: isSmallScreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required int count,
    required IconData icon,
    required bool isSmallScreen,
  }) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: isSmallScreen ? 20 : 24,
          ),
          SizedBox(height: isSmallScreen ? 6 : 8),
          Text(
            '$count',
            style: GoogleFonts.poppins(
              fontSize: isSmallScreen ? 18 : 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: isSmallScreen ? 2 : 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: isSmallScreen ? 10 : 11,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter(bool isSmallScreen) {
    return Column(
      children: [
        // Search Bar
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            style: GoogleFonts.poppins(
              fontSize: isSmallScreen ? 13 : 14,
              color: const Color(0xFF2D3436),
            ),
            decoration: InputDecoration(
              hintText: 'Cari berdasarkan jenis surat atau keperluan...',
              hintStyle: GoogleFonts.poppins(
                fontSize: isSmallScreen ? 13 : 14,
                color: const Color(0xFF636E72),
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: const Color(0xFF6C5CE7),
                size: isSmallScreen ? 20 : 22,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear_rounded,
                        color: const Color(0xFF636E72),
                        size: isSmallScreen ? 20 : 22,
                      ),
                      onPressed: () {
                        _searchController.clear();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 14),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 12 : 16,
                vertical: isSmallScreen ? 14 : 16,
              ),
            ),
          ),
        ),
        SizedBox(height: isSmallScreen ? 10 : 12),
        
        // Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: _filterOptions.map((filter) {
              final isSelected = _selectedFilter == filter['value'];
              final color = filter['color'] as Color;
              
              return Padding(
                padding: EdgeInsets.only(right: isSmallScreen ? 8 : 10),
                child: FilterChip(
                  selected: isSelected,
                  label: Text(
                    filter['label'] as String,
                    style: GoogleFonts.poppins(
                      fontSize: isSmallScreen ? 11 : 12,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? Colors.white : color,
                    ),
                  ),
                  backgroundColor: Colors.white,
                  selectedColor: color,
                  checkmarkColor: Colors.white,
                  side: BorderSide(
                    color: isSelected ? color : color.withOpacity(0.3),
                    width: isSelected ? 2 : 1,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 10 : 12,
                    vertical: isSmallScreen ? 6 : 8,
                  ),
                  onSelected: (selected) {
                    setState(() {
                      _selectedFilter = filter['value'] as String;
                      _applyFilters();
                    });
                  },
                ),
              );
            }).toList(),
          ),
        ),
        
        // Results Count
        if (!_isLoading && !_isError) ...[
          SizedBox(height: isSmallScreen ? 10 : 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Menampilkan ${_filteredSuratList.length} dari ${_allSuratList.length} surat',
              style: GoogleFonts.poppins(
                fontSize: isSmallScreen ? 11 : 12,
                color: const Color(0xFF636E72),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSuratList(bool isSmallScreen) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: RefreshIndicator(
        onRefresh: _loadAllSurat,
        color: const Color(0xFF6C5CE7),
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 16 : 20,
            vertical: isSmallScreen ? 8 : 12,
          ),
          itemCount: _filteredSuratList.length,
          itemBuilder: (context, index) {
            return _buildSuratCard(_filteredSuratList[index], isSmallScreen);
          },
        ),
      ),
    );
  }

  Widget _buildSuratCard(SuratModel surat, bool isSmallScreen) {
    final statusColor = _getStatusColor(surat.status);
    final statusIcon = _getStatusIcon(surat.status);

    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 16),
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AdminDetailSuratPage(suratId: surat.id),
              ),
            );
            
            if (result == true) {
              _loadAllSurat();
            }
          },
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 14 : 16),
            child: Row(
              children: [
                // Icon Container
                Container(
                  width: isSmallScreen ? 50 : 56,
                  height: isSmallScreen ? 50 : 56,
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 14),
                  ),
                  child: Icon(
                    statusIcon,
                    color: statusColor,
                    size: isSmallScreen ? 24 : 28,
                  ),
                ),
                SizedBox(width: isSmallScreen ? 12 : 16),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        surat.jenisSurat,
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 14 : 15,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2D3436),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: isSmallScreen ? 4 : 6),
                      Text(
                        surat.keperluan,
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 11 : 12,
                          color: const Color(0xFF636E72),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: isSmallScreen ? 6 : 8),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: isSmallScreen ? 12 : 14,
                            color: const Color(0xFF636E72),
                          ),
                          SizedBox(width: isSmallScreen ? 4 : 6),
                          Text(
                            _formatDate(surat.tanggalPengajuan),
                            style: GoogleFonts.poppins(
                              fontSize: isSmallScreen ? 10 : 11,
                              color: const Color(0xFF636E72),
                            ),
                          ),
                          SizedBox(width: isSmallScreen ? 12 : 16),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 8 : 10,
                              vertical: isSmallScreen ? 3 : 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(isSmallScreen ? 6 : 8),
                            ),
                            child: Text(
                              surat.statusText.toUpperCase(),
                              style: GoogleFonts.poppins(
                                fontSize: isSmallScreen ? 9 : 10,
                                fontWeight: FontWeight.w600,
                                color: statusColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Arrow Icon
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: isSmallScreen ? 16 : 18,
                  color: const Color(0xFF636E72),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(bool isSmallScreen) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: Color(0xFF6C5CE7),
            strokeWidth: 3,
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),
          Text(
            'Memuat data surat...',
            style: GoogleFonts.poppins(
              fontSize: isSmallScreen ? 13 : 14,
              color: const Color(0xFF636E72),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(bool isSmallScreen) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 24 : 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: isSmallScreen ? 70 : 80,
              height: isSmallScreen ? 70 : 80,
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B6B).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: isSmallScreen ? 35 : 40,
                color: const Color(0xFFFF6B6B),
              ),
            ),
            SizedBox(height: isSmallScreen ? 16 : 20),
            Text(
              'Gagal Memuat Data',
              style: GoogleFonts.poppins(
                fontSize: isSmallScreen ? 16 : 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2D3436),
              ),
            ),
            SizedBox(height: isSmallScreen ? 6 : 8),
            Text(
              'Terjadi kesalahan saat memuat data surat',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: isSmallScreen ? 12 : 13,
                color: const Color(0xFF636E72),
              ),
            ),
            SizedBox(height: isSmallScreen ? 24 : 30),
            Container(
              height: isSmallScreen ? 44 : 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                ),
                borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6C5CE7).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _loadAllSurat,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 24 : 32,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.refresh_rounded,
                      color: Colors.white,
                      size: isSmallScreen ? 18 : 20,
                    ),
                    SizedBox(width: isSmallScreen ? 6 : 8),
                    Text(
                      'Coba Lagi',
                      style: GoogleFonts.poppins(
                        fontSize: isSmallScreen ? 13 : 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
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

  Widget _buildEmptyState(bool isSmallScreen) {
    final isFiltering = _searchController.text.isNotEmpty || _selectedFilter != 'semua';
    
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 24 : 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: isSmallScreen ? 70 : 80,
              height: isSmallScreen ? 70 : 80,
              decoration: BoxDecoration(
                color: const Color(0xFF636E72).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isFiltering ? Icons.search_off_rounded : Icons.description_outlined,
                size: isSmallScreen ? 35 : 40,
                color: const Color(0xFF636E72),
              ),
            ),
            SizedBox(height: isSmallScreen ? 16 : 20),
            Text(
              isFiltering ? 'Tidak Ada Hasil' : 'Belum Ada Surat',
              style: GoogleFonts.poppins(
                fontSize: isSmallScreen ? 16 : 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2D3436),
              ),
            ),
            SizedBox(height: isSmallScreen ? 6 : 8),
            Text(
              isFiltering
                  ? 'Tidak ada surat yang sesuai dengan pencarian atau filter Anda'
                  : 'Belum ada pengajuan surat dari warga',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: isSmallScreen ? 12 : 13,
                color: const Color(0xFF636E72),
              ),
            ),
            if (isFiltering) ...[
              SizedBox(height: isSmallScreen ? 24 : 30),
              TextButton.icon(
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _selectedFilter = 'semua';
                    _applyFilters();
                  });
                },
                icon: Icon(
                  Icons.clear_all_rounded,
                  size: isSmallScreen ? 18 : 20,
                ),
                label: Text(
                  'Reset Filter',
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 13 : 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF6C5CE7),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}