import 'package:arg30_frontend/presentation/settings/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:arg30_frontend/i18n/strings.dart';
import 'package:provider/provider.dart';

class AnalysisDetailPage extends StatelessWidget {
  final Map<String, dynamic> result;

  const AnalysisDetailPage({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context).lang;

    final predictedClass =
        lang == "tr" ? result["predictedClassTr"] : result["predictedClassEn"];

    final summaryShort =
        lang == "tr" ? result["summaryShortTr"] : result["summaryShortEn"];

    final summaryLong =
        lang == "tr" ? result["summaryLongTr"] : result["summaryLongEn"];

    final explanation =
        lang == "tr" ? result["explanationTr"] : result["explanationEn"];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          result["filename"] ?? translate(context, "document_analysis"),
        ),
        backgroundColor: const Color(0xFF592EC3),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _detailRow(context, "detail_class", predictedClass),
          _detailRow(context, "detail_date", result["filenameDate"]),
          _detailRow(context, "detail_version", result["filenameVersion"]),
          _detailRow(context, "detail_short_summary", summaryShort),
          _detailRow(context, "detail_long_summary", summaryLong),
          _detailRow(
            context,
            "detail_headings",
            (result["headings"] is List && result["headings"].isNotEmpty)
                ? result["headings"].join(", ")
                : "-",
          ),
          _detailRow(
            context,
            "detail_keywords",
            (result["keywords"] is List && result["keywords"].isNotEmpty)
                ? result["keywords"].join(", ")
                : "-",
          ),
          _detailRow(
            context,
            "detail_topics",
            (result["topics"] is List && result["topics"].isNotEmpty)
                ? result["topics"].join(", ")
                : "-",
          ),
          _detailRow(context, "detail_explanation", explanation),
        ],
      ),
    );
  }

  Widget _detailRow(BuildContext context, String titleKey, dynamic value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              translate(context, titleKey),
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
