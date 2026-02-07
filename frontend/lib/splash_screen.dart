import 'package:flutter/material.dart';
import 'api_service.dart';
import 'prediction_form.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final ApiService _apiService = ApiService();
  bool _backendReady = false;
  String _statusText = 'Waking up the server...';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _checkBackend();
  }

  Future<void> _checkBackend() async {
    while (!_backendReady) {
      try {
        // Try to fetch locations as a health check
        await _apiService.fetchLocations();
        if (mounted) {
          setState(() {
            _backendReady = true;
            _statusText = 'Server Ready!';
          });
          // Give a moment for the user to see the success state
          await Future.delayed(const Duration(seconds: 1));
          _navigateToHome();
        }
        break;
      } catch (e) {
        if (mounted) {
          setState(() {
            // Cycle messages to keep user entertained
            if (_statusText == 'Waking up the server...')
              _statusText = 'Laying foundations...';
            else if (_statusText == 'Laying foundations...')
              _statusText = 'Building walls...';
            else if (_statusText == 'Building walls...')
              _statusText = 'Painting the roof...';
            else
              _statusText = 'Waking up the server...'; // Loop back
          });
        }
        // Wait 2 seconds before retrying
        await Future.delayed(const Duration(seconds: 2));
      }
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) =>
            const Scaffold(body: SafeArea(child: PredictionForm())),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomPaint(
              painter: HouseBuildingPainter(_controller),
              size: const Size(200, 200),
            ),
            const SizedBox(height: 40),
            Text(
              'UrbanNest',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Chennai Real Estate',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 40),
            Text(
              _statusText,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 10),
            if (!_backendReady)
              const SizedBox(
                width: 100,
                child: LinearProgressIndicator(
                  backgroundColor: Colors.grey,
                  color: Colors.white,
                  minHeight: 2,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class HouseBuildingPainter extends CustomPainter {
  final Animation<double> animation;

  HouseBuildingPainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..style = PaintingStyle.fill;
    final double w = size.width;
    final double h = size.height;
    final double progress = animation.value;

    // Ground (Phase 1: 0.0 - 0.2)
    double groundProgress = (progress).clamp(0.0, 0.2) / 0.2;
    paint.color = Colors.green[800]!;
    double groundWidth = w * groundProgress;
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(w / 2, h * 0.9),
        width: groundWidth,
        height: 10,
      ),
      paint,
    );

    if (progress < 0.2) return;

    // Walls (Phase 2: 0.2 - 0.5)
    double wallProgress = (progress - 0.2).clamp(0.0, 0.3) / 0.3;
    paint.color = Colors.grey[300]!;
    double wallHeight = (h * 0.5) * wallProgress;
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(w / 2, h * 0.9 - wallHeight / 2),
        width: w * 0.6,
        height: wallHeight,
      ),
      paint,
    );

    if (progress < 0.5) return;

    // Roof (Phase 3: 0.5 - 0.7)
    double roofProgress = (progress - 0.5).clamp(0.0, 0.2) / 0.2;
    paint.color = Colors.red[800]!;
    Path roofPath = Path();

    // Actually simplicity: grow from bottom of roof (top of wall)
    double roofBaseY = h * 0.9 - (h * 0.5); // Top of wall
    double currentRoofHeight = (h * 0.25) * roofProgress;

    roofPath.moveTo(w / 2, roofBaseY - currentRoofHeight); // Top Peak
    roofPath.lineTo(w * 0.15, roofBaseY); // Left Corner
    roofPath.lineTo(w * 0.85, roofBaseY); // Right Corner
    roofPath.close();
    canvas.drawPath(roofPath, paint);

    if (progress < 0.7) return;

    // Door & Windows (Phase 4: 0.7 - 0.9)
    double detailsProgress = (progress - 0.7).clamp(0.0, 0.2) / 0.2;
    paint.color = Colors.brown[600]!.withValues(alpha: detailsProgress);

    // Door
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(w / 2, h * 0.9 - (h * 0.15)),
        width: w * 0.15,
        height: h * 0.3, // Clip to wall?
      ),
      paint,
    );

    // Window
    paint.color = Colors.lightBlue[300]!.withValues(alpha: detailsProgress);
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(w * 0.35, h * 0.65),
        width: w * 0.12,
        height: w * 0.12,
      ),
      paint,
    );
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(w * 0.65, h * 0.65),
        width: w * 0.12,
        height: w * 0.12,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
