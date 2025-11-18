// UPDATE: lib/screens/surat/daftar_surat_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/surat_model.dart';
import '../../services/surat_service.dart';
import '../../utils/app_colors.dart';
import '../../widgets/glass_container.dart';
import 'detail_surat_page.dart';

class DaftarSuratPage extends StatefulWidget {
  const DaftarSuratPage({super.key});

  @override
  State<DaftarSuratPage> createState() => _DaftarSuratPageState();
}

class _DaftarSuratPageState extends State<DaftarSuratPage> {
  List<SuratModel> _suratList = [];
  List<SuratModel> _filteredSuratList = [];
  bool _isLoading = true;
  bool _isError = false;
  
  // ✅ ENHANCEMENT: Search & Filter
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'semua';
  final List<Map<String, dynamic>> _filterOptions = [
    {'value': 'semua', 'label': 'Semua Status'},
    {'value': 'pending', 'label': 'Menunggu'},
    {'value': 'diproses', 'label': 'Diproses'},
    {'value': 'selesai', 'label': 'Selesai'},
    {'value': 'ditolak', 'label': 'Ditolak'},
  ];

  @override
  void initState() {
    super.initState();
    _loadSuratSaya();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _applyFilters();
  }

  void _applyFilters() {
    String searchQuery = _searchController.text.toLowerCase();
    
    setState(() {
      _filteredSuratList = _suratList.where((surat) {
        // Filter by status
        bool statusMatch = _selectedFilter == 'semua' || surat.status == _selectedFilter;
        
        // Filter by search query
        bool searchMatch = searchQuery.isEmpty ||
            surat.jenisSurat.toLowerCase().contains(searchQuery) ||
            surat.keperluan.toLowerCase().contains(searchQuery) ||
            surat.statusText.toLowerCase().contains(searchQuery);
        
        return statusMatch && searchMatch;
      }).toList();
    });
  }

  Future<void> _loadSuratSaya() async {
    setState(() {
      _isLoading = true;
      _isError = false;
    });

    try {
      final surat = await SuratService.getSuratSaya();
      setState(() {
        _suratList = surat;
        _filteredSuratList = surat;
      });
    } catch (e) {
      setState(() => _isError = true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal memuat data surat: $e',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _batalkanSurat(int suratId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Konfirmasi Pembatalan',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Apakah Anda yakin ingin membatalkan surat ini?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal', style: GoogleFonts.poppins()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Ya, Batalkan',
              style: GoogleFonts.poppins(color: AppColors.errorColor),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await SuratService.batalkanSurat(suratId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Surat berhasil dibatalkan',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: AppColors.successColor,
            ),
          );
          _loadSuratSaya(); // Reload data
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Gagal membatalkan surat: $e',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: AppColors.errorColor,
            ),
          );
        }
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return const Color(0xFFFF9800);
      case 'diproses': return AppColors.primaryBlue;
      case 'selesai': return const Color(0xFF66BB6A);
      case 'ditolak': return const Color(0xFFEF5350);
      default: return const Color(0xFFFF9800);
    }
  }

// Di _buildSuratCard di daftar_surat_page.dart - TAMBAHKAN INI
Widget _buildSuratCard(SuratModel surat, bool isSmallScreen) {
  return Container(
    margin: EdgeInsets.only(bottom: isSmallScreen ? 12 : 15),
    child: GlassContainer(
      blur: 10,
      opacity: 0.2,
      borderRadius: BorderRadius.circular(16),
      child: ListTile(
        contentPadding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            children: [
              const Icon(Icons.description_outlined, color: Colors.white, size: 22),
              // ✅ BADGE JIKA ADA FILE HASIL
              if (surat.hasFileHasil)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.download,
                      color: Colors.white,
                      size: 8,
                    ),
                  ),
                ),
            ],
          ),
        ),
        title: Text(
          surat.jenisSurat,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: isSmallScreen ? 14 : 15,
            color: AppColors.darkNavy,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Diajukan: ${_formatDate(surat.tanggalPengajuan)}',
              style: GoogleFonts.poppins(
                fontSize: isSmallScreen ? 11 : 12,
                color: Colors.grey.shade600,
              ),
            ),
            // ✅ TAMBAHKAN INDIKATOR FILE HASIL
            if (surat.hasFileHasil) ...[
              const SizedBox(height: 2),
              Text(
                '📎 File hasil tersedia',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            if (surat.isPending) ...[
              const SizedBox(height: 4),
              Text(
                'Klik untuk membatalkan',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: AppColors.errorColor,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: _getStatusColor(surat.status).withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _getStatusColor(surat.status), width: 1),
          ),
          child: Text(
            surat.statusText.toUpperCase(),
            style: GoogleFonts.poppins(
              fontSize: isSmallScreen ? 9 : 10,
              fontWeight: FontWeight.w600,
              color: _getStatusColor(surat.status),
            ),
          ),
        ),
        onTap: () {
          if (surat.isPending) {
            _batalkanSurat(surat.id);
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailSuratPage(surat: surat),
              ),
            );
          }
        },
      ),
    ),
  );
}
  Widget _buildSearchAndFilter(bool isSmallScreen) {
    return GlassContainer(
      blur: 10,
      opacity: 0.2,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        child: Column(
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari surat...',
                hintStyle: GoogleFonts.poppins(),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.9),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              ),
            ),
            const SizedBox(height: 12),
            // Filter Dropdown
DropdownButtonFormField<String>(
  value: _selectedFilter,
  items: _filterOptions.map((filter) {
    return DropdownMenuItem<String>(
      value: filter['value'].toString(),
      child: Text(
        filter['label'].toString(),
        style: GoogleFonts.poppins(),
      ),
    );
  }).toList(),
  onChanged: (value) {
    setState(() {
      _selectedFilter = value!;
      _applyFilters();
    });
  },
  decoration: InputDecoration(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    filled: true,
    fillColor: Colors.white.withOpacity(0.9),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
    hintText: 'Filter Status',
  ),
),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Surat Saya',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: AppColors.darkNavy,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkNavy),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.darkNavy),
            onPressed: _loadSuratSaya,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
            child: Column(
              children: [
                // ✅ ENHANCEMENT: Search & Filter Section
                _buildSearchAndFilter(isSmallScreen),
                const SizedBox(height: 16),
                
                // Results Count
                if (!_isLoading && !_isError)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Ditemukan ${_filteredSuratList.length} surat',
                      style: GoogleFonts.poppins(
                        fontSize: isSmallScreen ? 12 : 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                
                // Main Content
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: AppColors.primaryBlue),
                        )
                      : _isError
                          ? _buildErrorState()
                          : _filteredSuratList.isEmpty
                              ? _buildEmptyState(isSmallScreen)
                              : RefreshIndicator(
                                  onRefresh: _loadSuratSaya,
                                  color: AppColors.primaryBlue,
                                  child: ListView.builder(
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: _filteredSuratList.length,
                                    itemBuilder: (context, index) {
                                      return _buildSuratCard(_filteredSuratList[index], isSmallScreen);
                                    },
                                  ),
                                ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.errorColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Gagal memuat data',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.darkNavy,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Silakan coba lagi',
            style: GoogleFonts.poppins(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadSuratSaya,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              'Coba Lagi',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
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
          Icon(
            Icons.description_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            _searchController.text.isEmpty && _selectedFilter == 'semua'
                ? 'Belum ada surat'
                : 'Tidak ada surat yang sesuai',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.darkNavy,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchController.text.isEmpty && _selectedFilter == 'semua'
                ? 'Ajukan surat pertama Anda'
                : 'Coba ubah pencarian atau filter',
            style: GoogleFonts.poppins(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Kembali ke dashboard
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              'Ajukan Surat',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}