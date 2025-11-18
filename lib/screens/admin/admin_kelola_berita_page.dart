// lib/screens/admin/admin_kelola_berita_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/berita_model.dart';
import '../../services/berita_service.dart';
import '../../utils/app_colors.dart';
import '../../widgets/glass_container.dart';
import 'admin_tambah_berita_page.dart';
import 'admin_edit_berita_page.dart';

class AdminKelolaBeritaPage extends StatefulWidget {
  const AdminKelolaBeritaPage({super.key});

  @override
  State<AdminKelolaBeritaPage> createState() => _AdminKelolaBeritaPageState();
}

class _AdminKelolaBeritaPageState extends State<AdminKelolaBeritaPage> {
  List<BeritaModel> _beritaList = [];
  List<BeritaModel> _filteredBeritaList = [];
  bool _isLoading = true;
  bool _isError = false;
  
  // Search
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadBerita();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _applySearch();
  }

  void _applySearch() {
    String searchQuery = _searchController.text.toLowerCase();
    
    setState(() {
      if (searchQuery.isEmpty) {
        _filteredBeritaList = _beritaList;
      } else {
        _filteredBeritaList = _beritaList.where((berita) {
          return berita.judul.toLowerCase().contains(searchQuery) ||
                 berita.konten.toLowerCase().contains(searchQuery);
        }).toList();
      }
    });
  }

  Future<void> _loadBerita() async {
    setState(() {
      _isLoading = true;
      _isError = false;
    });

    try {
      final berita = await BeritaService.getBerita();
      setState(() {
        _beritaList = berita;
        _filteredBeritaList = berita;
      });
    } catch (e) {
      setState(() => _isError = true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal memuat berita: $e',
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

  Future<void> _deleteBerita(int beritaId, String judul) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Konfirmasi Hapus',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus berita "$judul"?',
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
              'Ya, Hapus',
              style: GoogleFonts.poppins(color: AppColors.errorColor),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await BeritaService.deleteBerita(beritaId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Berita berhasil dihapus',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: AppColors.successColor,
            ),
          );
          _loadBerita(); // Reload data
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Gagal menghapus berita: $e',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: AppColors.errorColor,
            ),
          );
        }
      }
    }
  }

  Widget _buildBeritaCard(BeritaModel berita, bool isSmallScreen) {
    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 12 : 16),
      child: GlassContainer(
        blur: 10,
        opacity: 0.1,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gambar Thumbnail
              if (berita.hasGambar) ...[
                Container(
                  width: isSmallScreen ? 60 : 80,
                  height: isSmallScreen ? 60 : 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade200,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: berita.gambarUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey.shade200,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryBlue,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey.shade200,
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          color: Colors.grey.shade400,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: isSmallScreen ? 12 : 16),
              ],

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Judul
                    Text(
                      berita.judul,
                      style: GoogleFonts.poppins(
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkNavy,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),

                    // Preview Konten
                    Text(
                      berita.previewText,
                      style: GoogleFonts.poppins(
                        fontSize: isSmallScreen ? 11 : 12,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),

                    // Info Footer
                    Row(
                      children: [
                        // Tanggal
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: isSmallScreen ? 12 : 14,
                              color: Colors.grey.shade500,
                            ),
                            SizedBox(width: 4),
                            Text(
                              berita.formattedPublishedAt,
                              style: GoogleFonts.poppins(
                                fontSize: isSmallScreen ? 10 : 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 12),

                        // Views
                        Row(
                          children: [
                            Icon(
                              Icons.remove_red_eye_outlined,
                              size: isSmallScreen ? 12 : 14,
                              color: Colors.grey.shade500,
                            ),
                            SizedBox(width: 4),
                            Text(
                              berita.viewsText,
                              style: GoogleFonts.poppins(
                                fontSize: isSmallScreen ? 10 : 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        Spacer(),

                        // Action Buttons
                        Row(
                          children: [
                            // Edit Button
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AdminEditBeritaPage(berita: berita),
                                  ),
                                ).then((_) => _loadBerita());
                              },
                              icon: Icon(
                                Icons.edit_outlined,
                                size: isSmallScreen ? 16 : 18,
                                color: AppColors.primaryBlue,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints(),
                            ),
                            SizedBox(width: 8),

                            // Delete Button
                            IconButton(
                              onPressed: () => _deleteBerita(berita.id, berita.judul),
                              icon: Icon(
                                Icons.delete_outline,
                                size: isSmallScreen ? 16 : 18,
                                color: AppColors.errorColor,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
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
            hintText: 'Cari berita...',
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Kelola Berita',
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
            onPressed: _loadBerita,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AdminTambahBeritaPage(),
            ),
          ).then((_) => _loadBerita());
        },
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        child: Icon(Icons.add),
        elevation: 2,
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
                SizedBox(height: isSmallScreen ? 16 : 20),
                
                // Results Count & Add Button
                Row(
                  children: [
                    Text(
                      'Total: ${_filteredBeritaList.length} berita',
                      style: GoogleFonts.poppins(
                        fontSize: isSmallScreen ? 12 : 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Spacer(),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AdminTambahBeritaPage(),
                          ),
                        ).then((_) => _loadBerita());
                      },
                      icon: Icon(Icons.add, size: isSmallScreen ? 16 : 18),
                      label: Text(
                        'Tambah Berita',
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 12 : 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 12 : 16,
                          vertical: isSmallScreen ? 8 : 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                
                // Main Content
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: AppColors.primaryBlue),
                        )
                      : _isError
                          ? _buildErrorState()
                          : _filteredBeritaList.isEmpty
                              ? _buildEmptyState(isSmallScreen)
                              : RefreshIndicator(
                                  onRefresh: _loadBerita,
                                  color: AppColors.primaryBlue,
                                  child: ListView.builder(
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: _filteredBeritaList.length,
                                    itemBuilder: (context, index) {
                                      return _buildBeritaCard(_filteredBeritaList[index], isSmallScreen);
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
            'Gagal memuat berita',
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
            onPressed: _loadBerita,
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
            Icons.article_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 16),
          Text(
            _searchController.text.isEmpty
                ? 'Belum ada berita'
                : 'Tidak ada berita yang sesuai',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.darkNavy,
            ),
          ),
          SizedBox(height: 8),
          Text(
            _searchController.text.isEmpty
                ? 'Tambahkan berita pertama Anda'
                : 'Coba ubah kata kunci pencarian',
            style: GoogleFonts.poppins(
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AdminTambahBeritaPage(),
                ),
              ).then((_) => _loadBerita());
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
              'Tambah Berita Pertama',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}