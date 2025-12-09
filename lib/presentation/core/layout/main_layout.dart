import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../settings/language_provider.dart';
import '../../../i18n/strings.dart';

class MainLayout extends StatelessWidget {
  final String title;
  final Widget child;

  const MainLayout({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          _sidebar(context),

          Expanded(
            child: Column(
              children: [
                _topBar(context, title),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------
  // SIDEBAR
  // ------------------------------
  Widget _sidebar(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context).lang;

    return Container(
      width: 240,
      color: const Color(0xFF592EC3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 50),

          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              "ARG30",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 20),

          _menuItem(
            context,
            Icons.cloud_upload,
            translate(context, "upload"),
            () => Navigator.pushReplacementNamed(context, "/dashboard"),
          ),

          _menuItem(
            context,
            Icons.history,
            translate(context, "history"),
            () => Navigator.pushReplacementNamed(context, "/history"),
          ),

          _menuItem(
            context,
            Icons.settings,
            translate(context, "settings"),
            () => Navigator.pushReplacementNamed(context, "/settings"),
          ),
        ],
      ),
    );
  }

  Widget _menuItem(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------
  // TOP BAR
  // ------------------------------
  Widget _topBar(BuildContext context, String title) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.language),
                onPressed: () {
                  final prov = Provider.of<LanguageProvider>(
                    context,
                    listen: false,
                  );

                  prov.setLang(prov.lang == "tr" ? "en" : "tr");
                },
              ),

              const SizedBox(width: 8),

              const CircleAvatar(
                radius: 16,
                backgroundColor: Colors.black26,
                child: Icon(Icons.person, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
