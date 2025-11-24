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
            backgroundColor: const Color(0xFFFF6B6B),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Color(0xFF2D3436)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Berita Desa',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2D3436),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF6C5CE7)),
            onPressed: _loadBerita,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchSection(),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF6C5CE7),
                    ),
                  )
                : _isError
                    ? _buildErrorState()
                    : _filteredBeritaList.isEmpty
                        ? _buildEmptyState()
                        : _buildBeritaList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      child: Column(
        children: [
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
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari berita...',
                hintStyle: GoogleFonts.poppins(
                  color: const Color(0xFF636E72),
                  fontSize: 14,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Color(0xFF6C5CE7),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, color: Color(0xFF636E72)),
                        onPressed: () {
                          _searchController.clear();
                          _applySearch();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xFF2D3436),
              ),
            ),
          ),
          if (!_isLoading && !_isError) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'Ditemukan ${_filteredBeritaList.length} berita',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: const Color(0xFF636E72),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBeritaList() {
    return RefreshIndicator(
      onRefresh: _loadBerita,
      color: const Color(0xFF6C5CE7),
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        itemCount: _filteredBeritaList.length,
        itemBuilder: (context, index) {
          return _buildBeritaCard(_filteredBeritaList[index]);
        },
      ),
    );
  }

  Widget _buildBeritaCard(BeritaModel berita) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
              children: [
                // Gambar Berita
                if (berita.hasGambar)
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: berita.gambarUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF6C5CE7),
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey.shade200,
                          child: Icon(
                            Icons.image_not_supported_rounded,
                            color: Colors.grey.shade400,
                            size: 48,
                          ),
                        ),
                      ),
                    ),
                  ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Judul
                      Text(
                        berita.judul,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2D3436),
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),

                      // Preview Konten
                      Text(
                        berita.previewText,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: const Color(0xFF636E72),
                          height: 1.5,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),

                      // Footer Info
                      Row(
                        children: [
                          // Penulis
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6C5CE7).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.person_outline_rounded,
                                  size: 14,
                                  color: Color(0xFF6C5CE7),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  berita.penulisNama,
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: const Color(0xFF6C5CE7),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Tanggal
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 12,
                                color: Colors.grey.shade500,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                berita.formattedPublishedAt,
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),

                          // Views
                          Row(
                            children: [
                              Icon(
                                Icons.visibility_outlined,
                                size: 12,
                                color: Colors.grey.shade500,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                berita.viewsText,
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B6B).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: Color(0xFFFF6B6B),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Gagal Memuat Berita',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2D3436),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Terjadi kesalahan saat memuat data.\nSilakan coba lagi.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xFF636E72),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 160,
              height: 48,
              child: ElevatedButton(
                onPressed: _loadBerita,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C5CE7),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.refresh_rounded, size: 20),
                    const SizedBox(width: 8),
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
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF6C5CE7).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _searchController.text.isEmpty
                    ? Icons.article_outlined
                    : Icons.search_off_rounded,
                size: 64,
                color: const Color(0xFF6C5CE7),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _searchController.text.isEmpty
                  ? 'Belum Ada Berita'
                  : 'Tidak Ditemukan',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2D3436),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchController.text.isEmpty
                  ? 'Belum ada berita yang dipublikasikan.\nSilakan cek kembali nanti.'
                  : 'Tidak ada berita yang cocok dengan\npencarian Anda.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xFF636E72),
              ),
            ),
            if (_searchController.text.isNotEmpty) ...[
              const SizedBox(height: 24),
              TextButton(
                onPressed: () {
                  _searchController.clear();
                  _applySearch();
                },
                child: Text(
                  'Hapus Pencarian',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF6C5CE7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}