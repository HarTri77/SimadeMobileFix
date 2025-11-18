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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat aduan: $e'),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteAduan(int aduanId, String judul) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Hapus Aduan',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: AppColors.darkNavy,
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus aduan "$judul"? Tindakan ini tidak dapat dibatalkan.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Batal',
              style: GoogleFonts.poppins(color: Colors.grey.shade600),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Hapus',
              style: GoogleFonts.poppins(color: AppColors.errorColor),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await AduanService.deleteAduan(aduanId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Aduan berhasil dihapus'),
            backgroundColor: AppColors.successColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
        
        // Hapus dari local state tanpa reload API
        setState(() {
          _aduanList.removeWhere((aduan) => aduan.id == aduanId);
          _applyFilter();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus aduan: $e'),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
    }
  }

  bool _canDeleteAduan(AduanModel aduan) {
    return aduan.status == 'baru' || aduan.status == 'ditolak';
  }

  Widget _buildAduanCard(AduanModel aduan, bool isSmallScreen) {
    bool canDelete = _canDeleteAduan(aduan);
    
    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 12 : 16),
      child: GlassContainer(
        blur: 10,
        opacity: 0.1,
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailAduanPage(aduanId: aduan.id),
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // PERBAIKAN: Header dengan layout yang lebih baik
                  Row(
                    children: [
                      // Status dan Prioritas dalam satu row
                      Expanded(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            // Status
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isSmallScreen ? 8 : 10,
                                vertical: isSmallScreen ? 4 : 6,
                              ),
                              decoration: BoxDecoration(
                                color: aduan.statusColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: aduan.statusColor, width: 1),
                              ),
                              child: Text(
                                aduan.statusText.toUpperCase(),
                                style: GoogleFonts.poppins(
                                  fontSize: isSmallScreen ? 9 : 10,
                                  fontWeight: FontWeight.w600,
                                  color: aduan.statusColor,
                                ),
                              ),
                            ),
                            
                            // Prioritas
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isSmallScreen ? 8 : 10,
                                vertical: isSmallScreen ? 4 : 6,
                              ),
                              decoration: BoxDecoration(
                                color: aduan.prioritasColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: aduan.prioritasColor, width: 1),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.flag,
                                    size: isSmallScreen ? 10 : 12,
                                    color: aduan.prioritasColor,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    aduan.prioritasText,
                                    style: GoogleFonts.poppins(
                                      fontSize: isSmallScreen ? 9 : 10,
                                      fontWeight: FontWeight.w600,
                                      color: aduan.prioritasColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // PERBAIKAN: Tanggal dan tombol hapus dipisah row baru
                    ],
                  ),
                  
                  // PERBAIKAN: Row kedua untuk tanggal dan tombol hapus
                  SizedBox(height: 8),
                  Row(
                    children: [
                      // Tanggal
                      Text(
                        aduan.formattedCreatedAt,
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 10 : 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Spacer(),
                      
                      // TOMBOL HAPUS - PASTI MUNCUL KALAU BISA DIHAPUS
                      if (canDelete)
                        Container(
                          height: isSmallScreen ? 28 : 32,
                          child: ElevatedButton(
                            onPressed: () => _deleteAduan(aduan.id, aduan.judul),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.errorColor.withOpacity(0.1),
                              foregroundColor: AppColors.errorColor,
                              elevation: 0,
                              padding: EdgeInsets.symmetric(
                                horizontal: isSmallScreen ? 8 : 12,
                                vertical: 4,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                  color: AppColors.errorColor.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.delete_outline,
                                  size: isSmallScreen ? 14 : 16,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Hapus',
                                  style: GoogleFonts.poppins(
                                    fontSize: isSmallScreen ? 10 : 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: isSmallScreen ? 8 : 12),

                  // Judul
                  Text(
                    aduan.judul,
                    style: GoogleFonts.poppins(
                      fontSize: isSmallScreen ? 14 : 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkNavy,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: isSmallScreen ? 8 : 12),

                  // Preview isi aduan
                  Text(
                    aduan.isiAduan.length > 100 
                        ? '${aduan.isiAduan.substring(0, 100)}...' 
                        : aduan.isiAduan,
                    style: GoogleFonts.poppins(
                      fontSize: isSmallScreen ? 12 : 13,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: isSmallScreen ? 12 : 16),

                  // Footer
                  Wrap(
                    spacing: isSmallScreen ? 12 : 16,
                    runSpacing: 8,
                    children: [
                      // Kategori
                      if (aduan.namaKategori != null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.category_outlined,
                              size: isSmallScreen ? 12 : 14,
                              color: Colors.grey.shade500,
                            ),
                            SizedBox(width: 4),
                            Text(
                              aduan.namaKategori!,
                              style: GoogleFonts.poppins(
                                fontSize: isSmallScreen ? 10 : 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),

                      // Lokasi jika ada
                      if (aduan.lokasi != null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: isSmallScreen ? 12 : 14,
                              color: Colors.grey.shade500,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Lokasi',
                              style: GoogleFonts.poppins(
                                fontSize: isSmallScreen ? 10 : 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),

                      // Info bisa dihapus atau tidak
                      if (!canDelete)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.lock_outline,
                              size: isSmallScreen ? 12 : 14,
                              color: Colors.grey.shade400,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Tidak dapat dihapus',
                              style: GoogleFonts.poppins(
                                fontSize: isSmallScreen ? 10 : 11,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ],
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
      blur: 10,
      opacity: 0.1,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Cari aduan...',
            hintStyle: GoogleFonts.poppins(
              color: Colors.grey.shade500,
            ),
            prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.9),
            contentPadding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 12 : 16,
              vertical: isSmallScreen ? 14 : 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(bool isSmallScreen) {
    final statusList = [
      {'value': 'semua', 'label': 'Semua', 'color': AppColors.primaryBlue},
      {'value': 'baru', 'label': 'Baru', 'color': Colors.orange},
      {'value': 'diproses', 'label': 'Diproses', 'color': Colors.blue},
      {'value': 'selesai', 'label': 'Selesai', 'color': Colors.green},
      {'value': 'ditolak', 'label': 'Ditolak', 'color': Colors.red},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: statusList.map((status) {
          final isSelected = _selectedStatus == status['value'];
          return Container(
            margin: EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                status['label'] as String,
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 11 : 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : status['color'] as Color,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedStatus = selected ? status['value'] as String : 'semua';
                  _applyFilter();
                });
              },
              backgroundColor: Colors.white,
              selectedColor: status['color'] as Color,
              side: BorderSide(
                color: status['color'] as Color,
                width: 1,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Aduan Saya',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: AppColors.darkNavy,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.darkNavy),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: AppColors.darkNavy),
            onPressed: _loadAduan,
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
                // Search Bar
                _buildSearchBar(isSmallScreen),
                SizedBox(height: isSmallScreen ? 12 : 16),
                
                // Filter Chips
                _buildFilterChips(isSmallScreen),
                SizedBox(height: isSmallScreen ? 12 : 16),
                
                // Results Count
                if (!_isLoading && !_isError)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Ditemukan ${_filteredAduanList.length} aduan',
                      style: GoogleFonts.poppins(
                        fontSize: isSmallScreen ? 12 : 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                SizedBox(height: 8),
                
                // Main Content
                Expanded(
                  child: _isLoading
                      ? Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
                      : _isError
                          ? _buildErrorState()
                          : _filteredAduanList.isEmpty
                              ? _buildEmptyState(isSmallScreen)
                              : RefreshIndicator(
                                  onRefresh: _loadAduan,
                                  color: AppColors.primaryBlue,
                                  child: ListView.builder(
                                    physics: BouncingScrollPhysics(),
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
          SizedBox(height: 16),
          Text(
            'Gagal memuat aduan',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.darkNavy,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Silakan coba lagi',
            style: GoogleFonts.poppins(
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadAduan,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
            Icons.report_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 16),
          Text(
            _searchController.text.isEmpty && _selectedStatus == 'semua'
                ? 'Belum ada aduan'
                : 'Tidak ada aduan yang sesuai',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.darkNavy,
            ),
          ),
          SizedBox(height: 8),
          Text(
            _searchController.text.isEmpty && _selectedStatus == 'semua'
                ? 'Ajukan aduan pertama Anda'
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