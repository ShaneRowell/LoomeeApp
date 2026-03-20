import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../models/measurement.dart';
import '../../providers/measurement_provider.dart';
import '../../widgets/common/animated_tab_header.dart';

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
      // Guard required: if the widget is disposed while fetchMeasurements() is
      // in flight, the TextEditingControllers will already be disposed and
      // setting their .text would throw an assertion error.
      if (!mounted) return;
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
    if (mounted) setState(() => _unit = m.unit);
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
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Consumer<MeasurementProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.measurement == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return SafeArea(
            top: false,
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
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: scheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Used for size recommendation and AI try ons, enter your measurements below.',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 13,
                              color: scheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Measurement fields with icons
                          _buildMeasurementField(
                            icon: Icons.accessibility_new,
                            label: 'Chest ($unitLabel)',
                            controller: _chestController,
                            min: 50,
                            max: 200,
                          ),
                          const SizedBox(height: 14),
                          _buildMeasurementField(
                            icon: Icons.straighten,
                            label: 'Waist ($unitLabel)',
                            controller: _waistController,
                            min: 40,
                            max: 180,
                          ),
                          const SizedBox(height: 14),
                          _buildMeasurementField(
                            icon: Icons.circle_outlined,
                            label: 'Hips ($unitLabel)',
                            controller: _hipsController,
                            min: 50,
                            max: 200,
                          ),
                          const SizedBox(height: 14),
                          _buildMeasurementField(
                            icon: Icons.height,
                            label: 'Height ($unitLabel)',
                            controller: _heightController,
                            min: 100,
                            max: 250,
                          ),
                          const SizedBox(height: 14),
                          _buildMeasurementField(
                            icon: Icons.monitor_weight_outlined,
                            label: 'Weight (kg)',
                            controller: _weightController,
                            min: 30,
                            max: 300,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'All measurements in ($unitLabel)',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 12,
                              color: scheme.onSurface.withValues(alpha: 0.4),
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
                                      style: GoogleFonts.playfairDisplay(
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

  Widget _buildHeader() => const AnimatedTabHeader(title: 'Measure');

  Widget _buildMeasurementField({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    double? min,
    double? max,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: scheme.onSurface.withValues(alpha: 0.55)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Required';
        final parsed = double.tryParse(value);
        if (parsed == null) return 'Invalid number';
        if (min != null && parsed < min) return 'Min value is $min';
        if (max != null && parsed > max) return 'Max value is $max';
        return null;
      },
    );
  }
}

