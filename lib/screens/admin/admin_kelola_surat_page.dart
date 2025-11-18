// lib/screens/admin/admin_kelola_surat_page.dart
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

class _AdminKelolaSuratPageState extends State<AdminKelolaSuratPage> {
  List<SuratModel> _allSuratList = [];
  List<SuratModel> _filteredSuratList = [];
  bool _isLoading = true;
  bool _isError = false;
  
  // Search & Filter
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
    _loadAllSurat();
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
      _filteredSuratList = _allSuratList.where((surat) {
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

  Future<void> _loadAllSurat() async {
    setState(() {
      _isLoading = true;
      _isError = false;
    });

    try {
      final surat = await SuratService.getAllSurat();
      setState(() {
        _allSuratList = surat;
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return const Color(0xFFFF9800);
      case 'diproses': return AppColors.primaryBlue;
      case 'selesai': return const Color(0xFF66BB6A);
      case 'ditolak': return const Color(0xFFEF5350);
      default: return const Color(0xFFFF9800);
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending': return Icons.pending;
      case 'diproses': return Icons.autorenew;
      case 'selesai': return Icons.check_circle;
      case 'ditolak': return Icons.cancel;
      default: return Icons.pending;
    }
  }

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
            child: Icon(_getStatusIcon(surat.status), color: Colors.white, size: 22),
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
              if (surat.keperluan.length > 50) ...[
                const SizedBox(height: 2),
                Text(
                  '${surat.keperluan.substring(0, 50)}...',
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 10 : 11,
                    color: Colors.grey.shade500,
                  ),
                ),
              ] else if (surat.keperluan.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  surat.keperluan,
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 10 : 11,
                    color: Colors.grey.shade500,
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
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => AdminDetailSuratPage(
        suratId: surat.id, // atau surat['id']
      ),
    ),
  );
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
      value: filter['value'] as String,  // pastikan String
      child: Text(
        filter['label'] as String,
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
          'Kelola Surat Warga',
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
            onPressed: _loadAllSurat,
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
                // Search & Filter Section
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
                                  onRefresh: _loadAllSurat,
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
            onPressed: _loadAllSurat,
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
                ? 'Tidak ada pengajuan surat dari warga'
                : 'Coba ubah pencarian atau filter',
            style: GoogleFonts.poppins(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}