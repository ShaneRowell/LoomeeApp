import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../models/measurement.dart';
import '../../providers/measurement_provider.dart';

class MeasurementsScreen extends StatefulWidget {
  const MeasurementsScreen({super.key});

  @override
  State<MeasurementsScreen> createState() => _MeasurementsScreenState();
}

class _MeasurementsScreenState extends State<MeasurementsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _chestController = TextEditingController();
  final _waistController = TextEditingController();
  final _hipsController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _shoulderController = TextEditingController();
  final _inseamController = TextEditingController();
  String _unit = 'cm';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<MeasurementProvider>();
      await provider.fetchMeasurements();
      _prefillForm(provider.measurement);
    });
  }

  void _prefillForm(Measurement? m) {
    if (m == null) return;
    _chestController.text = m.chest.toString();
    _waistController.text = m.waist.toString();
    _hipsController.text = m.hips.toString();
    _heightController.text = m.height.toString();
    _weightController.text = m.weight.toString();
    if (m.shoulderWidth != null) {
      _shoulderController.text = m.shoulderWidth.toString();
    }
    if (m.inseam != null) _inseamController.text = m.inseam.toString();
    setState(() => _unit = m.unit);
  }

  @override
  void dispose() {
    _chestController.dispose();
    _waistController.dispose();
    _hipsController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _shoulderController.dispose();
    _inseamController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final measurement = Measurement(
      chest: double.parse(_chestController.text),
      waist: double.parse(_waistController.text),
      hips: double.parse(_hipsController.text),
      height: double.parse(_heightController.text),
      weight: double.parse(_weightController.text),
      shoulderWidth: _shoulderController.text.isNotEmpty
          ? double.parse(_shoulderController.text)
          : null,
      inseam: _inseamController.text.isNotEmpty
          ? double.parse(_inseamController.text)
          : null,
      unit: _unit,
    );

    final success =
        await context.read<MeasurementProvider>().saveMeasurements(measurement);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Measurements saved successfully'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final unitLabel = _unit == 'cm' ? 'cm' : 'in';
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Consumer<MeasurementProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.measurement == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Wave header
                  _buildHeader(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          Text(
                            'Body Measurements',
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.fontColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Used for size recommendation and AI try ons, enter your measurements below.',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppTheme.fontColor.withValues(alpha: 0.5),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Measurement fields with icons
                          _buildMeasurementField(
                            icon: Icons.checkroom,
                            label: 'Chest ($unitLabel)',
                            controller: _chestController,
                          ),
                          const SizedBox(height: 14),
                          _buildMeasurementField(
                            icon: Icons.straighten,
                            label: 'Waist ($unitLabel)',
                            controller: _waistController,
                          ),
                          const SizedBox(height: 14),
                          _buildMeasurementField(
                            icon: Icons.circle_outlined,
                            label: 'Hips ($unitLabel)',
                            controller: _hipsController,
                          ),
                          const SizedBox(height: 14),
                          _buildMeasurementField(
                            icon: Icons.height,
                            label: 'Height ($unitLabel)',
                            controller: _heightController,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'All measurements in ($unitLabel)',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppTheme.fontColor.withValues(alpha: 0.4),
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: provider.isLoading ? null : _save,
                              child: provider.isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: Colors.white),
                                    )
                                  : Text(
                                      'Save Measurements',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                          if (provider.error != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              provider.error!,
                              style: const TextStyle(color: AppTheme.errorColor, fontSize: 13),
                            ),
                          ],
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 100,
          decoration: BoxDecoration(
            color: AppTheme.widgetColor.withValues(alpha: 0.08),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: CustomPaint(
            size: const Size(double.infinity, 25),
            painter: _WavePainter(color: AppTheme.backgroundColor),
          ),
        ),
        Positioned(
          top: 16,
          left: 20,
          child: Text(
            'Loomeé',
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppTheme.fontColor,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMeasurementField({
    required IconData icon,
    required String label,
    required TextEditingController controller,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.fontColor.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Icon(icon, size: 20, color: AppTheme.widgetColor),
          ),
          Expanded(
            child: TextFormField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: label,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                filled: false,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Required';
                if (double.tryParse(value) == null) return 'Invalid number';
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final Color color;

  _WavePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height * 0.4)
      ..quadraticBezierTo(
        size.width * 0.25,
        0,
        size.width * 0.5,
        size.height * 0.3,
      )
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height * 0.6,
        size.width,
        size.height * 0.2,
      )
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
