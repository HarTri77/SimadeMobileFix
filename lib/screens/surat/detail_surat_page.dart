// lib/screens/surat/detail_surat_page.dart - UPDATED WITH FILE DOWNLOAD
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/surat_model.dart';
import '../../utils/app_colors.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/file_download_widget.dart'; // ✅ IMPORT FILE DOWNLOAD

class DetailSuratPage extends StatelessWidget {
  final SuratModel surat;

  const DetailSuratPage({super.key, required this.surat});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return const Color(0xFFFF9800);
      case 'diproses':
        return AppColors.primaryBlue;
      case 'selesai':
        return const Color(0xFF66BB6A);
      case 'ditolak':
        return const Color(0xFFEF5350);
      default:
        return const Color(0xFFFF9800);
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildDetailRow(String label, String value, bool isSmallScreen) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: AppColors.darkNavy,
                fontSize: isSmallScreen ? 13 : 14,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: GoogleFonts.poppins(
                color: Colors.grey.shade700,
                fontSize: isSmallScreen ? 13 : 14,
              ),
            ),
          ),
        ],
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
          'Detail Surat',
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
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // Status Card
                  GlassContainer(
                    blur: 15,
                    opacity: 0.1,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.description_outlined, color: Colors.white, size: 28),
                          ),
                          SizedBox(width: isSmallScreen ? 12 : 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  surat.jenisSurat,
                                  style: GoogleFonts.poppins(
                                    fontSize: isSmallScreen ? 16 : 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkNavy,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(surat.status).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: _getStatusColor(surat.status), width: 1),
                                  ),
                                  child: Text(
                                    surat.statusText.toUpperCase(),
                                    style: GoogleFonts.poppins(
                                      fontSize: isSmallScreen ? 11 : 12,
                                      fontWeight: FontWeight.w600,
                                      color: _getStatusColor(surat.status),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Informasi Pengajuan
                  GlassContainer(
                    blur: 15,
                    opacity: 0.1,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Informasi Pengajuan',
                            style: GoogleFonts.poppins(
                              fontSize: isSmallScreen ? 16 : 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkNavy,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildDetailRow('Jenis Surat', surat.jenisSurat, isSmallScreen),
                          _buildDetailRow('Keperluan', surat.keperluan, isSmallScreen),
                          _buildDetailRow('Tanggal Pengajuan', _formatDate(surat.tanggalPengajuan), isSmallScreen),
                          if (surat.tanggalDiproses != null)
                            _buildDetailRow('Tanggal Diproses', _formatDate(surat.tanggalDiproses!), isSmallScreen),
                          if (surat.tanggalSelesai != null)
                            _buildDetailRow('Tanggal Selesai', _formatDate(surat.tanggalSelesai!), isSmallScreen),
                        ],
                      ),
                    ),
                  ),

                  // ✅ FILE PENDUKUNG (jika ada)
                  if (surat.hasFilePendukung) ...[
                    const SizedBox(height: 16),
                    GlassContainer(
                      blur: 15,
                      opacity: 0.1,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'File Pendukung',
                              style: GoogleFonts.poppins(
                                fontSize: isSmallScreen ? 16 : 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkNavy,
                              ),
                            ),
                            const SizedBox(height: 8),
                            FileDownloadWidget(
                              fileName: surat.filePendukung!,
                              fileType: 'pendukung',
                              label: 'File Pendukung - ${surat.filePendukungType}',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // ✅ CATATAN ADMIN (jika ada)
                  if (surat.catatanAdmin != null) ...[
                    const SizedBox(height: 16),
                    GlassContainer(
                      blur: 15,
                      opacity: 0.1,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Catatan Admin',
                              style: GoogleFonts.poppins(
                                fontSize: isSmallScreen ? 16 : 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkNavy,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              surat.catatanAdmin!,
                              style: GoogleFonts.poppins(
                                fontSize: isSmallScreen ? 14 : 16,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // ✅ FILE HASIL DARI ADMIN (jika ada)
                  if (surat.hasFileHasil) ...[
                    const SizedBox(height: 16),
                    GlassContainer(
                      blur: 15,
                      opacity: 0.1,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.file_download_done,
                                  color: AppColors.successColor,
                                  size: isSmallScreen ? 20 : 24,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'File Hasil dari Admin',
                                  style: GoogleFonts.poppins(
                                    fontSize: isSmallScreen ? 16 : 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkNavy,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Admin telah mengupload file hasil surat yang sudah ditandatangani. Silakan download file berikut:',
                              style: GoogleFonts.poppins(
                                fontSize: isSmallScreen ? 13 : 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            FileDownloadWidget(
                              fileName: surat.fileHasil!,
                              fileType: 'hasil',
                              label: 'File Hasil Surat - ${surat.fileHasilType}',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // ✅ INSTRUKSI JIKA STATUS SELESAI TAPI TIDAK ADA FILE
                  if (surat.status == 'selesai' && !surat.hasFileHasil) ...[
                    const SizedBox(height: 16),
                    GlassContainer(
                      blur: 15,
                      opacity: 0.1,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: AppColors.primaryBlue,
                                  size: isSmallScreen ? 20 : 24,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Informasi',
                                  style: GoogleFonts.poppins(
                                    fontSize: isSmallScreen ? 16 : 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkNavy,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Surat Anda telah selesai diproses. Silakan hubungi admin untuk mengambil surat fisik yang sudah ditandatangani.',
                              style: GoogleFonts.poppins(
                                fontSize: isSmallScreen ? 13 : 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}