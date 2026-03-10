import 'dart:math' as math;
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

  // Live values that drive the animated body figure
  double _chest = 90;
  double _waist = 72;
  double _hips = 96;
  double _height = 170;

  @override
  void initState() {
    super.initState();
    _chestController.addListener(_onMeasurementChanged);
    _waistController.addListener(_onMeasurementChanged);
    _hipsController.addListener(_onMeasurementChanged);
    _heightController.addListener(_onMeasurementChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<MeasurementProvider>();
      await provider.fetchMeasurements();
      _prefillForm(provider.measurement);
    });
  }

  void _onMeasurementChanged() {
    setState(() {
      _chest = double.tryParse(_chestController.text) ?? _chest;
      _waist = double.tryParse(_waistController.text) ?? _waist;
      _hips = double.tryParse(_hipsController.text) ?? _hips;
      _height = double.tryParse(_heightController.text) ?? _height;
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
    _chestController.removeListener(_onMeasurementChanged);
    _waistController.removeListener(_onMeasurementChanged);
    _hipsController.removeListener(_onMeasurementChanged);
    _heightController.removeListener(_onMeasurementChanged);
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
                  _buildHeader(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
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
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Enter your measurements for size recommendations and AI try-ons.',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w300,
                            color: AppTheme.fontColor.withValues(alpha: 0.5),
                            letterSpacing: 0.1,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ── Animated body figure card ──────────────────
                        _buildFigureCard(),
                        const SizedBox(height: 24),

                        // ── Measurement form ───────────────────────────
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildMeasurementField(
                                icon: Icons.width_normal_outlined,
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
                                icon: Icons.social_distance_outlined,
                                label: 'Hips ($unitLabel)',
                                controller: _hipsController,
                              ),
                              const SizedBox(height: 14),
                              _buildMeasurementField(
                                icon: Icons.height,
                                label: 'Height ($unitLabel)',
                                controller: _heightController,
                              ),
                              const SizedBox(height: 14),
                              _buildMeasurementField(
                                icon: Icons.monitor_weight_outlined,
                                label: 'Weight (kg)',
                                controller: _weightController,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'All measurements in ($unitLabel)',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w300,
                                  color: AppTheme.fontColor.withValues(alpha: 0.4),
                                  letterSpacing: 0.2,
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
                                              strokeWidth: 2,
                                              color: Colors.white),
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
                                  style: const TextStyle(
                                      color: AppTheme.errorColor, fontSize: 13),
                                ),
                              ],
                              const SizedBox(height: 32),
                            ],
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
      ),
    );
  }

  Widget _buildFigureCard() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.fontColor.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Body silhouette (left half)
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(end: _chest),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutCubic,
                builder: (_, animChest, __) {
                  return TweenAnimationBuilder<double>(
                    tween: Tween<double>(end: _waist),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutCubic,
                    builder: (_, animWaist, __) {
                      return TweenAnimationBuilder<double>(
                        tween: Tween<double>(end: _hips),
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOutCubic,
                        builder: (_, animHips, __) {
                          return CustomPaint(
                            painter: _BodyFigurePainter(
                              chest: animChest,
                              waist: animWaist,
                              hips: animHips,
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
          // Stats (right)
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 16, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'BODY PROFILE',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.fontColor.withValues(alpha: 0.35),
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildStatRow('Chest', _chestController.text, _unit),
                  const SizedBox(height: 8),
                  _buildStatRow('Waist', _waistController.text, _unit),
                  const SizedBox(height: 8),
                  _buildStatRow('Hips', _hipsController.text, _unit),
                  const SizedBox(height: 8),
                  _buildStatRow('Height', _heightController.text, _unit),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, String unit) {
    final display = value.isNotEmpty ? '$value $unit' : '—';
    return Row(
      children: [
        SizedBox(
          width: 52,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w300,
              color: AppTheme.fontColor.withValues(alpha: 0.45),
              letterSpacing: 0.2,
            ),
          ),
        ),
        Text(
          display,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.fontColor,
          ),
        ),
      ],
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

// ── Body figure painter ────────────────────────────────────────────────

class _BodyFigurePainter extends CustomPainter {
  final double chest;
  final double waist;
  final double hips;

  _BodyFigurePainter({
    required this.chest,
    required this.waist,
    required this.hips,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;

    // Normalise measurement values against average references, clamped to [0.7, 1.3]
    final cScale = (chest / 90.0).clamp(0.70, 1.30);
    final wScale = (waist / 72.0).clamp(0.65, 1.35);
    final hScale = (hips / 96.0).clamp(0.70, 1.30);

    // Pixel half-widths at each body level
    final chestHW = cScale * size.width * 0.27;
    final waistHW = wScale * size.width * 0.19;
    final hipsHW = hScale * size.width * 0.28;
    final neckHW = size.width * 0.045;
    final legHW = size.width * 0.10;
    final legGap = size.width * 0.030;

    // Y key-points as fractions of height
    final h = size.height;
    final headR = h * 0.064;
    final headCY = h * 0.068;
    final neckTop = h * 0.136;
    final neckBot = h * 0.172;
    final shoulderY = h * 0.182;
    final chestBotY = h * 0.340;
    final waistY = h * 0.470;
    final hipTopY = h * 0.510;
    final hipBotY = h * 0.600;
    final legBotY = h * 0.985;

    final fillPaint = Paint()
      ..color = AppTheme.deepNavy.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = AppTheme.deepNavy.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Head
    canvas.drawCircle(Offset(cx, headCY), headR, fillPaint);
    canvas.drawCircle(Offset(cx, headCY), headR, strokePaint);

    // Torso + legs path
    final body = Path();
    body.moveTo(cx - neckHW, neckTop);
    // Left neck to shoulder
    body.cubicTo(
      cx - neckHW, neckBot, cx - chestHW, neckBot, cx - chestHW, shoulderY);
    // Left side chest → waist (cubic for hourglass curve)
    body.cubicTo(
      cx - chestHW, chestBotY,
      cx - waistHW, waistY - h * 0.04,
      cx - waistHW, waistY,
    );
    // Left waist → hip
    body.cubicTo(
      cx - waistHW, hipTopY,
      cx - hipsHW, hipTopY,
      cx - hipsHW, hipBotY,
    );
    // Left outer leg
    body.lineTo(cx - legGap - legHW, legBotY);
    // Left inner leg
    body.lineTo(cx - legGap, hipBotY);
    // Crotch curve
    body.quadraticBezierTo(cx, hipBotY + h * 0.025, cx + legGap, hipBotY);
    // Right inner → outer leg
    body.lineTo(cx + legGap + legHW, legBotY);
    // Right hip
    body.lineTo(cx + hipsHW, hipBotY);
    body.cubicTo(
      cx + hipsHW, hipTopY,
      cx + waistHW, hipTopY,
      cx + waistHW, waistY,
    );
    // Right waist → chest
    body.cubicTo(
      cx + waistHW, waistY - h * 0.04,
      cx + chestHW, chestBotY,
      cx + chestHW, shoulderY,
    );
    // Right shoulder → neck
    body.cubicTo(
      cx + chestHW, neckBot, cx + neckHW, neckBot, cx + neckHW, neckTop);
    body.close();

    canvas.drawPath(body, fillPaint);
    canvas.drawPath(body, strokePaint);

    // Arms
    final armTopW = size.width * 0.09;
    final armBotW = size.width * 0.07;
    final armLen = h * 0.28;
    final spread = math.sin(0.18) * armLen;
    final drop = math.cos(0.18) * armLen;

    for (final side in [-1.0, 1.0]) {
      final ax = cx + side * chestHW;
      final arm = Path()
        ..moveTo(ax - side * armTopW * 0.5, shoulderY)
        ..lineTo(ax + side * spread, shoulderY + drop)
        ..lineTo(ax + side * spread - side * armBotW, shoulderY + drop)
        ..lineTo(ax + side * armTopW * 0.5, shoulderY)
        ..close();
      canvas.drawPath(arm, fillPaint);
      canvas.drawPath(arm, strokePaint);
    }

    // Waist guide line
    final dashPaint = Paint()
      ..color = AppTheme.accentColor.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    _drawDashedLine(
        canvas, Offset(cx - waistHW - 4, waistY), Offset(cx + waistHW + 4, waistY), dashPaint);
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint,
      {double dashLen = 3, double gapLen = 3}) {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final total = math.sqrt(dx * dx + dy * dy);
    final ux = dx / total;
    final uy = dy / total;
    double dist = 0;
    bool drawing = true;
    while (dist < total) {
      final segLen = drawing ? dashLen : gapLen;
      final next = (dist + segLen).clamp(0, total).toDouble();
      if (drawing) {
        canvas.drawLine(
          Offset(start.dx + ux * dist, start.dy + uy * dist),
          Offset(start.dx + ux * next, start.dy + uy * next),
          paint,
        );
      }
      dist += segLen;
      drawing = !drawing;
    }
  }

  @override
  bool shouldRepaint(_BodyFigurePainter old) =>
      old.chest != chest || old.waist != waist || old.hips != hips;
}

// ── Wave header painter (unchanged) ──────────────────────────────────

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
          size.width * 0.25, 0, size.width * 0.5, size.height * 0.3)
      ..quadraticBezierTo(
          size.width * 0.75, size.height * 0.6, size.width, size.height * 0.2)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
