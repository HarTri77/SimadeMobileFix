// lib/widgets/file_download_widget.dart - FIXED
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/file_service.dart';
import '../utils/app_colors.dart';

class FileDownloadWidget extends StatelessWidget {
  final String fileName;
  final String fileType;
  final String label;

  const FileDownloadWidget({
    super.key,
    required this.fileName,
    required this.fileType,
    required this.label,
  });

  Future<void> _downloadAndOpenFile(BuildContext context) async {
    try {
      // ✅ PERBAIKAN: Tambahkan loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final url = await FileService.getDownloadUrl(fileName, fileType);
      
      print('Attempting to launch: $url'); // Debug

      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalApplication,
        );
      } else {
        throw 'Tidak dapat membuka file. URL: $url';
      }

      // Tutup loading
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    } catch (e) {
      // Tutup loading
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      
      print('Download error: $e');
      _showErrorDialog(context, 'Gagal membuka file: $e');
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Error',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          message,
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: GoogleFonts.poppins(color: AppColors.primaryBlue),
            ),
          ),
        ],
      ),
    );
  }

  // Cek apakah file adalah gambar
  bool get _isImage {
    final imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp'];
    final extension = fileName.split('.').last.toLowerCase();
    return imageExtensions.contains(extension);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _isImage ? Icons.image : Icons.description,
            color: AppColors.primaryBlue,
            size: 24,
          ),
        ),
        title: Text(
          label,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          fileName,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IconButton(
          icon: Icon(
            _isImage ? Icons.visibility : Icons.download,
            color: AppColors.primaryBlue,
          ),
          onPressed: () => _downloadAndOpenFile(context),
        ),
        onTap: () => _downloadAndOpenFile(context),
      ),
    );
  }
}