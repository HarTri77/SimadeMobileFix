// lib/widgets/image_viewer_widget.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:photo_view/photo_view.dart'; // Tambah dependency di pubspec.yaml

class ImageViewerWidget extends StatelessWidget {
  final String imageUrl;
  final String imageName;

  const ImageViewerWidget({
    super.key,
    required this.imageUrl,
    required this.imageName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          imageName,
          style: GoogleFonts.poppins(),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            onPressed: () {
              // TODO: Implement download functionality
            },
          ),
        ],
      ),
      body: PhotoView(
        imageProvider: NetworkImage(imageUrl),
        backgroundDecoration: BoxDecoration(color: Colors.black),
        loadingBuilder: (context, event) => Center(
          child: CircularProgressIndicator(),
        ),
        errorBuilder: (context, error, stackTrace) => Center(
          child: Text(
            'Gagal memuat gambar',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
        ),
      ),
    );
  }
}