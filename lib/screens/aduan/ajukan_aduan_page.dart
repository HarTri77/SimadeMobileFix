// lib/screens/aduan/ajukan_aduan_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/aduan_service.dart';
import '../../utils/app_colors.dart';
import '../../widgets/glass_container.dart';
import '../../models/kategori_aduan_model.dart';

class AjukanAduanPage extends StatefulWidget {
  const AjukanAduanPage({super.key});

  @override
  State<AjukanAduanPage> createState() => _AjukanAduanPageState();
}

class _AjukanAduanPageState extends State<AjukanAduanPage> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _isiAduanController = TextEditingController();
  final _lokasiController = TextEditingController();

  List<KategoriAduanModel> _kategoriList = [];
  KategoriAduanModel? _selectedKategori;
  String _selectedPrioritas = 'rendah';
  bool _isLoading = false;
  bool _isLoadingKategori = true;

  @override
  void initState() {
    super.initState();
    _loadKategori();
  }

  Future<void> _loadKategori() async {
    try {
      final kategori = await AduanService.getKategoriAduan();
      setState(() {
        _kategoriList = kategori;
        _isLoadingKategori = false;
      });
    } catch (e) {
      setState(() => _isLoadingKategori = false);
      _showErrorSnackbar('Gagal memuat kategori: $e');
    }
  }

  Future<void> _submitAduan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await AduanService.createAduan(
        judul: _judulController.text,
        isiAduan: _isiAduanController.text,
        kategori: _selectedKategori?.id,
        prioritas: _selectedPrioritas,
        lokasi: _lokasiController.text.isEmpty ? null : _lokasiController.text,
      );

      _showSuccessSnackbar('Aduan berhasil dikirim');
      Navigator.pop(context, true);
    } catch (e) {
      _showErrorSnackbar('Gagal mengirim aduan: $e');
    } finally {
      setState(() => _isLoading = false);
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

  Color _getPrioritasColor(String prioritas) {
    switch (prioritas) {
      case 'rendah':
        return const Color(0xFF00D2D3);
      case 'sedang':
        return const Color(0xFFFFA502);
      case 'tinggi':
        return const Color(0xFFFF6B6B);
      default:
        return const Color(0xFF00D2D3);
    }
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
          'Ajukan Aduan',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2D3436),
          ),
        ),
      ),
      body: _isLoadingKategori
          ? Center(
              child: CircularProgressIndicator(
                color: const Color(0xFF00D2D3),
                strokeWidth: 2,
              ),
            )
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
                    _buildSubmitButton(isSmallScreen),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeaderCard(bool isSmallScreen) {
    return Container(
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
              Icons.report_problem_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Form Pengaduan',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: isSmallScreen ? 18 : 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sampaikan keluhan atau masalah Anda dengan jelas dan lengkap',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: isSmallScreen ? 12 : 13,
              color: Colors.white.withOpacity(0.9),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(bool isSmallScreen) {
    return Container(
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
          _buildSectionTitle('Data Aduan'),
          const SizedBox(height: 20),
          _buildInputField(
            label: 'Judul Aduan *',
            hintText: 'Contoh: Jalan Rusak di Depan Rumah',
            controller: _judulController,
            icon: Icons.title_rounded,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Judul aduan tidak boleh kosong';
              }
              if (value.length < 5) {
                return 'Judul minimal 5 karakter';
              }
              return null;
            },
            isSmallScreen: isSmallScreen,
          ),
          const SizedBox(height: 20),
          _buildDropdownField(
            label: 'Kategori Aduan',
            value: _selectedKategori,
            items: _kategoriList,
            hint: 'Pilih kategori aduan',
            onChanged: (kategori) {
              setState(() {
                _selectedKategori = kategori;
              });
            },
            isSmallScreen: isSmallScreen,
          ),
          const SizedBox(height: 20),
          _buildPrioritasField(isSmallScreen),
          const SizedBox(height: 20),
          _buildInputField(
            label: 'Lokasi (Opsional)',
            hintText: 'Contoh: Jl. Merdeka No. 123, RT 01/RW 02',
            controller: _lokasiController,
            icon: Icons.location_on_rounded,
            isSmallScreen: isSmallScreen,
          ),
          const SizedBox(height: 20),
          _buildIsiAduanField(isSmallScreen),
        ],
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
                color: Colors.grey.shade500,
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
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required KategoriAduanModel? value,
    required List<KategoriAduanModel> items,
    required String hint,
    required Function(KategoriAduanModel?) onChanged,
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
          child: DropdownButtonFormField<KategoriAduanModel>(
            value: value,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(isSmallScreen ? 12 : 16),
              prefixIcon: Icon(
                Icons.category_rounded,
                color: const Color(0xFF00D2D3),
                size: isSmallScreen ? 18 : 20,
              ),
            ),
            items: items.map((kategori) {
              return DropdownMenuItem<KategoriAduanModel>(
                value: kategori,
                child: Row(
                  children: [
                    Icon(
                      kategori.iconData,
                      color: kategori.color,
                      size: isSmallScreen ? 16 : 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      kategori.namaKategori,
                      style: GoogleFonts.poppins(
                        fontSize: isSmallScreen ? 13 : 14,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: onChanged,
            hint: Text(
              hint,
              style: GoogleFonts.poppins(
                color: Colors.grey.shade500,
                fontSize: isSmallScreen ? 13 : 14,
              ),
            ),
            style: GoogleFonts.poppins(
              fontSize: isSmallScreen ? 13 : 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrioritasField(bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Prioritas',
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
          child: DropdownButtonFormField<String>(
            value: _selectedPrioritas,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(isSmallScreen ? 12 : 16),
              prefixIcon: Icon(
                Icons.priority_high_rounded,
                color: _getPrioritasColor(_selectedPrioritas),
                size: isSmallScreen ? 18 : 20,
              ),
            ),
            items: [
              _buildPrioritasItem('rendah', 'Rendah', const Color(0xFF00D2D3), isSmallScreen),
              _buildPrioritasItem('sedang', 'Sedang', const Color(0xFFFFA502), isSmallScreen),
              _buildPrioritasItem('tinggi', 'Tinggi', const Color(0xFFFF6B6B), isSmallScreen),
            ],
            onChanged: (prioritas) {
              setState(() {
                _selectedPrioritas = prioritas!;
              });
            },
            style: GoogleFonts.poppins(
              fontSize: isSmallScreen ? 13 : 14,
            ),
          ),
        ),
      ],
    );
  }

  DropdownMenuItem<String> _buildPrioritasItem(
      String value, String text, Color color, bool isSmallScreen) {
    return DropdownMenuItem(
      value: value,
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: isSmallScreen ? 13 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIsiAduanField(bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Isi Aduan *',
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
            controller: _isiAduanController,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(isSmallScreen ? 12 : 16),
              hintText: 'Jelaskan detail keluhan atau masalah Anda...',
              hintStyle: GoogleFonts.poppins(
                color: Colors.grey.shade500,
                fontSize: isSmallScreen ? 13 : 14,
              ),
              prefixIcon: Icon(
                Icons.description_rounded,
                color: const Color(0xFF00D2D3),
                size: isSmallScreen ? 18 : 20,
              ),
            ),
            maxLines: 6,
            style: GoogleFonts.poppins(
              fontSize: isSmallScreen ? 13 : 14,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Isi aduan tidak boleh kosong';
              }
              if (value.length < 20) {
                return 'Isi aduan minimal 20 karakter';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(bool isSmallScreen) {
    return SizedBox(
      width: double.infinity,
      height: isSmallScreen ? 50 : 55,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitAduan,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00D2D3),
          foregroundColor: Colors.white,
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
                  const Icon(Icons.send_rounded, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Kirim Aduan',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: isSmallScreen ? 14 : 15,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  @override
  void dispose() {
    _judulController.dispose();
    _isiAduanController.dispose();
    _lokasiController.dispose();
    super.dispose();
  }
}