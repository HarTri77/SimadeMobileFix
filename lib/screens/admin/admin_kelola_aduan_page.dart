// lib/screens/aduan/admin/admin_kelola_aduan_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../services/aduan_service.dart';
import '../../../utils/app_colors.dart';
import '../../../widgets/glass_container.dart';
import '../../../models/aduan_model.dart';
import '../aduan/detail_aduan_page.dart';

class AdminKelolaAduanPage extends StatefulWidget {
  const AdminKelolaAduanPage({super.key});

  @override
  State<AdminKelolaAduanPage> createState() => _AdminKelolaAduanPageState();
}

class _AdminKelolaAduanPageState extends State<AdminKelolaAduanPage> with SingleTickerProviderStateMixin {
  List<AduanModel> _aduanList = [];
  List<AduanModel> _filteredAduanList = [];
  bool _isLoading = true;
  bool _isError = false;
  bool _isRefreshing = false;
  
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'semua';
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
    _loadAduan().then((_) {
      _animationController.forward();
    });
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _applyFilter();
  }

  void _applyFilter() {
    String searchQuery = _searchController.text.toLowerCase();
    
    setState(() {
      if (searchQuery.isEmpty && _selectedStatus == 'semua') {
        _filteredAduanList = _aduanList;
      } else {
        _filteredAduanList = _aduanList.where((aduan) {
          final matchesSearch = searchQuery.isEmpty || 
              aduan.judul.toLowerCase().contains(searchQuery) ||
              aduan.isiAduan.toLowerCase().contains(searchQuery) ||
              aduan.userNama.toLowerCase().contains(searchQuery);
          
          final matchesStatus = _selectedStatus == 'semua' || 
              aduan.status == _selectedStatus;
          
          return matchesSearch && matchesStatus;
        }).toList();
      }
    });
  }

  Future<void> _loadAduan() async {
    setState(() {
      _isLoading = true;
      _isError = false;
    });

    try {
      final aduan = await AduanService.getAduan();
      setState(() {
        _aduanList = aduan;
        _filteredAduanList = aduan;
      });
    } catch (e) {
      setState(() => _isError = true);
      _showErrorSnackbar('Gagal memuat aduan: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshData() async {
    setState(() => _isRefreshing = true);
    await _loadAduan();
    setState(() => _isRefreshing = false);
  }

  Future<void> _updateStatusAduan(int aduanId, String status, String? tanggapan) async {
    try {
      await AduanService.updateAduan(
        id: aduanId,
        status: status,
        tanggapan: tanggapan,
      );
      
      _showSuccessSnackbar('Status aduan berhasil diupdate');
      _loadAduan();
    } catch (e) {
      _showErrorSnackbar('Gagal mengupdate status: $e');
    }
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
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
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFFFF6B6B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showUpdateStatusDialog(AduanModel aduan) {
    String selectedStatus = aduan.status;
    TextEditingController tanggapanController = TextEditingController(text: aduan.tanggapan ?? '');

    showDialog(
      context: context,
      builder: (context) {
        final screenHeight = MediaQuery.of(context).size.height;
        final isSmallScreen = screenHeight < 600;
        
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          insetPadding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 16 : 24,
            vertical: isSmallScreen ? 16 : 24,
          ),
          child: Container(
            constraints: BoxConstraints(maxHeight: screenHeight * 0.85),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00D2D3), Color(0xFF26A69A)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.edit_rounded,
                          color: Colors.white,
                          size: isSmallScreen ? 20 : 24,
                        ),
                      ),
                      SizedBox(width: isSmallScreen ? 12 : 16),
                      Expanded(
                        child: Text(
                          'Update Status Aduan',
                          style: GoogleFonts.poppins(
                            fontSize: isSmallScreen ? 16 : 18,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2D3436),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Scrollable Content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 20 : 24,
                      vertical: isSmallScreen ? 16 : 20,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Current Status
                        _buildInfoCard(
                          icon: Icons.info_outline_rounded,
                          title: 'Status Saat Ini',
                          value: aduan.statusText,
                          color: const Color(0xFF00D2D3),
                          isSmallScreen: isSmallScreen,
                        ),
                        SizedBox(height: isSmallScreen ? 16 : 20),

                        // New Status
                        Text(
                          'Status Baru',
                          style: GoogleFonts.poppins(
                            fontSize: isSmallScreen ? 14 : 15,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2D3436),
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 8 : 12),
                        GlassContainer(
                          blur: 8,
                          opacity: 0.05,
                          child: DropdownButtonFormField<String>(
                            value: selectedStatus,
                            isExpanded: true,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: isSmallScreen ? 12 : 16,
                                vertical: isSmallScreen ? 12 : 14,
                              ),
                              prefixIcon: Icon(
                                Icons.flag_rounded,
                                color: const Color(0xFF00D2D3),
                              ),
                            ),
                            items: [
                              _buildStatusDropdownItem('diterima', '📥 Diterima', 'Aduan telah diterima'),
                              _buildStatusDropdownItem('diproses', '⚙️ Diproses', 'Sedang dalam proses'),
                              _buildStatusDropdownItem('selesai', '✅ Selesai', 'Aduan telah selesai'),
                              _buildStatusDropdownItem('ditolak', '❌ Ditolak', 'Aduan ditolak'),
                            ],
                            onChanged: (value) => selectedStatus = value!,
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF2D3436),
                              fontSize: isSmallScreen ? 13 : 14,
                            ),
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 16 : 20),

                        // Response
                        Text(
                          'Tanggapan (Opsional)',
                          style: GoogleFonts.poppins(
                            fontSize: isSmallScreen ? 14 : 15,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2D3436),
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 8 : 12),
                        GlassContainer(
                          blur: 8,
                          opacity: 0.05,
                          child: TextField(
                            controller: tanggapanController,
                            maxLines: 4,
                            minLines: 3,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                              hintText: 'Berikan tanggapan atau keterangan...',
                              hintStyle: GoogleFonts.poppins(
                                color: const Color(0xFF636E72),
                                fontSize: isSmallScreen ? 13 : 14,
                              ),
                              alignLabelWithHint: true,
                            ),
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 20 : 24),
                      ],
                    ),
                  ),
                ),
                
                // Action Buttons
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF2D3436),
                            side: const BorderSide(color: Color(0xFFDFE6E9)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 12 : 14),
                          ),
                          child: Text(
                            'Batal',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: isSmallScreen ? 14 : 15,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: isSmallScreen ? 12 : 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _updateStatusAduan(
                              aduan.id, 
                              selectedStatus, 
                              tanggapanController.text.isEmpty ? null : tanggapanController.text
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00D2D3),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 12 : 14),
                            elevation: 2,
                            shadowColor: const Color(0xFF00D2D3).withOpacity(0.3),
                          ),
                          child: Text(
                            'Simpan',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                              fontSize: isSmallScreen ? 14 : 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required bool isSmallScreen,
  }) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: isSmallScreen ? 18 : 20),
          SizedBox(width: isSmallScreen ? 10 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 11 : 12,
                    color: const Color(0xFF636E72),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 13 : 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D3436),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  DropdownMenuItem<String> _buildStatusDropdownItem(String value, String text, String hint) {
    return DropdownMenuItem(
      value: value,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text, style: GoogleFonts.poppins(fontSize: 14)),
          SizedBox(height: 2),
          Text(
            hint,
            style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF636E72)),
          ),
        ],
      ),
    );
  }

  Widget _buildAduanCard(AduanModel aduan, bool isSmallScreen) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _fadeAnimation,
        child: Container(
          margin: EdgeInsets.only(bottom: isSmallScreen ? 12 : 16),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DetailAduanPage(aduanId: aduan.id)),
                );
              },
              child: GlassContainer(
                blur: 15,
                opacity: 0.08,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header dengan status dan prioritas
                      Row(
                        children: [
                          // Status Badge
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 10 : 12,
                              vertical: isSmallScreen ? 6 : 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  aduan.statusColor,
                                  aduan.statusColor.withOpacity(0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getStatusIcon(aduan.status),
                                  color: Colors.white,
                                  size: isSmallScreen ? 12 : 14,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  aduan.statusText,
                                  style: GoogleFonts.poppins(
                                    fontSize: isSmallScreen ? 10 : 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 8),
                          
                          // Prioritas Badge
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 10 : 12,
                              vertical: isSmallScreen ? 6 : 8,
                            ),
                            decoration: BoxDecoration(
                              color: aduan.prioritasColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: aduan.prioritasColor, width: 1.5),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.flag_rounded,
                                  size: isSmallScreen ? 12 : 14,
                                  color: aduan.prioritasColor,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  aduan.prioritasText,
                                  style: GoogleFonts.poppins(
                                    fontSize: isSmallScreen ? 10 : 11,
                                    fontWeight: FontWeight.w600,
                                    color: aduan.prioritasColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          
                          // Tanggal
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F7FA),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              aduan.formattedCreatedAt,
                              style: GoogleFonts.poppins(
                                fontSize: isSmallScreen ? 10 : 11,
                                color: const Color(0xFF636E72),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isSmallScreen ? 12 : 16),

                      // Judul
                      Text(
                        aduan.judul,
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2D3436),
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: isSmallScreen ? 8 : 12),

                      // Preview isi aduan
                      Text(
                        aduan.isiAduan.length > 120 
                            ? '${aduan.isiAduan.substring(0, 120)}...' 
                            : aduan.isiAduan,
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 13 : 14,
                          color: const Color(0xFF636E72),
                          height: 1.5,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: isSmallScreen ? 12 : 16),

                      // Footer Info
                      _buildFooterInfo(aduan, isSmallScreen),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooterInfo(AduanModel aduan, bool isSmallScreen) {
    return Row(
      children: [
        // User Info
        Expanded(
          child: Wrap(
            spacing: isSmallScreen ? 8 : 12,
            runSpacing: 8,
            children: [
              _buildFooterItem(
                Icons.person_rounded,
                aduan.userNama,
                isSmallScreen,
              ),
              if (aduan.namaKategori != null)
                _buildFooterItem(
                  Icons.category_rounded,
                  aduan.namaKategori!,
                  isSmallScreen,
                ),
            ],
          ),
        ),
        
        SizedBox(width: 8),
        
        // Action Buttons
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF5F7FA),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Detail Button
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DetailAduanPage(aduanId: aduan.id)),
                  );
                },
                icon: Icon(
                  Icons.visibility_rounded,
                  size: isSmallScreen ? 18 : 20,
                  color: const Color(0xFF00D2D3),
                ),
                padding: EdgeInsets.all(6),
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
              Container(width: 1, height: 20, color: Colors.grey.shade300),
              // Edit Status Button
              IconButton(
                onPressed: () => _showUpdateStatusDialog(aduan),
                icon: Icon(
                  Icons.edit_rounded,
                  size: isSmallScreen ? 18 : 20,
                  color: const Color(0xFFFFA502),
                ),
                padding: EdgeInsets.all(6),
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooterItem(IconData icon, String text, bool isSmallScreen) {
    return Container(
      constraints: BoxConstraints(maxWidth: isSmallScreen ? 100 : 120),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isSmallScreen ? 14 : 16, color: const Color(0xFF636E72)),
          SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: isSmallScreen ? 11 : 12,
                color: const Color(0xFF636E72),
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'diterima': return Icons.inbox_rounded;
      case 'diproses': return Icons.autorenew_rounded;
      case 'selesai': return Icons.check_circle_rounded;
      case 'ditolak': return Icons.cancel_rounded;
      default: return Icons.inbox_rounded;
    }
  }

  Widget _buildHeader(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari aduan...',
                  hintStyle: GoogleFonts.poppins(color: const Color(0xFF636E72)),
                  prefixIcon: Icon(Icons.search_rounded, color: const Color(0xFF636E72)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 12 : 16,
                    vertical: isSmallScreen ? 14 : 16,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00D2D3), Color(0xFF26A69A)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: _refreshData,
              icon: Icon(
                _isRefreshing ? Icons.refresh : Icons.refresh_rounded,
                color: Colors.white,
              ),
              padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
              constraints: BoxConstraints(
                minWidth: isSmallScreen ? 40 : 48,
                minHeight: isSmallScreen ? 40 : 48,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(bool isSmallScreen) {
    final statusList = [
      {'value': 'semua', 'label': '📋 Semua', 'color': const Color(0xFF00D2D3)},
      {'value': 'diterima', 'label': '📥 Diterima', 'color': const Color(0xFFFFA502)},
      {'value': 'diproses', 'label': '⚙️ Diproses', 'color': const Color(0xFF6C5CE7)},
      {'value': 'selesai', 'label': '✅ Selesai', 'color': const Color(0xFF00D2D3)},
      {'value': 'ditolak', 'label': '❌ Ditolak', 'color': const Color(0xFFFF6B6B)},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: statusList.map((status) {
          final isSelected = _selectedStatus == status['value'];
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  setState(() {
                    _selectedStatus = status['value'] as String;
                    _applyFilter();
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 14 : 16,
                    vertical: isSmallScreen ? 8 : 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [
                              status['color'] as Color,
                              (status['color'] as Color).withOpacity(0.8),
                            ],
                          )
                        : null,
                    color: isSelected ? null : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? Colors.transparent : status['color'] as Color,
                      width: 1.5,
                    ),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: (status['color'] as Color).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      else
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                    ],
                  ),
                  child: Text(
                    status['label'] as String,
                    style: GoogleFonts.poppins(
                      fontSize: isSmallScreen ? 11 : 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : status['color'] as Color,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatsOverview(bool isSmallScreen) {
    final totalAduan = _aduanList.length;
    final aduanBaru = _aduanList.where((a) => a.status == 'diterima').length;
    final dalamProses = _aduanList.where((a) => a.status == 'diproses').length;

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
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
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Total', totalAduan.toString(), Icons.list_alt_rounded, isSmallScreen),
          _buildStatItem('Baru', aduanBaru.toString(), Icons.new_releases_rounded, isSmallScreen),
          _buildStatItem('Proses', dalamProses.toString(), Icons.autorenew_rounded, isSmallScreen),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, bool isSmallScreen) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: isSmallScreen ? 18 : 20),
        ),
        SizedBox(height: isSmallScreen ? 4 : 6),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: isSmallScreen ? 16 : 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: isSmallScreen ? 10 : 11,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 380;

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
          'Kelola Aduan',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2D3436),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
          child: Column(
            children: [
              // Stats Overview
              _buildStatsOverview(isSmallScreen),
              SizedBox(height: isSmallScreen ? 16 : 20),
              
              // Search Bar
              _buildHeader(isSmallScreen),
              SizedBox(height: isSmallScreen ? 16 : 20),
              
              // Filter Chips
              _buildFilterChips(isSmallScreen),
              SizedBox(height: isSmallScreen ? 16 : 20),
              
              // Results Count
              if (!_isLoading && !_isError)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00D2D3).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_filteredAduanList.length} aduan ditemukan',
                      style: GoogleFonts.poppins(
                        fontSize: isSmallScreen ? 12 : 13,
                        color: const Color(0xFF00D2D3),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              SizedBox(height: 12),
              
              // Main Content
              Expanded(
                child: _isLoading
                    ? _buildLoadingState(isSmallScreen)
                    : _isError
                        ? _buildErrorState(isSmallScreen)
                        : _filteredAduanList.isEmpty
                            ? _buildEmptyState(isSmallScreen)
                            : RefreshIndicator(
                                onRefresh: _refreshData,
                                color: const Color(0xFF00D2D3),
                                backgroundColor: Colors.white,
                                child: ListView.builder(
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: _filteredAduanList.length,
                                  itemBuilder: (context, index) {
                                    return _buildAduanCard(_filteredAduanList[index], isSmallScreen);
                                  },
                                ),
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(bool isSmallScreen) {
    return ListView.builder(
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 80, height: 24,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 60, height: 16,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity, height: 20,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity, height: 16,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 100, height: 16,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 80, height: 32,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorState(bool isSmallScreen) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: isSmallScreen ? 100 : 120,
            height: isSmallScreen ? 100 : 120,
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B6B).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline_rounded,
              size: isSmallScreen ? 40 : 50,
              color: const Color(0xFFFF6B6B),
            ),
          ),
          SizedBox(height: isSmallScreen ? 20 : 24),
          Text(
            'Gagal Memuat Aduan',
            style: GoogleFonts.poppins(
              fontSize: isSmallScreen ? 18 : 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2D3436),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Terjadi kesalahan saat memuat data aduan',
            style: GoogleFonts.poppins(
              color: const Color(0xFF636E72),
              fontSize: isSmallScreen ? 13 : 14,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isSmallScreen ? 20 : 24),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _loadAduan,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 24 : 32,
                  vertical: isSmallScreen ? 12 : 14,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00D2D3), Color(0xFF26A69A)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00D2D3).withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
                    SizedBox(width: isSmallScreen ? 6 : 8),
                    Text(
                      'Coba Lagi',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: isSmallScreen ? 14 : 15,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isSmallScreen) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: isSmallScreen ? 100 : 120,
            height: isSmallScreen ? 100 : 120,
            decoration: BoxDecoration(
              color: const Color(0xFF00D2D3).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.report_gmailerrorred_rounded,
              size: isSmallScreen ? 40 : 50,
              color: const Color(0xFF00D2D3),
            ),
          ),
          SizedBox(height: isSmallScreen ? 20 : 24),
          Text(
            _searchController.text.isEmpty && _selectedStatus == 'semua'
                ? 'Belum Ada Aduan'
                : 'Aduan Tidak Ditemukan',
            style: GoogleFonts.poppins(
              fontSize: isSmallScreen ? 18 : 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2D3436),
            ),
          ),
          SizedBox(height: 8),
          Text(
            _searchController.text.isEmpty && _selectedStatus == 'semua'
                ? 'Saat ini belum ada aduan yang diajukan warga'
                : 'Tidak ada aduan yang sesuai dengan pencarian Anda',
            style: GoogleFonts.poppins(
              color: const Color(0xFF636E72),
              fontSize: isSmallScreen ? 13 : 14,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          if (_searchController.text.isNotEmpty || _selectedStatus != 'semua')
            TextButton(
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _selectedStatus = 'semua';
                  _applyFilter();
                });
              },
              child: Text(
                'Reset Pencarian',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF00D2D3),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}