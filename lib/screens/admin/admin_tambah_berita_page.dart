// lib/screens/admin/admin_tambah_berita_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../services/berita_service.dart';
import '../../services/file_service.dart';
import '../../utils/app_colors.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/file_picker_widget.dart';
import '../../config/app_config.dart';

class AdminTambahBeritaPage extends StatefulWidget {
  const AdminTambahBeritaPage({super.key});

  @override
  State<AdminTambahBeritaPage> createState() => _AdminTambahBeritaPageState();
}

class _AdminTambahBeritaPageState extends State<AdminTambahBeritaPage> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _kontenController = TextEditingController();

  PlatformFile? _gambarFile;
  String? _gambarFileName;
  bool _isLoading = false;
  bool _isUploading = false;

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

  Future<void> _tambahBerita() async {
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
      await BeritaService.createBerita(
        judul: _judulController.text,
        konten: _kontenController.text,
        gambar: _gambarFileName,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Berita berhasil ditambahkan'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true); // Return success
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menambah berita: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _judulController.clear();
    _kontenController.clear();
    setState(() {
      _gambarFile = null;
      _gambarFileName = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Tambah Berita Baru',
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
                              Icons.article_outlined,
                              color: AppColors.primaryBlue,
                              size: isSmallScreen ? 24 : 28,
                            ),
                            SizedBox(width: isSmallScreen ? 12 : 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Form Tambah Berita',
                                    style: GoogleFonts.poppins(
                                      fontSize: isSmallScreen ? 16 : 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.darkNavy,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Buat berita baru untuk warga',
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
                      'Gambar Berita (Opsional)',
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

                    // Preview Gambar jika sudah diupload
                    if (_gambarFileName != null) ...[
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
                      SizedBox(height: 12),
                      Text(
                        'Gambar berhasil diupload: $_gambarFileName',
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 11 : 12,
                          color: Colors.green,
                        ),
                      ),
                      SizedBox(height: 12),
                    ],

                    // File Picker
                    FilePickerWidget(
                      onFileSelected: (file) {
                        setState(() {
                          _gambarFile = file;
                          _gambarFileName = null; // Reset uploaded filename
                        });
                      },
                      label: 'Pilih gambar berita',
                    ),
                    SizedBox(height: 12),

                    // Upload Button jika ada file yang dipilih
                    if (_gambarFile != null && _gambarFileName == null) ...[
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
                          _isUploading ? 'Mengupload...' : 'Upload Gambar',
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
                        // Reset Button
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _resetForm,
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                vertical: isSmallScreen ? 14 : 16,
                              ),
                              side: BorderSide(color: AppColors.primaryBlue),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Reset',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryBlue,
                                fontSize: isSmallScreen ? 14 : 15,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: isSmallScreen ? 12 : 16),

                        // Submit Button
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _tambahBerita,
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
                                    'Tambah Berita',
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