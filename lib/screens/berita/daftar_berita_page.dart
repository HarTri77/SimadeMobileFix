// lib/screens/berita/daftar_berita_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/berita_model.dart';
import '../../services/berita_service.dart';
import '../../utils/app_colors.dart';
import '../../widgets/glass_container.dart';
import 'detail_berita_page.dart';

class DaftarBeritaPage extends StatefulWidget {
  const DaftarBeritaPage({super.key});

  @override
  State<DaftarBeritaPage> createState() => _DaftarBeritaPageState();
}

class _DaftarBeritaPageState extends State<DaftarBeritaPage> {
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
                 berita.konten.toLowerCase().contains(searchQuery) ||
                 berita.penulisNama.toLowerCase().contains(searchQuery);
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

  Widget _buildBeritaCard(BeritaModel berita, bool isSmallScreen) {
    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 16 : 20),
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
                  builder: (context) => DetailBeritaPage(beritaId: berita.id),
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gambar Berita
                  if (berita.hasGambar) ...[
                    Container(
                      height: isSmallScreen ? 140 : 180,
                      width: double.infinity,
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
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 12 : 16),
                  ],

                  // Judul
                  Text(
                    berita.judul,
                    style: GoogleFonts.poppins(
                      fontSize: isSmallScreen ? 16 : 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkNavy,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: isSmallScreen ? 8 : 12),

                  // Preview Konten
                  Text(
                    berita.previewText,
                    style: GoogleFonts.poppins(
                      fontSize: isSmallScreen ? 13 : 14,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: isSmallScreen ? 12 : 16),

                  // Footer Info
                  Row(
                    children: [
                      // Penulis
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: isSmallScreen ? 14 : 16,
                            color: Colors.grey.shade500,
                          ),
                          SizedBox(width: 4),
                          Text(
                            berita.penulisNama,
                            style: GoogleFonts.poppins(
                              fontSize: isSmallScreen ? 11 : 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: isSmallScreen ? 12 : 16),

                      // Tanggal
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: isSmallScreen ? 14 : 16,
                            color: Colors.grey.shade500,
                          ),
                          SizedBox(width: 4),
                          Text(
                            berita.formattedPublishedAt,
                            style: GoogleFonts.poppins(
                              fontSize: isSmallScreen ? 11 : 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      Spacer(),

                      // Views
                      Row(
                        children: [
                          Icon(
                            Icons.remove_red_eye_outlined,
                            size: isSmallScreen ? 14 : 16,
                            color: Colors.grey.shade500,
                          ),
                          SizedBox(width: 4),
                          Text(
                            berita.viewsText,
                            style: GoogleFonts.poppins(
                              fontSize: isSmallScreen ? 11 : 12,
                              color: Colors.grey.shade600,
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
          'Berita Desa',
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
                
                // Results Count
                if (!_isLoading && !_isError)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Ditemukan ${_filteredBeritaList.length} berita',
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
                ? 'Tidak ada berita yang diterbitkan'
                : 'Coba ubah kata kunci pencarian',
            style: GoogleFonts.poppins(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}