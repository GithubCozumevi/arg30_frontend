import 'package:arg30_frontend/presentation/dashboard/user/pages/analysis_detail_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text("Giriş yapılmadı")));
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
        title: const Text("Geçmiş Analizler"),
        backgroundColor: const Color(0xFF592EC3),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Bir hata oluştu: ${snapshot.error}"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF592EC3)),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(child: Text("Henüz kayıtlı analiz yok."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;

              return Card(
                child: ListTile(
                  title: Text(data["filename"] ?? "-"),
                  subtitle: Text(data["predictedClassTr"] ?? "-"),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Firestore kaydını → AnalysisDetailPage formatına çeviriyoruz
                    final result = {
                      "filename": data["filename"],
                      "predicted_class_tr": data["predictedClassTr"],
                      "filename_date": data["filenameDate"],
                      "filename_version": data["filenameVersion"],
                      "summary_short_tr": data["summaryShortTr"],
                      "summary_long_tr": data["summaryLongTr"],
                      "headings": data["headings"] ?? [],
                      "keywords": data["keywords"] ?? [],
                    };

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
