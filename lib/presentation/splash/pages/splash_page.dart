// splash_page.dart
import 'package:arg30_frontend/presentation/auth/pages/login_page.dart';
import 'package:arg30_frontend/presentation/dashboard/user/pages/user_dashboard_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  final String text = "cozumevi";
  final List<AnimationController> _controllers = [];
  final List<Animation<double>> _animations = [];

  @override
  void initState() {
    super.initState();

    // 🔥 Harf animasyonlarını oluştur
    for (int i = 0; i < text.length; i++) {
      final controller = AnimationController(
        duration: const Duration(milliseconds: 400),
        vsync: this,
      );
      final animation = CurvedAnimation(
        parent: controller,
        curve: Curves.easeIn,
      );

      _controllers.add(controller);
      _animations.add(animation);

      Future.delayed(Duration(milliseconds: i * 150), () {
        if (mounted) controller.forward();
      });
    }

    // 🔥 Animasyon bitince Firebase Auth kontrolü
    Future.delayed(const Duration(seconds: 2), checkAuthStatus);
  }

  void checkAuthStatus() {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // 🔥 Kullanıcı giriş yapmış → Dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const UserDashboardPage()),
      );
    } else {
      // 🔥 Giriş yapılmamış → Login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF592EC3),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(text.length, (index) {
            return FadeTransition(
              opacity: _animations[index],
              child: Text(
                text[index],
                style: GoogleFonts.poppins(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
