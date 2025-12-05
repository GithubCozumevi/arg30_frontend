import 'package:flutter/material.dart';

class AnalysisDetailPage extends StatelessWidget {
  final Map<String, dynamic> result;

  const AnalysisDetailPage({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(result["filename"] ?? "Detay"),
        backgroundColor: const Color(0xFF592EC3),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _detailRow("Belge Türü", result["predicted_class_tr"]),
          _detailRow("Tarih (Dosya Adı)", result["filename_date"]),
          _detailRow("Versiyon (Dosya Adı)", result["filename_version"]),
          _detailRow("Kısa Özet", result["summary_short_tr"]),
          _detailRow("Uzun Özet", result["summary_long_tr"]),

          _detailRow(
            "Başlıklar",
            (result["headings"] is List && result["headings"].isNotEmpty)
                ? (result["headings"]).join(", ")
                : "-",
          ),

          _detailRow(
            "Anahtar Kelimeler",
            (result["keywords"] is List && result["keywords"].isNotEmpty)
                ? (result["keywords"]).join(", ")
                : "-",
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String title, dynamic value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(value?.toString() ?? "-"),
          ],
        ),
      ),
    );
  }
}
