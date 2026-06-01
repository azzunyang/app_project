import 'package:flutter/material.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  late Animation<double> _textFadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );
    _scaleAnim = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );
    _textFadeAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
    );

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 2000), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (ctx, a1, a2) => const MainScreen(),
          transitionDuration: const Duration(milliseconds: 400),
          transitionsBuilder: (ctx, anim, a2, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (ctx, _) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 아이콘
                Opacity(
                  opacity: _fadeAnim.value,
                  child: Transform.scale(
                    scale: _scaleAnim.value,
                    child: _buildIcon(),
                  ),
                ),
                const SizedBox(height: 28),
                // 텍스트
                Opacity(
                  opacity: _textFadeAnim.value,
                  child: Column(
                    children: [
                      const Text(
                        '호서대학교',
                        style: TextStyle(
                          color: Color(0xFF1E3A5F),
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '공지사항',
                        style: TextStyle(
                          color: const Color(0xFF1E3A5F).withValues(alpha: 0.55),
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 3.0,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 60),
                // 로딩 인디케이터
                Opacity(
                  opacity: _textFadeAnim.value,
                  child: const _LoadingDots(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 104,
      height: 104,
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A5F),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A5F).withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // H letter
          Center(
            child: _HLetter(),
          ),
          // Orange dot
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HLetter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 52,
      child: CustomPaint(painter: _HPainter()),
    );
  }
}

class _HPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final stroke = size.width * 0.22;
    final w = size.width;
    final h = size.height;

    // Left bar
    canvas.drawRect(Rect.fromLTWH(0, 0, stroke, h), paint);
    // Right bar
    canvas.drawRect(Rect.fromLTWH(w - stroke, 0, stroke, h), paint);
    // Crossbar
    canvas.drawRect(
      Rect.fromLTWH(0, (h - stroke) / 2, w, stroke),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LoadingDots extends StatefulWidget {
  const _LoadingDots();

  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
          ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          final t = ((_ctrl.value * 3) - i).clamp(0.0, 1.0);
          final opacity = t < 0.5 ? t * 2 : (1.0 - t) * 2;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A5F)
                  .withValues(alpha: opacity.clamp(0.15, 1.0)),
              shape: BoxShape.circle,
            ),
          );
        }),
      ),
    );
  }
}
