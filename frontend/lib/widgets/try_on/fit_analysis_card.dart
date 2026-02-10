import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/app_theme.dart';
import '../../models/try_on.dart';

class FitAnalysisCard extends StatelessWidget {
  final FitAnalysis fitAnalysis;

  const FitAnalysisCard({super.key, required this.fitAnalysis});

  Color get _fitColor {
    switch (fitAnalysis.overallFit) {
      case 'perfect':
        return AppTheme.successColor;
      case 'good':
        return const Color(0xFF1976D2);
      case 'acceptable':
        return AppTheme.warningColor;
      case 'poor':
        return AppTheme.errorColor;
      default:
        return Colors.grey;
    }
  }

  String get _fitLabel {
    switch (fitAnalysis.overallFit) {
      case 'perfect':
        return 'Perfect Fit';
      case 'good':
        return 'Good Fit';
      case 'acceptable':
        return 'Acceptable Fit';
      case 'poor':
        return 'Poor Fit';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.fontColor.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: _fitColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _fitLabel,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _fitColor,
                  ),
                ),
              ),
              const Spacer(),
              if (fitAnalysis.confidence != null)
                _buildConfidenceIndicator(fitAnalysis.confidence!),
            ],
          ),
          if (fitAnalysis.tightAreas.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Tight Areas',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.fontColor,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: fitAnalysis.tightAreas
                  .map((area) => Chip(
                        label: Text(area, style: const TextStyle(fontSize: 12)),
                        backgroundColor: AppTheme.errorColor.withValues(alpha: 0.1),
                        labelStyle: TextStyle(color: AppTheme.errorColor),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ))
                  .toList(),
            ),
          ],
          if (fitAnalysis.looseAreas.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Loose Areas',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.fontColor,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: fitAnalysis.looseAreas
                  .map((area) => Chip(
                        label: Text(area, style: const TextStyle(fontSize: 12)),
                        backgroundColor: AppTheme.warningColor.withValues(alpha: 0.1),
                        labelStyle: TextStyle(color: AppTheme.warningColor),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ))
                  .toList(),
            ),
          ],
          if (fitAnalysis.recommendations.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Recommendations',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.fontColor,
              ),
            ),
            const SizedBox(height: 6),
            ...fitAnalysis.recommendations.map((rec) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('  \u2022  ', style: TextStyle(fontSize: 13)),
                      Expanded(
                        child: Text(
                          rec,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppTheme.fontColor.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildConfidenceIndicator(double confidence) {
    return Column(
      children: [
        SizedBox(
          width: 44,
          height: 44,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: confidence / 100,
                strokeWidth: 4,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(_fitColor),
              ),
              Center(
                child: Text(
                  '${confidence.toInt()}%',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.fontColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
