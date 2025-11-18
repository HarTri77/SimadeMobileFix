// lib/widgets/custom_text_field.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';
import 'glass_container.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;
  final Widget? suffixIcon;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      blur: 10,
      opacity: 0.3,
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: GoogleFonts.poppins(
          color: AppColors.darkNavy,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: GoogleFonts.poppins(
            color: Colors.grey.shade700,
            fontSize: 14,
          ),
          hintStyle: GoogleFonts.poppins(
            color: Colors.grey.shade400,
            fontSize: 12,
          ),
          prefixIcon: Icon(icon, color: AppColors.primaryBlue),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
          errorStyle: GoogleFonts.poppins(fontSize: 11),
        ),
        validator: validator,
      ),
    );
  }
}