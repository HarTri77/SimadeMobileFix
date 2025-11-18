// lib/screens/berita/detail_berita_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/berita_model.dart';
import '../../services/berita_service.dart';
import '../../utils/app_colors.dart';
import '../../widgets/glass_container.dart';

class DetailBeritaPage extends StatefulWidget {
  final int beritaId;

  const DetailBeritaPage({super.key, required this.beritaId});

  @override
  State<DetailBeritaPage> createState() => _DetailBeritaPageState();
}

class _DetailBeritaPageState extends State<DetailBeritaPage> {
  BeritaModel? _berita;
  bool _isLoading = true;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _loadDetailBerita();
  }

// Di _loadDetailBerita method - perbaiki error handling
Future<void> _loadDetailBerita() async {
  setState(() {
    _isLoading = true;
    _isError = false;
  });

  try {
    print('Loading detail berita with ID: ${widget.beritaId}');
    final berita = await BeritaService.getDetailBerita(widget.beritaId);
    setState(() {
      _berita = berita;
    });
  } catch (e) {
    print('Error loading detail berita: $e');
    setState(() => _isError = true);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat detail berita: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } finally {
    setState(() => _isLoading = false);
  }
}

  Widget _buildInfoRow(IconData icon, String text, bool isSmallScreen) {
    return Row(
      children: [
        Icon(
          icon,
          size: isSmallScreen ? 16 : 18,
          color: Colors.grey.shade500,
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: isSmallScreen ? 13 : 14,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          title: Text(
            'Detail Berita',
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
        ),
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryBlue,
          ),
        ),
      );
    }

    if (_isError || _berita == null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          title: Text('Detail Berita'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              SizedBox(height: 16),
              Text(
                'Berita tidak ditemukan',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadDetailBerita,
                child: Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    final berita = _berita!;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
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
          icon: Icon(Icons.arrow_back, color: AppColors.darkNavy),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            // Gambar Berita (jika ada)
            if (berita.hasGambar) ...[
              Container(
                height: isSmallScreen ? 200 : 250,
                width: double.infinity,
                child: CachedNetworkImage(
                  imageUrl: berita.gambarUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey.shade200,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey.shade200,
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: Colors.grey.shade400,
                      size: 50,
                    ),
                  ),
                ),
              ),
            ],

            // Content
            Padding(
              padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul
                  Text(
                    berita.judul,
                    style: GoogleFonts.poppins(
                      fontSize: isSmallScreen ? 20 : 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkNavy,
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 16 : 20),

                  // Info Card
                  GlassContainer(
                    blur: 10,
                    opacity: 0.1,
                    child: Container(
                      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                      child: Column(
                        children: [
                          _buildInfoRow(
                            Icons.person_outline,
                            'Penulis: ${berita.penulisNama}',
                            isSmallScreen,
                          ),
                          SizedBox(height: 12),
                          _buildInfoRow(
                            Icons.calendar_today_outlined,
                            'Tanggal: ${berita.formattedPublishedAt}',
                            isSmallScreen,
                          ),
                          SizedBox(height: 12),
                          _buildInfoRow(
                            Icons.remove_red_eye_outlined,
                            'Dilihat: ${berita.viewsText}',
                            isSmallScreen,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 20 : 25),

                  // Konten
                  Text(
                    berita.konten,
                    style: GoogleFonts.poppins(
                      fontSize: isSmallScreen ? 14 : 16,
                      color: Colors.grey.shade700,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  SizedBox(height: isSmallScreen ? 20 : 25),

                  // Share Button
                  if (berita.hasGambar) ...[
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Implement share functionality
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Fitur share akan segera hadir!'),
                              backgroundColor: AppColors.primaryBlue,
                            ),
                          );
                        },
                        icon: Icon(Icons.share_outlined),
                        label: Text(
                          'Bagikan Berita',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 24 : 32,
                            vertical: isSmallScreen ? 12 : 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}