// lib/screens/aduan/detail_aduan_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/aduan_service.dart';
import '../../utils/app_colors.dart';
import '../../widgets/glass_container.dart';
import '../../models/aduan_model.dart';

class DetailAduanPage extends StatefulWidget {
  final int aduanId;

  const DetailAduanPage({super.key, required this.aduanId});

  @override
  State<DetailAduanPage> createState() => _DetailAduanPageState();
}

class _DetailAduanPageState extends State<DetailAduanPage> {
  AduanModel? _aduan;
  bool _isLoading = true;
  bool _isError = false;
  bool _showFullContent = false;

  @override
  void initState() {
    super.initState();
    _loadDetailAduan();
  }

  Future<void> _loadDetailAduan() async {
    setState(() {
      _isLoading = true;
      _isError = false;
    });

    try {
      final aduan = await AduanService.getDetailAduan(widget.aduanId);
      setState(() {
        _aduan = aduan;
      });
    } catch (e) {
      setState(() => _isError = true);
      if (mounted) {
        _showErrorSnackbar('Gagal memuat detail aduan: $e');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteAduan() async {
    if (_aduan == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon Warning
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B6B).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_forever_rounded,
                  color: Color(0xFFFF6B6B),
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Hapus Aduan?',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2D3436),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Aduan "${_aduan!.judul}" akan dihapus permanen. Tindakan ini tidak dapat dibatalkan.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF636E72),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF636E72),
                        side: const BorderSide(color: Color(0xFFDFE6E9)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'Batal',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B6B),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 2,
                        shadowColor: const Color(0xFFFF6B6B).withOpacity(0.3),
                      ),
                      child: Text(
                        'Hapus',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
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
    );

    if (confirmed != true) return;

    try {
      await AduanService.deleteAduan(_aduan!.id);
      
      if (mounted) {
        _showSuccessSnackbar('Aduan berhasil dihapus');
        Navigator.pop(context);
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

  bool _canDeleteAduan() {
    if (_aduan == null) return false;
    return _aduan!.status == 'baru' || _aduan!.status == 'ditolak';
  }

  Widget _buildInfoRow(IconData icon, String label, String value, bool isSmallScreen, {Color? iconColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (iconColor ?? const Color(0xFF00D2D3)).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: isSmallScreen ? 16 : 18,
              color: iconColor ?? const Color(0xFF00D2D3),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 12 : 13,
                    color: const Color(0xFF636E72),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 14 : 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D3436),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status, Color color, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 12 : 16,
        vertical: isSmallScreen ? 6 : 8,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(status),
            color: Colors.white,
            size: isSmallScreen ? 14 : 16,
          ),
          const SizedBox(width: 6),
          Text(
            _getStatusText(status).toUpperCase(),
            style: GoogleFonts.poppins(
              fontSize: isSmallScreen ? 11 : 12,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'baru': return 'Baru';
      case 'diproses': return 'Diproses';
      case 'selesai': return 'Selesai';
      case 'ditolak': return 'Ditolak';
      default: return status;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'baru': return Icons.new_releases_rounded;
      case 'diproses': return Icons.autorenew_rounded;
      case 'selesai': return Icons.check_circle_rounded;
      case 'ditolak': return Icons.cancel_rounded;
      default: return Icons.info_rounded;
    }
  }

  Widget _buildLoadingState(bool isSmallScreen) {
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
          'Detail Aduan',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2D3436),
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: isSmallScreen ? 60 : 80,
              height: isSmallScreen ? 60 : 80,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: const Color(0xFF00D2D3),
                backgroundColor: const Color(0xFF00D2D3).withOpacity(0.1),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Memuat Detail Aduan',
              style: GoogleFonts.poppins(
                fontSize: isSmallScreen ? 16 : 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2D3436),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Mohon tunggu sebentar...',
              style: GoogleFonts.poppins(
                color: const Color(0xFF636E72),
                fontSize: isSmallScreen ? 13 : 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(bool isSmallScreen) {
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
          'Detail Aduan',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2D3436),
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: isSmallScreen ? 100 : 120,
                height: isSmallScreen ? 100 : 120,
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
              const SizedBox(height: 20),
              Text(
                'Aduan Tidak Ditemukan',
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 18 : 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2D3436),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Terjadi kesalahan saat memuat detail aduan. Silakan coba lagi.',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF636E72),
                  fontSize: isSmallScreen ? 13 : 14,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _loadDetailAduan,
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
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Coba Lagi',
                          style: GoogleFonts.poppins(
                            fontSize: isSmallScreen ? 14 : 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentSection(String title, String content, bool isSmallScreen, {bool expandable = false}) {
    final shouldTruncate = expandable && content.length > 150 && !_showFullContent;
    final displayContent = shouldTruncate ? '${content.substring(0, 150)}...' : content;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00D2D3), Color(0xFF26A69A)],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: isSmallScreen ? 16 : 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2D3436),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          displayContent,
          style: GoogleFonts.poppins(
            fontSize: isSmallScreen ? 14 : 15,
            color: const Color(0xFF636E72),
            height: 1.6,
          ),
          textAlign: TextAlign.justify,
        ),
        if (expandable && content.length > 150) ...[
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              setState(() {
                _showFullContent = !_showFullContent;
              });
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _showFullContent ? 'Tampilkan lebih sedikit' : 'Baca selengkapnya',
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 13 : 14,
                    color: const Color(0xFF00D2D3),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  _showFullContent ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                  color: const Color(0xFF00D2D3),
                  size: 18,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    if (_isLoading) return _buildLoadingState(isSmallScreen);
    if (_isError || _aduan == null) return _buildErrorState(isSmallScreen);

    final aduan = _aduan!;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_rounded, color: Color(0xFF2D3436), size: 18),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              if (_canDeleteAduan())
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFFF6B6B), size: 20),
                  ),
                  onPressed: _deleteAduan,
                ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.refresh_rounded, color: Color(0xFF00D2D3), size: 20),
                ),
                onPressed: _loadDetailAduan,
              ),
            ],
            expandedHeight: isSmallScreen ? 180 : 200,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFF00D2D3), const Color(0xFF26A69A).withOpacity(0.9)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    // Background Pattern
                    Positioned(
                      right: -50,
                      top: -50,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      left: -30,
                      bottom: -30,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: isSmallScreen ? 60 : 70,
                            height: isSmallScreen ? 60 : 70,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.report_problem_rounded,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              aduan.judul,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: isSmallScreen ? 18 : 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
              child: Column(
                children: [
                  // Status Card
                  GlassContainer(
                    blur: 15,
                    opacity: 0.08,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Status Aduan',
                                      style: GoogleFonts.poppins(
                                        fontSize: isSmallScreen ? 13 : 14,
                                        color: const Color(0xFF636E72),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    _buildStatusBadge(aduan.status, aduan.statusColor, isSmallScreen),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Prioritas',
                                      style: GoogleFonts.poppins(
                                        fontSize: isSmallScreen ? 13 : 14,
                                        color: const Color(0xFF636E72),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: isSmallScreen ? 12 : 16,
                                        vertical: isSmallScreen ? 6 : 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: aduan.prioritasColor.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(20),
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
                                            size: isSmallScreen ? 14 : 16,
                                            color: aduan.prioritasColor,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            aduan.prioritasText,
                                            style: GoogleFonts.poppins(
                                              fontSize: isSmallScreen ? 11 : 12,
                                              fontWeight: FontWeight.w700,
                                              color: aduan.prioritasColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow(
                            Icons.calendar_today_rounded,
                            'Tanggal Dibuat',
                            aduan.formattedCreatedAt,
                            isSmallScreen,
                            iconColor: const Color(0xFFFFA502),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 20 : 25),

                  // Informasi Aduan
                  GlassContainer(
                    blur: 15,
                    opacity: 0.08,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 4,
                                height: 20,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF00D2D3), Color(0xFF26A69A)],
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Informasi Aduan',
                                style: GoogleFonts.poppins(
                                  fontSize: isSmallScreen ? 16 : 18,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF2D3436),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (aduan.namaKategori != null)
                            _buildInfoRow(
                              Icons.category_rounded,
                              'Kategori',
                              aduan.namaKategori!,
                              isSmallScreen,
                            ),
                          if (aduan.lokasi != null)
                            _buildInfoRow(
                              Icons.location_on_rounded,
                              'Lokasi',
                              aduan.lokasi!,
                              isSmallScreen,
                            ),
                          _buildInfoRow(
                            Icons.person_rounded,
                            'Diajukan Oleh',
                            aduan.userNama,
                            isSmallScreen,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 20 : 25),

                  // Isi Aduan
                  GlassContainer(
                    blur: 15,
                    opacity: 0.08,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                      child: _buildContentSection(
                        'Isi Aduan',
                        aduan.isiAduan,
                        isSmallScreen,
                        expandable: true,
                      ),
                    ),
                  ),

                  // Tanggapan jika ada
                  if (aduan.tanggapan != null && aduan.tanggapan!.isNotEmpty) ...[
                    SizedBox(height: isSmallScreen ? 20 : 25),
                    GlassContainer(
                      blur: 15,
                      opacity: 0.08,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFFFFA502), Color(0xFFFFA502)],
                                    ),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Tanggapan Admin',
                                  style: GoogleFonts.poppins(
                                    fontSize: isSmallScreen ? 16 : 18,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF2D3436),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFA502).withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFFFA502).withOpacity(0.2),
                                ),
                              ),
                              child: Text(
                                aduan.tanggapan!,
                                style: GoogleFonts.poppins(
                                  fontSize: isSmallScreen ? 14 : 15,
                                  color: const Color(0xFF636E72),
                                  height: 1.6,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (aduan.adminNama != null)
                              _buildInfoRow(
                                Icons.admin_panel_settings_rounded,
                                'Ditanggapi Oleh',
                                aduan.adminNama!,
                                isSmallScreen,
                                iconColor: const Color(0xFFFFA502),
                              ),
                            if (aduan.tanggalDiproses != null)
                              _buildInfoRow(
                                Icons.date_range_rounded,
                                'Tanggal Ditanggapi',
                                aduan.formattedTanggalDiproses!,
                                isSmallScreen,
                                iconColor: const Color(0xFFFFA502),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  SizedBox(height: isSmallScreen ? 20 : 25),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}