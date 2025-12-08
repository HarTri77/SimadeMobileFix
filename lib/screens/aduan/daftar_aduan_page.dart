// lib/screens/aduan/daftar_aduan_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/aduan_service.dart';
import '../../utils/app_colors.dart';
import '../../widgets/glass_container.dart';
import 'detail_aduan_page.dart';
import '../../models/aduan_model.dart';

class DaftarAduanPage extends StatefulWidget {
  const DaftarAduanPage({super.key});

  @override
  State<DaftarAduanPage> createState() => _DaftarAduanPageState();
}

class _DaftarAduanPageState extends State<DaftarAduanPage> {
  List<AduanModel> _aduanList = [];
  List<AduanModel> _filteredAduanList = [];
  bool _isLoading = true;
  bool _isError = false;
  
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'semua';

  @override
  void initState() {
    super.initState();
    _loadAduan();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _applyFilter();
  }

  void _applyFilter() {
    String searchQuery = _searchController.text.toLowerCase();
    
    setState(() {
      if (searchQuery.isEmpty && _selectedStatus == 'semua') {
        _filteredAduanList = _aduanList;
      } else {
        _filteredAduanList = _aduanList.where((aduan) {
          final matchesSearch = searchQuery.isEmpty || 
              aduan.judul.toLowerCase().contains(searchQuery) ||
              aduan.isiAduan.toLowerCase().contains(searchQuery);
          
          final matchesStatus = _selectedStatus == 'semua' || 
              aduan.status == _selectedStatus;
          
          return matchesSearch && matchesStatus;
        }).toList();
      }
    });
  }

  Future<void> _loadAduan() async {
    setState(() {
      _isLoading = true;
      _isError = false;
    });

    try {
      final aduan = await AduanService.getAduan();
      setState(() {
        _aduanList = aduan;
        _filteredAduanList = aduan;
      });
    } catch (e) {
      setState(() => _isError = true);
      if (mounted) {
        _showErrorSnackbar('Gagal memuat aduan: $e');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteAduan(int aduanId, String judul) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Hapus Aduan',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2D3436),
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus aduan "$judul"? Tindakan ini tidak dapat dibatalkan.',
          style: GoogleFonts.poppins(
            color: const Color(0xFF636E72),
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Batal',
              style: GoogleFonts.poppins(
                color: const Color(0xFF636E72),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B6B).withOpacity(0.1),
            ),
            child: Text(
              'Hapus',
              style: GoogleFonts.poppins(
                color: const Color(0xFFFF6B6B),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await AduanService.deleteAduan(aduanId);
      
      if (mounted) {
        _showSuccessSnackbar('Aduan berhasil dihapus');
        
        setState(() {
          _aduanList.removeWhere((aduan) => aduan.id == aduanId);
          _applyFilter();
        });
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('Gagal menghapus aduan: $e');
      }
    }
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF00D2D3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFFF6B6B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildAduanCard(AduanModel aduan, bool isSmallScreen) {
    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 12 : 16),
      child: GlassContainer(
        blur: 15,
        opacity: 0.08,
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailAduanPage(aduanId: aduan.id),
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header dengan Status dan Prioritas
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Status dan Prioritas
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          // Status Badge
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 10 : 12,
                              vertical: isSmallScreen ? 5 : 6,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  aduan.statusColor,
                                  aduan.statusColor.withOpacity(0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              aduan.statusText.toUpperCase(),
                              style: GoogleFonts.poppins(
                                fontSize: isSmallScreen ? 9 : 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          
                          // Prioritas Badge
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 10 : 12,
                              vertical: isSmallScreen ? 5 : 6,
                            ),
                            decoration: BoxDecoration(
                              color: aduan.prioritasColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: aduan.prioritasColor,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.flag_rounded,
                                  size: isSmallScreen ? 10 : 12,
                                  color: aduan.prioritasColor,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  aduan.prioritasText,
                                  style: GoogleFonts.poppins(
                                    fontSize: isSmallScreen ? 9 : 10,
                                    fontWeight: FontWeight.w700,
                                    color: aduan.prioritasColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Tombol Hapus
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _deleteAduan(aduan.id, aduan.judul),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6B6B).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.delete_outline_rounded,
                              size: isSmallScreen ? 16 : 18,
                              color: const Color(0xFFFF6B6B),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: isSmallScreen ? 12 : 16),

                  // Judul
                  Text(
                    aduan.judul,
                    style: GoogleFonts.poppins(
                      fontSize: isSmallScreen ? 15 : 17,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2D3436),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: isSmallScreen ? 8 : 12),

                  // Preview isi aduan
                  Text(
                    aduan.isiAduan.length > 120 
                        ? '${aduan.isiAduan.substring(0, 120)}...' 
                        : aduan.isiAduan,
                    style: GoogleFonts.poppins(
                      fontSize: isSmallScreen ? 12 : 13,
                      color: const Color(0xFF636E72),
                      height: 1.5,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: isSmallScreen ? 12 : 16),

                  // Footer dengan informasi tambahan
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Informasi Kategori dan Lokasi
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Tanggal
                            Text(
                              aduan.formattedCreatedAt,
                              style: GoogleFonts.poppins(
                                fontSize: isSmallScreen ? 10 : 11,
                                color: const Color(0xFF636E72),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 6),
                            
                            // Kategori dan Lokasi
                            Wrap(
                              spacing: 12,
                              runSpacing: 6,
                              children: [
                                if (aduan.namaKategori != null)
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.category_rounded,
                                        size: isSmallScreen ? 12 : 14,
                                        color: const Color(0xFF00D2D3),
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        aduan.namaKategori!,
                                        style: GoogleFonts.poppins(
                                          fontSize: isSmallScreen ? 10 : 11,
                                          color: const Color(0xFF636E72),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),

                                if (aduan.lokasi != null)
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.location_on_rounded,
                                        size: isSmallScreen ? 12 : 14,
                                        color: const Color(0xFF00D2D3),
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Lokasi',
                                        style: GoogleFonts.poppins(
                                          fontSize: isSmallScreen ? 10 : 11,
                                          color: const Color(0xFF636E72),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Arrow indicator
                      Container(
                        padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00D2D3).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: isSmallScreen ? 14 : 16,
                          color: const Color(0xFF00D2D3),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isSmallScreen) {
    return GlassContainer(
      blur: 15,
      opacity: 0.08,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.all(isSmallScreen ? 4 : 6),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Cari aduan...',
            hintStyle: GoogleFonts.poppins(
              color: const Color(0xFF636E72),
              fontSize: isSmallScreen ? 14 : 15,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: const Color(0xFF00D2D3),
              size: isSmallScreen ? 20 : 22,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 12 : 16,
              vertical: isSmallScreen ? 14 : 16,
            ),
          ),
          style: GoogleFonts.poppins(
            fontSize: isSmallScreen ? 14 : 15,
            color: const Color(0xFF2D3436),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(bool isSmallScreen) {
    final statusList = [
      {'value': 'semua', 'label': 'Semua', 'color': const Color(0xFF00D2D3)},
      {'value': 'baru', 'label': 'Baru', 'color': const Color(0xFFFFA502)},
      {'value': 'diproses', 'label': 'Diproses', 'color': const Color(0xFF6C5CE7)},
      {'value': 'selesai', 'label': 'Selesai', 'color': const Color(0xFF00D2D3)},
      {'value': 'ditolak', 'label': 'Ditolak', 'color': const Color(0xFFFF6B6B)},
    ];

    return SizedBox(
      height: isSmallScreen ? 40 : 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: statusList.length,
        itemBuilder: (context, index) {
          final status = statusList[index];
          final isSelected = _selectedStatus == status['value'];
          return Container(
            margin: EdgeInsets.only(right: 8, top: 4, bottom: 4),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: () {
                  setState(() {
                    _selectedStatus = status['value'] as String;
                    _applyFilter();
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 16 : 18,
                    vertical: isSmallScreen ? 8 : 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [
                              status['color'] as Color,
                              (status['color'] as Color).withOpacity(0.8),
                            ],
                          )
                        : null,
                    color: isSelected ? null : Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: isSelected 
                          ? Colors.transparent 
                          : (status['color'] as Color).withOpacity(0.3),
                      width: 1.5,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: (status['color'] as Color).withOpacity(0.3),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    status['label'] as String,
                    style: GoogleFonts.poppins(
                      fontSize: isSmallScreen ? 11 : 12,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : status['color'] as Color,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 16 : 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Aduan Saya',
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 22 : 26,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2D3436),
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Kelola dan pantau aduan Anda',
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 12 : 13,
                  color: const Color(0xFF636E72),
                ),
              ),
            ],
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _loadAduan,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00D2D3), Color(0xFF26A69A)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00D2D3).withOpacity(0.3),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.refresh_rounded,
                  color: Colors.white,
                  size: isSmallScreen ? 20 : 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
          child: Column(
            children: [
              // Header
              _buildHeader(isSmallScreen),
              SizedBox(height: isSmallScreen ? 16 : 20),
              
              // Search Bar
              _buildSearchBar(isSmallScreen),
              SizedBox(height: isSmallScreen ? 16 : 20),
              
              // Filter Chips
              _buildFilterChips(isSmallScreen),
              SizedBox(height: isSmallScreen ? 16 : 20),
              
              // Results Count
              if (!_isLoading && !_isError)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Ditemukan ${_filteredAduanList.length} aduan',
                    style: GoogleFonts.poppins(
                      fontSize: isSmallScreen ? 12 : 13,
                      color: const Color(0xFF636E72),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              SizedBox(height: isSmallScreen ? 12 : 16),
              
              // Main Content
              Expanded(
                child: _isLoading
                    ? _buildLoadingState(isSmallScreen)
                    : _isError
                        ? _buildErrorState(isSmallScreen)
                        : _filteredAduanList.isEmpty
                            ? _buildEmptyState(isSmallScreen)
                            : RefreshIndicator(
                                onRefresh: _loadAduan,
                                color: const Color(0xFF00D2D3),
                                backgroundColor: Colors.white,
                                child: ListView.builder(
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: _filteredAduanList.length,
                                  itemBuilder: (context, index) {
                                    return _buildAduanCard(_filteredAduanList[index], isSmallScreen);
                                  },
                                ),
                              ),
              ),
            ],
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
          SizedBox(
            width: isSmallScreen ? 40 : 50,
            height: isSmallScreen ? 40 : 50,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: const Color(0xFF00D2D3),
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Memuat aduan...',
            style: GoogleFonts.poppins(
              fontSize: isSmallScreen ? 14 : 16,
              color: const Color(0xFF636E72),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(bool isSmallScreen) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: isSmallScreen ? 80 : 100,
            height: isSmallScreen ? 80 : 100,
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B6B).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline_rounded,
              size: isSmallScreen ? 40 : 50,
              color: const Color(0xFFFF6B6B),
            ),
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),
          Text(
            'Gagal memuat aduan',
            style: GoogleFonts.poppins(
              fontSize: isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2D3436),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Silakan coba lagi',
            style: GoogleFonts.poppins(
              color: const Color(0xFF636E72),
              fontSize: isSmallScreen ? 13 : 14,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isSmallScreen ? 20 : 24),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _loadAduan,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 24 : 32,
                  vertical: isSmallScreen ? 12 : 14,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00D2D3), Color(0xFF26A69A)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00D2D3).withOpacity(0.3),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  'Coba Lagi',
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 14 : 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isSmallScreen) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: isSmallScreen ? 100 : 120,
            height: isSmallScreen ? 100 : 120,
            decoration: BoxDecoration(
              color: const Color(0xFF00D2D3).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.report_problem_outlined,
              size: isSmallScreen ? 40 : 50,
              color: const Color(0xFF00D2D3),
            ),
          ),
          SizedBox(height: isSmallScreen ? 20 : 24),
          Text(
            _searchController.text.isEmpty && _selectedStatus == 'semua'
                ? 'Belum ada aduan'
                : 'Tidak ada aduan yang sesuai',
            style: GoogleFonts.poppins(
              fontSize: isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2D3436),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            _searchController.text.isEmpty && _selectedStatus == 'semua'
                ? 'Mulai dengan mengajukan aduan pertama Anda'
                : 'Coba ubah pencarian atau filter yang digunakan',
            style: GoogleFonts.poppins(
              color: const Color(0xFF636E72),
              fontSize: isSmallScreen ? 13 : 14,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}