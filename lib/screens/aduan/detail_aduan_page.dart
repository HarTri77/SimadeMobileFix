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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat detail aduan: $e'),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteAduan() async {
    if (_aduan == null) return;

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
          'Apakah Anda yakin ingin menghapus aduan "${_aduan!.judul}"? Tindakan ini tidak dapat dibatalkan.',
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
      await AduanService.deleteAduan(_aduan!.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Aduan berhasil dihapus'),
            backgroundColor: AppColors.successColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
        
        // Kembali ke halaman sebelumnya
        Navigator.pop(context);
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

  // TAMBAHKAN METHOD INI untuk cek apakah aduan bisa dihapus
  bool _canDeleteAduan() {
    if (_aduan == null) return false;
    return _aduan!.status == 'baru' || _aduan!.status == 'ditolak';
  }

  Widget _buildInfoRow(IconData icon, String label, String value, bool isSmallScreen) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: isSmallScreen ? 16 : 18,
          color: Colors.grey.shade500,
        ),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 12 : 13,
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 14 : 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkNavy,
                ),
              ),
            ],
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
            'Detail Aduan',
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

    if (_isError || _aduan == null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          title: Text(
            'Detail Aduan',
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
                'Aduan tidak ditemukan',
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
                onPressed: _loadDetailAduan,
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
        ),
      );
    }

    final aduan = _aduan!;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Detail Aduan',
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
          // TOMBOL HAPUS - PASTI MUNCUL KALAU BISA DIHAPUS
          if (_canDeleteAduan()) 
            IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: AppColors.errorColor,
              ),
              onPressed: _deleteAduan,
              tooltip: 'Hapus Aduan',
            ),
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: AppColors.darkNavy,
            ),
            onPressed: _loadDetailAduan,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Judul Aduan
              Text(
                aduan.judul,
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 20 : 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkNavy,
                  height: 1.3,
                ),
              ),
              SizedBox(height: isSmallScreen ? 16 : 20),

              // Status dan Prioritas Card
              GlassContainer(
                blur: 10,
                opacity: 0.1,
                child: Container(
                  padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // Status
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Status',
                                  style: GoogleFonts.poppins(
                                    fontSize: isSmallScreen ? 12 : 13,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isSmallScreen ? 8 : 12,
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
                                      fontSize: isSmallScreen ? 11 : 12,
                                      fontWeight: FontWeight.w600,
                                      color: aduan.statusColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 16),
                          // Prioritas
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Prioritas',
                                  style: GoogleFonts.poppins(
                                    fontSize: isSmallScreen ? 12 : 13,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isSmallScreen ? 8 : 12,
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
                                        size: isSmallScreen ? 12 : 14,
                                        color: aduan.prioritasColor,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        aduan.prioritasText,
                                        style: GoogleFonts.poppins(
                                          fontSize: isSmallScreen ? 11 : 12,
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
                        ],
                      ),
                      SizedBox(height: 12),
                      // Tanggal Dibuat
                      _buildInfoRow(
                        Icons.calendar_today_outlined,
                        'Tanggal Dibuat',
                        aduan.formattedCreatedAt,
                        isSmallScreen,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: isSmallScreen ? 20 : 25),

              // Informasi Aduan
              GlassContainer(
                blur: 10,
                opacity: 0.1,
                child: Container(
                  padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informasi Aduan',
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkNavy,
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 12 : 16),
                      // Kategori
                      if (aduan.namaKategori != null) ...[
                        _buildInfoRow(
                          Icons.category_outlined,
                          'Kategori',
                          aduan.namaKategori!,
                          isSmallScreen,
                        ),
                        SizedBox(height: 12),
                      ],
                      // Lokasi
                      if (aduan.lokasi != null) ...[
                        _buildInfoRow(
                          Icons.location_on_outlined,
                          'Lokasi',
                          aduan.lokasi!,
                          isSmallScreen,
                        ),
                        SizedBox(height: 12),
                      ],
                      // Pengaju
                      _buildInfoRow(
                        Icons.person_outlined,
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
                blur: 10,
                opacity: 0.1,
                child: Container(
                  padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Isi Aduan',
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkNavy,
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 12 : 16),
                      Text(
                        aduan.isiAduan,
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 14 : 16,
                          color: Colors.grey.shade700,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    ],
                  ),
                ),
              ),

              // Tanggapan jika ada
              if (aduan.tanggapan != null && aduan.tanggapan!.isNotEmpty) ...[
                SizedBox(height: isSmallScreen ? 20 : 25),
                GlassContainer(
                  blur: 10,
                  opacity: 0.1,
                  child: Container(
                    padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tanggapan',
                          style: GoogleFonts.poppins(
                            fontSize: isSmallScreen ? 16 : 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkNavy,
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 12 : 16),
                        Text(
                          aduan.tanggapan!,
                          style: GoogleFonts.poppins(
                            fontSize: isSmallScreen ? 14 : 16,
                            color: Colors.grey.shade700,
                            height: 1.6,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                        if (aduan.adminNama != null) ...[
                          SizedBox(height: 12),
                          _buildInfoRow(
                            Icons.admin_panel_settings_outlined,
                            'Ditanggapi Oleh',
                            aduan.adminNama!,
                            isSmallScreen,
                          ),
                        ],
                        if (aduan.tanggalDiproses != null) ...[
                          SizedBox(height: 12),
                          _buildInfoRow(
                            Icons.date_range_outlined,
                            'Tanggal Ditanggapi',
                            aduan.formattedTanggalDiproses!,
                            isSmallScreen,
                          ),
                        ],
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
    );
  }
}