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
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('Gagal memuat berita: $e'),
              ],
            ),
            backgroundColor: Color(0xFFFF6B6B),
            behavior: SnackBarBehavior.floating,
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
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.4,
          ),
          child: Container(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Color(0xFFFF6B6B).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.warning_amber_rounded,
                        color: Color(0xFFFF6B6B),
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Hapus Berita',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2D3436),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Text(
                  'Apakah Anda yakin ingin menghapus berita "$judul"?',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Color(0xFF636E72),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1.5,
                          ),
                        ),
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context, false),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Color(0xFF2D3436),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Batal',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFFFF6B6B).withOpacity(0.3),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Hapus',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (confirmed == true) {
      try {
        await BeritaService.deleteBerita(beritaId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text('Berita berhasil dihapus'),
                ],
              ),
              backgroundColor: Color(0xFF00D2D3),
              behavior: SnackBarBehavior.floating,
            ),
          );
          _loadBerita();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text('Gagal menghapus berita: $e'),
                ],
              ),
              backgroundColor: Color(0xFFFF6B6B),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 380;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'Kelola Berita',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: Color(0xFF2D3436),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: Color(0xFF2D3436)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: Container(
        margin: EdgeInsets.only(bottom: isSmallScreen ? 16 : 20),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AdminTambahBeritaPage(),
              ),
            ).then((_) => _loadBerita());
          },
          backgroundColor: Color(0xFF6C5CE7),
          foregroundColor: Colors.white,
          elevation: 4,
          child: Icon(
            Icons.add_rounded, 
            size: isSmallScreen ? 24 : 28
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 12 : isTablet ? 24 : 16),
          child: Column(
            children: [
              // Search Bar
              _buildSearchBar(isSmallScreen, isTablet),
              SizedBox(height: isSmallScreen ? 16 : 20),
              
              // Header Section
              _buildHeaderSection(isSmallScreen, isTablet),
              SizedBox(height: isSmallScreen ? 16 : 20),
              
              // Main Content
              Expanded(
                child: _isLoading
                    ? _buildLoadingState(isSmallScreen, isTablet)
                    : _isError
                        ? _buildErrorState()
                        : _filteredBeritaList.isEmpty
                            ? _buildEmptyState(isSmallScreen)
                            : _buildBeritaList(isSmallScreen, isTablet),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isSmallScreen, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari berita...',
                  hintStyle: GoogleFonts.poppins(
                    color: Color(0xFF636E72),
                    fontSize: isSmallScreen ? 14 : 16,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: Color(0xFF636E72),
                    size: isSmallScreen ? 20 : 24,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 12 : 16,
                    vertical: isSmallScreen ? 14 : 16,
                  ),
                ),
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 14 : 16,
                ),
              ),
            ),
          ),
          SizedBox(width: isSmallScreen ? 8 : 12),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: _loadBerita,
              icon: Icon(
                Icons.refresh_rounded,
                color: Colors.white,
                size: isSmallScreen ? 20 : 24,
              ),
              padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(bool isSmallScreen, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 10 : 12,
              vertical: isSmallScreen ? 6 : 8,
            ),
            decoration: BoxDecoration(
              color: Color(0xFF6C5CE7).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_filteredBeritaList.length} Berita',
              style: GoogleFonts.poppins(
                fontSize: isSmallScreen ? 12 : 14,
                color: Color(0xFF6C5CE7),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Spacer(),
          Container(
            height: isSmallScreen ? 36 : isTablet ? 48 : 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF00D2D3), Color(0xFF26A69A)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF00D2D3).withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdminTambahBeritaPage(),
                  ),
                ).then((_) => _loadBerita());
              },
              icon: Icon(
                Icons.add_rounded,
                size: isSmallScreen ? 16 : 18,
              ),
              label: Text(
                'Tambah',
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 12 : 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 12 : 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBeritaList(bool isSmallScreen, bool isTablet) {
    return RefreshIndicator(
      onRefresh: _loadBerita,
      color: Color(0xFF6C5CE7),
      backgroundColor: Colors.white,
      child: isTablet 
          ? GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.6,
              ),
              physics: BouncingScrollPhysics(),
              itemCount: _filteredBeritaList.length,
              itemBuilder: (context, index) {
                return _buildBeritaCard(_filteredBeritaList[index], isSmallScreen, isTablet);
              },
            )
          : ListView.builder(
              physics: BouncingScrollPhysics(),
              itemCount: _filteredBeritaList.length,
              itemBuilder: (context, index) {
                return _buildBeritaCard(_filteredBeritaList[index], isSmallScreen, isTablet);
              },
            ),
    );
  }

  Widget _buildBeritaCard(BeritaModel berita, bool isSmallScreen, bool isTablet) {
    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 12 : 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // TODO: Add detail berita page if needed
          },
          child: Container(
            padding: EdgeInsets.all(isSmallScreen ? 12 : isTablet ? 20 : 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Content Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Gambar Thumbnail
                    if (berita.hasGambar) ...[
                      Container(
                        width: isTablet ? 120 : (isSmallScreen ? 80 : 100),
                        height: isTablet ? 120 : (isSmallScreen ? 80 : 100),
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
                                  color: Color(0xFF6C5CE7),
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey.shade200,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image_not_supported_outlined,
                                    color: Colors.grey.shade400,
                                    size: isSmallScreen ? 20 : 24,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Gagal memuat',
                                    style: GoogleFonts.poppins(
                                      fontSize: isSmallScreen ? 10 : 12,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
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
                              fontSize: isSmallScreen ? 14 : isTablet ? 18 : 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2D3436),
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 8),

                          // Preview Konten
                          Text(
                            berita.previewText,
                            style: GoogleFonts.poppins(
                              fontSize: isSmallScreen ? 12 : isTablet ? 14 : 13,
                              color: Color(0xFF636E72),
                              height: 1.4,
                            ),
                            maxLines: isTablet ? 3 : 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isSmallScreen ? 12 : 16),

                // Info Footer - FIXED: Tidak ada overflow
                _buildFooterInfo(berita, isSmallScreen, isTablet),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooterInfo(BeritaModel berita, bool isSmallScreen, bool isTablet) {
    return Row(
      children: [
        // Info items
        Expanded(
          child: Wrap(
            spacing: isSmallScreen ? 8 : 12,
            runSpacing: 8,
            children: [
              _buildInfoItem(
                Icons.calendar_today_rounded,
                berita.formattedPublishedAt,
                isSmallScreen,
              ),
              _buildInfoItem(
                Icons.remove_red_eye_rounded,
                berita.viewsText,
                isSmallScreen,
              ),
            ],
          ),
        ),
        
        SizedBox(width: 8),
        
        // Action Buttons - FIXED: Tidak akan overflow
        Container(
          constraints: BoxConstraints(
            maxWidth: isSmallScreen ? 90 : 100,
          ),
          decoration: BoxDecoration(
            color: Color(0xFFF5F7FA),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
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
                  Icons.edit_rounded,
                  size: isSmallScreen ? 18 : 20,
                  color: Color(0xFF6C5CE7),
                ),
                padding: EdgeInsets.all(6),
                constraints: BoxConstraints(
                  minWidth: 36,
                  minHeight: 36,
                ),
              ),
              Container(
                width: 1,
                height: 20,
                color: Colors.grey.shade300,
              ),
              // Delete Button
              IconButton(
                onPressed: () => _deleteBerita(berita.id, berita.judul),
                icon: Icon(
                  Icons.delete_rounded,
                  size: isSmallScreen ? 18 : 20,
                  color: Color(0xFFFF6B6B),
                ),
                padding: EdgeInsets.all(6),
                constraints: BoxConstraints(
                  minWidth: 36,
                  minHeight: 36,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(IconData icon, String text, bool isSmallScreen) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: isSmallScreen ? 100 : 120,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: isSmallScreen ? 14 : 16,
            color: Color(0xFF636E72),
          ),
          SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: isSmallScreen ? 10 : 11,
                color: Color(0xFF636E72),
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(bool isSmallScreen, bool isTablet) {
    final itemCount = isTablet ? 4 : 6;
    
    return isTablet
        ? GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.6,
            ),
            itemCount: itemCount,
            itemBuilder: (context, index) {
              return _buildSkeletonCard(isSmallScreen, isTablet);
            },
          )
        : ListView.builder(
            itemCount: itemCount,
            itemBuilder: (context, index) {
              return _buildSkeletonCard(isSmallScreen, isTablet);
            },
          );
  }

  Widget _buildSkeletonCard(bool isSmallScreen, bool isTablet) {
    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 12 : 16),
      padding: EdgeInsets.all(isSmallScreen ? 12 : isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Skeleton
          Container(
            width: isTablet ? 120 : (isSmallScreen ? 80 : 100),
            height: isTablet ? 120 : (isSmallScreen ? 80 : 100),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          SizedBox(width: isSmallScreen ? 12 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: isSmallScreen ? 16 : 20,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  height: isSmallScreen ? 14 : 16,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  width: isSmallScreen ? 100 : 120,
                  height: isSmallScreen ? 14 : 16,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      width: isSmallScreen ? 60 : 80,
                      height: isSmallScreen ? 12 : 14,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Spacer(),
                    Container(
                      width: isSmallScreen ? 60 : 80,
                      height: isSmallScreen ? 28 : 32,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Color(0xFFFF6B6B).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline_rounded,
              size: 60,
              color: Color(0xFFFF6B6B),
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Gagal Memuat Berita',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D3436),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Terjadi kesalahan saat memuat data berita',
            style: GoogleFonts.poppins(
              color: Color(0xFF636E72),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          Container(
            width: 200,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF6C5CE7).withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _loadBerita,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.refresh_rounded, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Coba Lagi',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
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
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Color(0xFF6C5CE7).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.article_rounded,
              size: 60,
              color: Color(0xFF6C5CE7),
            ),
          ),
          SizedBox(height: 24),
          Text(
            _searchController.text.isEmpty
                ? 'Belum Ada Berita'
                : 'Berita Tidak Ditemukan',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D3436),
            ),
          ),
          SizedBox(height: 8),
          Text(
            _searchController.text.isEmpty
                ? 'Mulai dengan menambahkan berita pertama Anda'
                : 'Tidak ada berita yang sesuai dengan pencarian Anda',
            style: GoogleFonts.poppins(
              color: Color(0xFF636E72),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          Container(
            width: 220,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF6C5CE7).withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdminTambahBeritaPage(),
                  ),
                ).then((_) => _loadBerita());
              },
              icon: Icon(Icons.add_rounded, size: 20),
              label: Text(
                'Tambah Berita Pertama',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          if (_searchController.text.isNotEmpty) ...[
            SizedBox(height: 12),
            TextButton(
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _applySearch();
                });
              },
              child: Text(
                'Reset Pencarian',
                style: GoogleFonts.poppins(
                  color: Color(0xFF6C5CE7),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}