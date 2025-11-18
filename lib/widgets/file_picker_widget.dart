// lib/widgets/file_picker_widget.dart
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/file_service.dart';

class FilePickerWidget extends StatefulWidget {
  final Function(PlatformFile?)? onFileSelected;
  final String? label;
  final String? initialFileName;
  final bool isRequired;

  const FilePickerWidget({
    super.key,
    this.onFileSelected,
    this.label,
    this.initialFileName,
    this.isRequired = false,
  });

  @override
  State<FilePickerWidget> createState() => _FilePickerWidgetState();
}

class _FilePickerWidgetState extends State<FilePickerWidget> {
  PlatformFile? _selectedFile;
  String? _fileName;

  @override
  void initState() {
    super.initState();
    _fileName = widget.initialFileName;
  }

  Future<void> _pickFile() async {
    try {
      final result = await FileService.pickFile();
      
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        
        // Validasi ukuran file
        if (!FileService.validateFileSize(file)) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('File terlalu besar. Maksimal 5MB'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
        
        // Validasi extension
        if (!FileService.validateFileExtension(file)) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Format file tidak didukung'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        setState(() {
          _selectedFile = file;
          _fileName = file.name;
        });

        widget.onFileSelected?.call(file);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memilih file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removeFile() {
    setState(() {
      _selectedFile = null;
      _fileName = null;
    });
    widget.onFileSelected?.call(null);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 8),
        ],
        
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                if (_fileName != null) ...[
                  Row(
                    children: [
                     Icon(
  FileService.getFileTypeIcon(_fileName!),
  size: 22,
  color: Colors.blueGrey,
),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _fileName!,
                              style: TextStyle(fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (_selectedFile != null)
                              Text(
                                FileService.formatFileSize(_selectedFile!.size),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: _removeFile,
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                ],
                
                ElevatedButton.icon(
                  onPressed: _pickFile,
                  icon: Icon(Icons.attach_file),
                  label: Text(_fileName == null ? 'Pilih File' : 'Ganti File'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade50,
                    foregroundColor: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        if (widget.isRequired && _fileName == null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'File wajib diupload',
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}