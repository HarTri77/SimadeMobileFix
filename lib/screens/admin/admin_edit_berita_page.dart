// lib/screens/admin/admin_edit_berita_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/berita_model.dart';
import '../../services/berita_service.dart';
import '../../services/file_service.dart';
import '../../utils/app_colors.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/file_picker_widget.dart';
import '../../config/app_config.dart';

class AdminEditBeritaPage extends StatefulWidget {
  final BeritaModel berita;

  const AdminEditBeritaPage({super.key, required this.berita});

  @override
  State<AdminEditBeritaPage> createState() => _AdminEditBeritaPageState();
}

class _AdminEditBeritaPageState extends State<AdminEditBeritaPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _judulController;
  late TextEditingController _kontenController;

  PlatformFile? _gambarFile;
  String? _gambarFileName;
  bool _isLoading = false;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _judulController = TextEditingController(text: widget.berita.judul);
    _kontenController = TextEditingController(text: widget.berita.konten);
    _gambarFileName = widget.berita.gambar;
  }

  Future<void> _uploadGambar() async {
    if (_gambarFile == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final result = await BeritaService.uploadGambarBerita(_gambarFile!);
      
      setState(() {
        _gambarFileName = result['file_name'];
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gambar berhasil diupload'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal upload gambar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _updateBerita() async {
    if (!_formKey.currentState!.validate()) return;

    if (_gambarFile != null && _gambarFileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Silakan upload gambar terlebih dahulu'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await BeritaService.updateBerita(
        id: widget.berita.id,
        judul: _judulController.text,
        konten: _kontenController.text,
        gambar: _gambarFileName,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Berita berhasil diperbarui'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true); // Return success
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui berita: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _removeGambar() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus Gambar'),
        content: Text('Apakah Anda yakin ingin menghapus gambar berita ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _gambarFileName = null;
        _gambarFile = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Edit Berita',
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
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryBlue,
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Info
                    GlassContainer(
                      blur: 10,
                      opacity: 0.1,
                      child: Container(
                        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit_outlined,
                              color: AppColors.primaryBlue,
                              size: isSmallScreen ? 24 : 28,
                            ),
                            SizedBox(width: isSmallScreen ? 12 : 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Edit Berita',
                                    style: GoogleFonts.poppins(
                                      fontSize: isSmallScreen ? 16 : 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.darkNavy,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Perbarui informasi berita',
                                    style: GoogleFonts.poppins(
                                      fontSize: isSmallScreen ? 12 : 13,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 20 : 25),

                    // Judul
                    Text(
                      'Judul Berita *',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkNavy,
                        fontSize: isSmallScreen ? 14 : 15,
                      ),
                    ),
                    SizedBox(height: 8),
                    GlassContainer(
                      blur: 8,
                      opacity: 0.05,
                      child: TextFormField(
                        controller: _judulController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                          hintText: 'Masukkan judul berita...',
                          hintStyle: GoogleFonts.poppins(
                            color: Colors.grey.shade500,
                          ),
                        ),
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 13 : 14,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Judul tidak boleh kosong';
                          }
                          if (value.length < 5) {
                            return 'Judul minimal 5 karakter';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 20 : 25),

                    // Konten
                    Text(
                      'Konten Berita *',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkNavy,
                        fontSize: isSmallScreen ? 14 : 15,
                      ),
                    ),
                    SizedBox(height: 8),
                    GlassContainer(
                      blur: 8,
                      opacity: 0.05,
                      child: TextFormField(
                        controller: _kontenController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                          hintText: 'Tulis konten berita di sini...',
                          hintStyle: GoogleFonts.poppins(
                            color: Colors.grey.shade500,
                          ),
                        ),
                        maxLines: 10,
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 13 : 14,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Konten tidak boleh kosong';
                          }
                          if (value.length < 20) {
                            return 'Konten minimal 20 karakter';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 20 : 25),

                    // Gambar Berita
                    Text(
                      'Gambar Berita',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkNavy,
                        fontSize: isSmallScreen ? 14 : 15,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Format: JPG, PNG, GIF, WebP (Maks. 2MB)',
                      style: GoogleFonts.poppins(
                        fontSize: isSmallScreen ? 11 : 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 8),

                    // Preview Gambar saat ini
                    if (_gambarFileName != null) ...[
                      Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            height: isSmallScreen ? 120 : 150,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.grey.shade100,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CachedNetworkImage(
                                imageUrl: '${AppConfig.baseUrl}/berita.php?download=true&file_name=$_gambarFileName',
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
                                    size: 40,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: CircleAvatar(
                              backgroundColor: Colors.red.withOpacity(0.9),
                              radius: isSmallScreen ? 14 : 16,
                              child: IconButton(
                                onPressed: _removeGambar,
                                icon: Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: isSmallScreen ? 14 : 16,
                                ),
                                padding: EdgeInsets.zero,
                                constraints: BoxConstraints(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Gambar saat ini',
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 11 : 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 12),
                    ],

                    // File Picker untuk ganti gambar
                    FilePickerWidget(
                      onFileSelected: (file) {
                        setState(() {
                          _gambarFile = file;
                        });
                      },
                      label: 'Ganti gambar berita',
                    ),
                    SizedBox(height: 12),

                    // Upload Button jika ada file baru yang dipilih
                    if (_gambarFile != null) ...[
                      ElevatedButton.icon(
                        onPressed: _isUploading ? null : _uploadGambar,
                        icon: _isUploading
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(Icons.cloud_upload_outlined),
                        label: Text(
                          _isUploading ? 'Mengupload...' : 'Upload Gambar Baru',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 16 : 20,
                            vertical: isSmallScreen ? 12 : 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                    ],
                    SizedBox(height: isSmallScreen ? 30 : 40),

                    // Action Buttons
                    Row(
                      children: [
                        // Cancel Button
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                vertical: isSmallScreen ? 14 : 16,
                              ),
                              side: BorderSide(color: Colors.grey),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Batal',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade600,
                                fontSize: isSmallScreen ? 14 : 15,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: isSmallScreen ? 12 : 16),

                        // Update Button
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _updateBerita,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                vertical: isSmallScreen ? 14 : 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: _isLoading
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    'Perbarui',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontSize: isSmallScreen ? 14 : 15,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isSmallScreen ? 20 : 25),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _judulController.dispose();
    _kontenController.dispose();
    super.dispose();
  }
}