// lib/screens/admin/admin_tambah_berita_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../services/berita_service.dart';
import '../../utils/app_colors.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/file_picker_widget.dart';
import '../../config/app_config.dart';

class AdminTambahBeritaPage extends StatefulWidget {
  const AdminTambahBeritaPage({super.key});

  @override
  State<AdminTambahBeritaPage> createState() => _AdminTambahBeritaPageState();
}

class _AdminTambahBeritaPageState extends State<AdminTambahBeritaPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _kontenController = TextEditingController();

  PlatformFile? _gambarFile;
  String? _gambarFileName;
  bool _isLoading = false;
  bool _isUploading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _judulController.dispose();
    _kontenController.dispose();
    super.dispose();
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

      _showSuccessSnackbar('Gambar berhasil diupload');
    } catch (e) {
      _showErrorSnackbar('Gagal upload gambar: $e');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _tambahBerita() async {
    if (!_formKey.currentState!.validate()) return;

    if (_gambarFile != null && _gambarFileName == null) {
      _showWarningSnackbar('Silakan upload gambar terlebih dahulu');
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

      _showSuccessSnackbar('Berita berhasil ditambahkan');
      Navigator.pop(context, true);
    } catch (e) {
      _showErrorSnackbar('Gagal menambah berita: $e');
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
    _showSuccessSnackbar('Form telah direset');
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: const Color(0xFF00D2D3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: const Color(0xFFFF6B6B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showWarningSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.warning_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: const Color(0xFFFFA502),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildHeaderCard(bool isSmallScreen) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF00D2D3), Color(0xFF26A69A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00D2D3).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.article_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Tambah Berita Baru',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: isSmallScreen ? 18 : 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bagikan informasi terbaru untuk warga',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: isSmallScreen ? 12 : 13,
                color: Colors.white.withOpacity(0.9),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormCard(bool isSmallScreen) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _fadeAnimation,
        child: Container(
          padding: const EdgeInsets.all(20),
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
              _buildSectionTitle('Informasi Berita'),
              const SizedBox(height: 20),
              _buildInputField(
                label: 'Judul Berita *',
                hintText: 'Masukkan judul berita yang menarik...',
                controller: _judulController,
                icon: Icons.title_rounded,
                maxLines: 1,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Judul tidak boleh kosong';
                  }
                  if (value.length < 5) {
                    return 'Judul minimal 5 karakter';
                  }
                  return null;
                },
                isSmallScreen: isSmallScreen,
              ),
              const SizedBox(height: 20),
              _buildKontenField(isSmallScreen),
              const SizedBox(height: 20),
              _buildGambarSection(isSmallScreen),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
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
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2D3436),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
    required bool isSmallScreen,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2D3436),
            fontSize: isSmallScreen ? 14 : 15,
          ),
        ),
        const SizedBox(height: 8),
        GlassContainer(
          blur: 8,
          opacity: 0.05,
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(isSmallScreen ? 12 : 16),
              hintText: hintText,
              hintStyle: GoogleFonts.poppins(
                color: const Color(0xFF636E72),
                fontSize: isSmallScreen ? 13 : 14,
              ),
              prefixIcon: Icon(
                icon,
                color: const Color(0xFF00D2D3),
                size: isSmallScreen ? 18 : 20,
              ),
            ),
            style: GoogleFonts.poppins(
              fontSize: isSmallScreen ? 13 : 14,
              color: const Color(0xFF2D3436),
            ),
            maxLines: maxLines,
            validator: validator,
          ),
        ),
      ],
    );
  }

  Widget _buildKontenField(bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Konten Berita *',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2D3436),
            fontSize: isSmallScreen ? 14 : 15,
          ),
        ),
        const SizedBox(height: 8),
        GlassContainer(
          blur: 8,
          opacity: 0.05,
          child: TextFormField(
            controller: _kontenController,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(isSmallScreen ? 12 : 16),
              hintText: 'Tulis konten berita yang informatif dan menarik...',
              hintStyle: GoogleFonts.poppins(
                color: const Color(0xFF636E72),
                fontSize: isSmallScreen ? 13 : 14,
              ),
              prefixIcon: Icon(
                Icons.description_rounded,
                color: const Color(0xFF00D2D3),
                size: isSmallScreen ? 18 : 20,
              ),
            ),
            maxLines: 8,
            minLines: 4,
            style: GoogleFonts.poppins(
              fontSize: isSmallScreen ? 13 : 14,
              color: const Color(0xFF2D3436),
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
      ],
    );
  }

  Widget _buildGambarSection(bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gambar Berita',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2D3436),
            fontSize: isSmallScreen ? 14 : 15,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Format: JPG, PNG, GIF, WebP • Maks. 2MB',
          style: GoogleFonts.poppins(
            fontSize: isSmallScreen ? 11 : 12,
            color: const Color(0xFF636E72),
          ),
        ),
        const SizedBox(height: 12),

        // Preview Gambar jika sudah diupload
        if (_gambarFileName != null) 
          _buildGambarPreview(isSmallScreen),

        // File Picker
        FilePickerWidget(
          onFileSelected: (file) {
            setState(() {
              _gambarFile = file;
              _gambarFileName = null;
            });
          },
          label: 'Pilih gambar berita',
        ),
        const SizedBox(height: 12),

        // Upload Button jika ada file yang dipilih
        if (_gambarFile != null && _gambarFileName == null) 
          _buildUploadButton(isSmallScreen),
      ],
    );
  }

  Widget _buildGambarPreview(bool isSmallScreen) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: isSmallScreen ? 140 : 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: const Color(0xFF00D2D3).withOpacity(0.1),
            border: Border.all(
              color: const Color(0xFF00D2D3).withOpacity(0.3),
              width: 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: '${AppConfig.baseUrl}/berita.php?download=true&file_name=$_gambarFileName',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (context, url) => Container(
                    color: const Color(0xFF00D2D3).withOpacity(0.1),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: const Color(0xFF00D2D3),
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
                          Icons.image_not_supported_rounded,
                          color: Colors.grey.shade400,
                          size: 40,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Gagal memuat gambar',
                          style: GoogleFonts.poppins(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: const Color(0xFF00D2D3),
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF00D2D3).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF00D2D3).withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: const Color(0xFF00D2D3),
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Gambar berhasil diupload: $_gambarFileName',
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 11 : 12,
                    color: const Color(0xFF00D2D3),
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildUploadButton(bool isSmallScreen) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isUploading ? null : _uploadGambar,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00D2D3),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 16 : 20,
            vertical: isSmallScreen ? 14 : 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          shadowColor: const Color(0xFF00D2D3).withOpacity(0.3),
        ),
        icon: _isUploading
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.cloud_upload_rounded, size: 20),
        label: Text(
          _isUploading ? 'Mengupload...' : 'Upload Gambar',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: isSmallScreen ? 14 : 15,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(bool isSmallScreen) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Row(
        children: [
          // Reset Button
          Expanded(
            child: OutlinedButton(
              onPressed: _resetForm,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 14 : 16),
                side: const BorderSide(color: Color(0xFF00D2D3), width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                backgroundColor: Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.refresh_rounded, color: Color(0xFF00D2D3), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Reset Form',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF00D2D3),
                      fontSize: isSmallScreen ? 14 : 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: isSmallScreen ? 12 : 16),

          // Submit Button
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading ? null : _tambahBerita,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D2D3),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 14 : 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                shadowColor: const Color(0xFF00D2D3).withOpacity(0.3),
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
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_rounded, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Tambah Berita',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: isSmallScreen ? 14 : 15,
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

  Widget _buildLoadingState(bool isSmallScreen) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: isSmallScreen ? 50 : 60,
            height: isSmallScreen ? 50 : 60,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: const Color(0xFF00D2D3),
              backgroundColor: const Color(0xFF00D2D3).withOpacity(0.1),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Menambah Berita...',
            style: GoogleFonts.poppins(
              fontSize: isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2D3436),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Mohon tunggu sebentar',
            style: GoogleFonts.poppins(
              color: const Color(0xFF636E72),
              fontSize: isSmallScreen ? 13 : 14,
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
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Color(0xFF2D3436)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Tambah Berita Baru',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2D3436),
          ),
        ),
      ),
      body: _isLoading
          ? _buildLoadingState(isSmallScreen)
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildHeaderCard(isSmallScreen),
                    const SizedBox(height: 20),
                    _buildFormCard(isSmallScreen),
                    const SizedBox(height: 20),
                    _buildActionButtons(isSmallScreen),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }
}