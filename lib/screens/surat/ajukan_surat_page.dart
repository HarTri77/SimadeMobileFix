// lib/screens/surat/ajukan_surat_page.dart - UPDATED WITH FILE UPLOAD
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/app_config.dart';
import '../../services/surat_service.dart';
import '../../utils/app_colors.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/file_picker_widget.dart'; // ✅ IMPORT FILE PICKER WIDGET

class AjukanSuratPage extends StatefulWidget {
  const AjukanSuratPage({super.key});

  @override
  State<AjukanSuratPage> createState() => _AjukanSuratPageState();
}

class _AjukanSuratPageState extends State<AjukanSuratPage> {
  final _formKey = GlobalKey<FormState>();
  final _keperluanController = TextEditingController();

  String _selectedJenisSurat = '';
  PlatformFile? _filePendukung;
  bool _isLoading = false;
  bool _isSubmitting = false;

  // ✅ ENHANCEMENT: VALIDATE FORM BEFORE SUBMIT
  bool _validateForm() {
    if (_selectedJenisSurat.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pilih jenis surat terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    if (_keperluanController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Keperluan tidak boleh kosong'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    return true;
  }

  // ✅ ENHANCEMENT: AJUKAN SURAT DENGAN FILE
  Future<void> _ajukanSurat() async {
    if (!_validateForm()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Validasi file jika ada
      if (_filePendukung != null) {
        final validation = SuratService.validateFile(_filePendukung!);
        if (!validation['isValid']) {
          final errors = validation['errors'] as Map<String, String>;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errors.values.first),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
          return;
        }
      }

      await SuratService.ajukanSuratWithFile(
        jenisSurat: _selectedJenisSurat,
        keperluan: _keperluanController.text,
        filePendukung: _filePendukung,
      );

      // ✅ SUCCESS - Kembali ke halaman sebelumnya
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Surat berhasil diajukan!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context, true); // Return true untuk refresh data

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengajukan surat: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  // ✅ ENHANCEMENT: RESET FORM
  void _resetForm() {
    _formKey.currentState?.reset();
    _keperluanController.clear();
    setState(() {
      _selectedJenisSurat = '';
      _filePendukung = null;
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
          'Ajukan Surat Baru',
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
                    // ✅ HEADER SECTION
                    GlassContainer(
                      blur: 10,
                      opacity: 0.1,
                      child: Container(
                        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                        child: Row(
                          children: [
                            Icon(
                              Icons.description_outlined,
                              color: AppColors.primaryBlue,
                              size: isSmallScreen ? 24 : 28,
                            ),
                            SizedBox(width: isSmallScreen ? 12 : 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Form Pengajuan Surat',
                                    style: GoogleFonts.poppins(
                                      fontSize: isSmallScreen ? 16 : 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.darkNavy,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Isi form berikut untuk mengajukan surat baru',
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

                    // ✅ JENIS SURAT DROPDOWN
                    Text(
                      'Jenis Surat *',
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
                        value: _selectedJenisSurat.isEmpty ? null : _selectedJenisSurat,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 12 : 16,
                            vertical: isSmallScreen ? 14 : 16,
                          ),
                          hintText: 'Pilih Jenis Surat',
                          hintStyle: GoogleFonts.poppins(
                            color: Colors.grey.shade500,
                          ),
                        ),
                        items: AppConfig.jenisSuratList.map((jenis) {
                          return DropdownMenuItem(
                            value: jenis['value'],
                            child: Text(
                              jenis['label']!,
                              style: GoogleFonts.poppins(
                                fontSize: isSmallScreen ? 13 : 14,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedJenisSurat = value!;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Pilih jenis surat';
                          }
                          return null;
                        },
                        isExpanded: true,
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 20 : 25),

                    // ✅ KEPERLUAN TEXTFIELD
                    Text(
                      'Keperluan *',
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
                        controller: _keperluanController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                          hintText: 'Jelaskan keperluan pengajuan surat...',
                          hintStyle: GoogleFonts.poppins(
                            color: Colors.grey.shade500,
                          ),
                        ),
                        maxLines: 4,
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 13 : 14,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Keperluan tidak boleh kosong';
                          }
                          if (value.length < 10) {
                            return 'Keperluan minimal 10 karakter';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 20 : 25),

                    // ✅ FILE PENDUKUNG UPLOAD
                    Text(
                      'File Pendukung (Opsional)',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkNavy,
                        fontSize: isSmallScreen ? 14 : 15,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Format: PDF, JPG, PNG, DOC (Maks. 5MB)',
                      style: GoogleFonts.poppins(
                        fontSize: isSmallScreen ? 11 : 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 8),
                    FilePickerWidget(
                      onFileSelected: (file) {
                        setState(() {
                          _filePendukung = file;
                        });
                      },
                      label: 'Unggah file pendukung',
                    ),
                    SizedBox(height: isSmallScreen ? 30 : 40),

                    // ✅ ACTION BUTTONS
                    Row(
                      children: [
                        // RESET BUTTON
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isSubmitting ? null : _resetForm,
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

                        // SUBMIT BUTTON
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _ajukanSurat,
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
                            child: _isSubmitting
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    'Ajukan Surat',
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

                    // ✅ INFO FOOTER
                    GlassContainer(
                      blur: 5,
                      opacity: 0.05,
                      child: Container(
                        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: AppColors.primaryBlue,
                              size: isSmallScreen ? 16 : 18,
                            ),
                            SizedBox(width: isSmallScreen ? 8 : 12),
                            Expanded(
                              child: Text(
                                'Surat akan diproses dalam 1-3 hari kerja. Anda akan mendapatkan notifikasi ketika status berubah.',
                                style: GoogleFonts.poppins(
                                  fontSize: isSmallScreen ? 11 : 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _keperluanController.dispose();
    super.dispose();
  }
}