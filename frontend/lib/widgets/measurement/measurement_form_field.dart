import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/app_theme.dart';

class MeasurementFormField extends StatelessWidget {
  final String label;
  final String hint;
  final String unit;
  final TextEditingController controller;
  final double? min;
  final double? max;
  final bool isRequired;
  final IconData? icon;

  const MeasurementFormField({
    super.key,
    required this.label,
    required this.hint,
    required this.unit,
    required this.controller,
    this.min,
    this.max,
    this.isRequired = true,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
        ],
        // Input text — rule 2
        style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w500, color: AppTheme.fontColor),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          suffixText: unit,
          prefixIcon: icon != null ? Icon(icon, size: 20) : null,
          // Suffix text — rule 2
          suffixStyle: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.fontColor.withValues(alpha: 0.5),
          ),
        ),
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return '$label is required';
          }
          if (value != null && value.isNotEmpty) {
            final num = double.tryParse(value);
            if (num == null) return 'Enter a valid number';
            if (min != null && num < min!) return 'Minimum is $min';
            if (max != null && num > max!) return 'Maximum is $max';
          }
          return null;
        },
      ),
    );
  }
}
