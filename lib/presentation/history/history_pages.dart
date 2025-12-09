import 'package:arg30_frontend/presentation/dashboard/user/pages/analysis_detail_page.dart';
import 'package:arg30_frontend/i18n/strings.dart';
import 'package:arg30_frontend/presentation/settings/language_provider.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final lang = Provider.of<LanguageProvider>(context).lang;

    if (user == null) {
      return Scaffold(
        body: Center(child: Text(translate(context, "error_occurred"))),
      );
    }

    final stream =
        FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('analyses')
            .orderBy('createdAt', descending: true)
            .snapshots();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          color: Colors.white,
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/user',
              (route) => false,
            );
          },
        ),
        title: Text(translate(context, "history_title")),
        backgroundColor: const Color(0xFF592EC3),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "${translate(context, "history_error")} ${snapshot.error}",
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF592EC3)),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(child: Text(translate(context, "history_empty")));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;

              final predictedClass =
                  lang == "tr"
                      ? data["predictedClassTr"]
                      : data["predictedClassEn"];

              final result = {
                "filename": data["filename"],
                "predictedClassTr": data["predictedClassTr"],
                "predictedClassEn": data["predictedClassEn"],
                "filenameDate": data["filenameDate"],
                "filenameVersion": data["filenameVersion"],
                "summaryShortTr": data["summaryShortTr"],
                "summaryShortEn": data["summaryShortEn"],
                "summaryLongTr": data["summaryLongTr"],
                "summaryLongEn": data["summaryLongEn"],
                "headings": data["headings"] ?? [],
                "keywords": data["keywords"] ?? [],
                "topics": data["topics"] ?? [],
                "explanationTr": data["explanationTr"],
                "explanationEn": data["explanationEn"],
              };

              return Card(
                child: ListTile(
                  title: Text(data["filename"] ?? "-"),
                  subtitle: Text(predictedClass ?? "-"),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AnalysisDetailPage(result: result),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
