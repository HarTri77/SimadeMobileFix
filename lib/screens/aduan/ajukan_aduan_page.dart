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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat kategori: $e'),
          backgroundColor: Colors.red,
        ),
      );
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Aduan berhasil dikirim'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true); // Return success
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengirim aduan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
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
          'Ajukan Aduan',
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
      body: _isLoadingKategori
          ? Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
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
                              Icons.report_outlined,
                              color: AppColors.primaryBlue,
                              size: isSmallScreen ? 24 : 28,
                            ),
                            SizedBox(width: isSmallScreen ? 12 : 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Form Pengaduan',
                                    style: GoogleFonts.poppins(
                                      fontSize: isSmallScreen ? 16 : 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.darkNavy,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Sampaikan keluhan atau masalah Anda',
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

                    // Judul Aduan
                    Text(
                      'Judul Aduan *',
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
                          hintText: 'Contoh: Jalan Rusak di Depan Rumah',
                          hintStyle: GoogleFonts.poppins(
                            color: Colors.grey.shade500,
                          ),
                        ),
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 13 : 14,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Judul aduan tidak boleh kosong';
                          }
                          if (value.length < 5) {
                            return 'Judul minimal 5 karakter';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 20 : 25),

                    // Kategori Aduan
                    Text(
                      'Kategori Aduan',
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
                      child: DropdownButtonFormField<KategoriAduanModel>(
                        value: _selectedKategori,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                        ),
                        items: _kategoriList.map((kategori) {
                          return DropdownMenuItem<KategoriAduanModel>(
                            value: kategori,
                            child: Row(
                              children: [
                                Icon(
                                  kategori.iconData,
                                  color: kategori.color,
                                  size: isSmallScreen ? 16 : 18,
                                ),
                                SizedBox(width: 8),
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
                        onChanged: (kategori) {
                          setState(() {
                            _selectedKategori = kategori;
                          });
                        },
                        hint: Text(
                          'Pilih kategori aduan',
                          style: GoogleFonts.poppins(
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 20 : 25),

                    // Prioritas
                    Text(
                      'Prioritas',
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
                      child: DropdownButtonFormField<String>(
                        value: _selectedPrioritas,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'rendah',
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Rendah',
                                  style: GoogleFonts.poppins(),
                                ),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'sedang',
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: Colors.orange,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Sedang',
                                  style: GoogleFonts.poppins(),
                                ),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'tinggi',
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Tinggi',
                                  style: GoogleFonts.poppins(),
                                ),
                              ],
                            ),
                          ),
                        ],
                        onChanged: (prioritas) {
                          setState(() {
                            _selectedPrioritas = prioritas!;
                          });
                        },
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 20 : 25),

                    // Lokasi
                    Text(
                      'Lokasi (Opsional)',
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
                        controller: _lokasiController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                          hintText: 'Contoh: Jl. Merdeka No. 123, RT 01/RW 02',
                          hintStyle: GoogleFonts.poppins(
                            color: Colors.grey.shade500,
                          ),
                        ),
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 13 : 14,
                        ),
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 20 : 25),

                    // Isi Aduan
                    Text(
                      'Isi Aduan *',
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
                        controller: _isiAduanController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                          hintText: 'Jelaskan detail keluhan atau masalah Anda...',
                          hintStyle: GoogleFonts.poppins(
                            color: Colors.grey.shade500,
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
                    SizedBox(height: isSmallScreen ? 30 : 40),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: isSmallScreen ? 50 : 55,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitAduan,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
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
                                'Kirim Aduan',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: isSmallScreen ? 14 : 15,
                                ),
                              ),
                      ),
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
    _isiAduanController.dispose();
    _lokasiController.dispose();
    super.dispose();
  }
}