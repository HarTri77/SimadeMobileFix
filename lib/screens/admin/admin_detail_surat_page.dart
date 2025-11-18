// lib/screens/admin/admin_detail_surat_page.dart - UPDATED WITH FILE UPLOAD
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/surat_model.dart';
import '../../services/surat_service.dart';
import '../../utils/app_colors.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/file_picker_widget.dart';
import '../../widgets/file_download_widget.dart';

class AdminDetailSuratPage extends StatefulWidget {
  final int suratId;

  const AdminDetailSuratPage({super.key, required this.suratId});

  @override
  State<AdminDetailSuratPage> createState() => _AdminDetailSuratPageState();
}

class _AdminDetailSuratPageState extends State<AdminDetailSuratPage> {
  SuratModel? _surat;
  bool _isLoading = true;
  bool _isUpdating = false;

  // ✅ ENHANCEMENT: FORM STATE FOR ADMIN
  PlatformFile? _fileHasil;
  final _catatanController = TextEditingController();
  String _selectedStatus = 'pending';

  @override
  void initState() {
    super.initState();
    _loadDetailSurat();
  }

  Future<void> _loadDetailSurat() async {
    try {
      final surat = await SuratService.getDetailSurat(widget.suratId);
      setState(() {
        _surat = surat;
        _selectedStatus = surat.status;
        _catatanController.text = surat.catatanAdmin ?? '';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat detail surat: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // ✅ ENHANCEMENT: UPDATE STATUS DENGAN FILE HASIL
  Future<void> _updateStatus() async {
    if (_catatanController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Catatan admin tidak boleh kosong'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    try {
      // Validasi file hasil jika ada
      if (_fileHasil != null) {
        final validation = SuratService.validateFile(_fileHasil!);
        if (!validation['isValid']) {
          final errors = validation['errors'] as Map<String, String>;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errors.values.first),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

      await SuratService.updateStatusWithFile(
        suratId: widget.suratId,
        status: _selectedStatus,
        catatanAdmin: _catatanController.text,
        fileHasil: _fileHasil,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status surat berhasil diupdate'),
          backgroundColor: Colors.green,
        ),
      );

      // Reload data
      await _loadDetailSurat();
      
      // Reset file hasil setelah upload
      setState(() {
        _fileHasil = null;
      });

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal update status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  // ✅ ENHANCEMENT: DOWNLOAD FILE
  Future<void> _downloadFile(String? fileUrl) async {
    if (fileUrl == null) return;
    
    try {
      if (await canLaunchUrl(Uri.parse(fileUrl))) {
        await launchUrl(Uri.parse(fileUrl));
      } else {
        throw 'Tidak dapat membuka file';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membuka file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ✅ ENHANCEMENT: STATUS COLOR
  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'diproses': return Colors.blue;
      case 'selesai': return Colors.green;
      case 'ditolak': return Colors.red;
      default: return Colors.grey;
    }
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
            'Detail Surat',
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

    if (_surat == null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          title: Text('Detail Surat'),
        ),
        body: Center(
          child: Text(
            'Surat tidak ditemukan',
            style: GoogleFonts.poppins(),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
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
          icon: Icon(Icons.arrow_back, color: AppColors.darkNavy),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ SURAT INFO CARD
            GlassContainer(
              blur: 10,
              opacity: 0.1,
              child: Container(
                padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Jenis Surat',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkNavy,
                            fontSize: isSmallScreen ? 14 : 15,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 8 : 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(_surat!.status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _getStatusColor(_surat!.status),
                            ),
                          ),
                          child: Text(
                            _surat!.statusText.toUpperCase(),
                            style: GoogleFonts.poppins(
                              fontSize: isSmallScreen ? 10 : 11,
                              fontWeight: FontWeight.bold,
                              color: _getStatusColor(_surat!.status),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      _surat!.jenisSurat,
                      style: GoogleFonts.poppins(
                        fontSize: isSmallScreen ? 16 : 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    Text(
                      'Keperluan',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkNavy,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      _surat!.keperluan,
                      style: GoogleFonts.poppins(
                        color: Colors.grey.shade700,
                      ),
                    ),
                    SizedBox(height: 12),
                    
                    Text(
                      'Tanggal Pengajuan',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkNavy,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${_surat!.tanggalPengajuan.day}/${_surat!.tanggalPengajuan.month}/${_surat!.tanggalPengajuan.year}',
                      style: GoogleFonts.poppins(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: isSmallScreen ? 20 : 25),

            // ✅ FILE PENDUKUNG SECTION
            if (_surat!.hasFilePendukung) ...[
              Text(
                'File Pendukung',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkNavy,
                  fontSize: isSmallScreen ? 16 : 18,
                ),
              ),
              SizedBox(height: 8),
              FileDownloadWidget(
                fileName: _surat!.filePendukung!,
                fileType: 'pendukung',
                label: 'File Pendukung - ${_surat!.filePendukungType}',
              ),
              SizedBox(height: isSmallScreen ? 20 : 25),
            ],

            // ✅ ADMIN ACTION SECTION
            Text(
              'Update Status Surat',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: AppColors.darkNavy,
                fontSize: isSmallScreen ? 16 : 18,
              ),
            ),
            SizedBox(height: 12),

            // STATUS DROPDOWN
            GlassContainer(
              blur: 8,
              opacity: 0.05,
              child: DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 12 : 16,
                    vertical: isSmallScreen ? 14 : 16,
                  ),
                  labelText: 'Status Surat',
                  labelStyle: GoogleFonts.poppins(
                    color: AppColors.darkNavy,
                  ),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'pending',
                    child: Text('Menunggu', style: GoogleFonts.poppins()),
                  ),
                  DropdownMenuItem(
                    value: 'diproses',
                    child: Text('Diproses', style: GoogleFonts.poppins()),
                  ),
                  DropdownMenuItem(
                    value: 'selesai',
                    child: Text('Selesai', style: GoogleFonts.poppins()),
                  ),
                  DropdownMenuItem(
                    value: 'ditolak',
                    child: Text('Ditolak', style: GoogleFonts.poppins()),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value!;
                  });
                },
              ),
            ),
            SizedBox(height: isSmallScreen ? 16 : 20),

            // CATATAN ADMIN
            Text(
              'Catatan Admin *',
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
                controller: _catatanController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                  hintText: 'Berikan catatan untuk pemohon...',
                  hintStyle: GoogleFonts.poppins(
                    color: Colors.grey.shade500,
                  ),
                ),
                maxLines: 3,
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 13 : 14,
                ),
              ),
            ),
            SizedBox(height: isSmallScreen ? 20 : 25),

            // ✅ FILE HASIL UPLOAD (Hanya untuk status selesai)
            if (_selectedStatus == 'selesai') ...[
              Text(
                'File Hasil (Opsional)',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkNavy,
                  fontSize: isSmallScreen ? 14 : 15,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Upload surat hasil yang sudah ditandatangani',
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 11 : 12,
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: 8),
              FilePickerWidget(
                onFileSelected: (file) {
                  setState(() {
                    _fileHasil = file;
                  });
                },
                label: 'Unggah file hasil',
              ),
              SizedBox(height: isSmallScreen ? 20 : 25),
            ],

            // ✅ UPDATE BUTTON
            ElevatedButton(
              onPressed: _isUpdating ? null : _updateStatus,
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
              child: _isUpdating
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Update Status',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: isSmallScreen ? 14 : 15,
                      ),
                    ),
            ),
            SizedBox(height: isSmallScreen ? 20 : 25),

            // ✅ FILE HASIL SECTION (Jika sudah ada)
            if (_surat!.hasFileHasil) ...[
              Text(
                'File Hasil',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkNavy,
                  fontSize: isSmallScreen ? 16 : 18,
                ),
              ),
              SizedBox(height: 8),
              FileDownloadWidget(
                fileName: _surat!.fileHasil!,
                fileType: 'hasil',
                label: 'File Hasil - ${_surat!.fileHasilType}',
              ),
              SizedBox(height: isSmallScreen ? 20 : 25),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _catatanController.dispose();
    super.dispose();
  }
}