// lib/widgets/file_download_widget.dart - COMPLETE REWRITE
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';
import '../services/file_service.dart';
import '../utils/app_colors.dart';
import '../config/app_config.dart';

class FileDownloadWidget extends StatefulWidget {
  final String fileName;
  final String fileType;
  final String label;

  const FileDownloadWidget({
    super.key,
    required this.fileName,
    required this.fileType,
    required this.label,
  });

  @override
  State<FileDownloadWidget> createState() => _FileDownloadWidgetState();
}

class _FileDownloadWidgetState extends State<FileDownloadWidget> {
  bool _isDownloading = false;
  double _downloadProgress = 0.0;

Future<void> _downloadAndOpenFile() async {
  try {
    setState(() {
      _isDownloading = true;
    });

    // ✅ PERBAIKAN: Coba beberapa format URL
    final List<String> urlTemplates = [
      // Format 1: Direct URL (YANG BEKERJA DI BROWSER)
      '${AppConfig.baseUrl.replaceAll('/api/', '/')}uploads/surat_${widget.fileType}/${widget.fileName}',
      '${AppConfig.baseUrl.replaceFirst('/api', '')}/uploads/surat_${widget.fileType}/${widget.fileName}',
      
      // Format 2: Standard API URL
      '${AppConfig.baseUrl}/uploads/surat_${widget.fileType}/${widget.fileName}',
      
      // Format 3: Via script (backup)
      '${AppConfig.baseUrl}/surat.php?download=true&file_name=${widget.fileName}&file_type=${widget.fileType}',
    ];

    String? successfulUrl;
    http.Response? response;

    // Coba setiap URL sampai ada yang berhasil
    for (final url in urlTemplates) {
      try {
        print('🔄 Testing URL: $url');
        response = await http.head(Uri.parse(url));
        
        if (response.statusCode == 200) {
          successfulUrl = url;
          print('✅ URL works: $url');
          break;
        }
      } catch (e) {
        print('❌ URL failed: $e');
        continue;
      }
    }

    if (successfulUrl == null) {
      throw 'Tidak ada URL yang berhasil. Status terakhir: ${response?.statusCode}';
    }

    // Download file
    final downloadResponse = await http.get(Uri.parse(successfulUrl));
    
    if (downloadResponse.statusCode == 200) {
      // Simpan file
      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/${widget.fileName}';
      final file = File(filePath);
      await file.writeAsBytes(downloadResponse.bodyBytes);
      
      // Buka file
      await OpenFile.open(filePath);
    } else {
      throw 'Gagal download (${downloadResponse.statusCode})';
    }

  } catch (e) {
    _showErrorDialog('Gagal membuka file: $e');
  } finally {
    setState(() {
      _isDownloading = false;
    });
  }
}

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  bool get _isImage {
    final imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp'];
    final extension = widget.fileName.split('.').last.toLowerCase();
    return imageExtensions.contains(extension);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label dan file info
            Row(
              children: [
                Icon(
                  _isImage ? Icons.image : Icons.description,
                  color: AppColors.primaryBlue,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.label,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.fileName,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Progress bar atau tombol download
            if (_isDownloading) ...[
              LinearProgressIndicator(
                value: _downloadProgress,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
              ),
              const SizedBox(height: 8),
              const Text(
                'Mendownload file...',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _downloadAndOpenFile,
                  icon: Icon(_isImage ? Icons.visibility : Icons.download),
                  label: Text(_isImage ? 'Lihat File' : 'Download File'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
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