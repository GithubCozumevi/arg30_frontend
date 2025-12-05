// ignore_for_file: use_build_context_synchronously

import 'dart:typed_data';
import 'dart:convert';
import 'dart:html' as html;

import 'package:arg30_frontend/presentation/history/history_pages.dart';
import 'package:arg30_frontend/presentation/settings/settings_page.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'analysis_detail_page.dart';

class UserDashboardPage extends StatefulWidget {
  const UserDashboardPage({super.key});

  @override
  State<UserDashboardPage> createState() => _UserDashboardPageState();
}

class _UserDashboardPageState extends State<UserDashboardPage> {
  bool isLoading = false;
  List<dynamic> results = [];

  String? selectedFilename;
  Uint8List? selectedBytes;

  List<String> selectedClasses = [];
  bool summarize = true;
  String readMode = "short";

  final dio = Dio(BaseOptions(baseUrl: "https://arg30-backend.onrender.com"));

  final List<String> availableClasses = [
    "Teklif",
    "Sözleşme",
    "Fatura",
    "Ar-Ge Projesi",
    "Toplantı Özeti",
    "Teknik Doküman",
    "Rapor",
    "İhale Dokümanı",
    "Sunum",
    "Politika / Prosedür",
  ];

  // ------------------------------------------------------------
  // DOSYA SEÇ
  // ------------------------------------------------------------
  Future<void> pickFile() async {
    setState(() {
      selectedFilename = null;
      selectedBytes = null;
    });

    if (kIsWeb) {
      final upload =
          html.FileUploadInputElement()..accept = ".pdf,.docx,.xlsx,.png,.jpg";
      upload.click();

      upload.onChange.listen((event) {
        final file = upload.files?.first;
        if (file == null) return;

        final reader = html.FileReader();
        reader.readAsArrayBuffer(file);

        reader.onLoadEnd.listen((event) {
          setState(() {
            selectedBytes = reader.result as Uint8List;
            selectedFilename = file.name;
          });
        });
      });

      return;
    }

    final picked = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      withData: true,
      allowedExtensions: ["pdf", "docx", "xlsx", "png", "jpg"],
      type: FileType.custom,
    );

    if (picked == null) return;

    setState(() {
      selectedBytes = picked.files.first.bytes;
      selectedFilename = picked.files.first.name;
    });
  }

  // ------------------------------------------------------------
  // 🔥 FULL MODE: STORAGE + BACKEND + FIRESTORE
  // ------------------------------------------------------------
  Future<void> evaluateDocument() async {
    if (selectedBytes == null || selectedFilename == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Lütfen bir dosya seçin.")));
      return;
    }

    setState(() => isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("Kullanıcı giriş yapmamış!");

      // ------------------------------------------
      // 1) STORAGE'A YÜKLE
      // ------------------------------------------
      final storageRef = FirebaseStorage.instance.ref().child(
        "uploads/${user.uid}/${DateTime.now().millisecondsSinceEpoch}_${selectedFilename}",
      );

      await storageRef.putData(selectedBytes!);

      final fileUrl = await storageRef.getDownloadURL();

      // ------------------------------------------
      // 2) BACKEND’E GÖNDER
      // ------------------------------------------
      final classPayload =
          selectedClasses.map((c) => {"name": c, "description": ""}).toList();

      final formData = FormData.fromMap({
        "classes": jsonEncode(classPayload),
        "summarize": summarize.toString(),
        "read_mode": readMode,
        "files": MultipartFile.fromBytes(
          selectedBytes!,
          filename: selectedFilename,
        ),
      });

      final response = await dio.post("/classify/", data: formData);

      final apiResults = response.data["results"] ?? [];

      setState(() => results = apiResults);

      // ------------------------------------------
      // 3) FIRESTORE'A KAYDET
      // ------------------------------------------
      await _saveToFirestore(user.uid, fileUrl, apiResults);
    } catch (e, stack) {
      debugPrint("🔥 API ERROR:\n➡ $e\n➡ STACK: $stack");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Analiz sırasında hata oluştu.")),
      );
    }

    setState(() => isLoading = false);
  }

  // ------------------------------------------------------------
  // FIRESTORE DATABASE KAYIT
  // ------------------------------------------------------------
  Future<void> _saveToFirestore(
    String userId,
    String fileUrl,
    List<dynamic> results,
  ) async {
    final userRef = FirebaseFirestore.instance.collection("users").doc(userId);
    final analysesRef = userRef.collection("analyses");

    for (final item in results) {
      final data = item as Map<String, dynamic>;

      await analysesRef.add({
        "userId": userId,
        "fileUrl": fileUrl,
        "filename": data["filename"],
        "predictedClassTr": data["predicted_class_tr"],
        "predictedClassEn": data["predicted_class_en"],
        "confidenceClass": data["confidence_class"],
        "filenameDate": data["filename_date"],
        "filenameVersion": data["filename_version"],
        "summaryShortTr": data["summary_short_tr"],
        "summaryLongTr": data["summary_long_tr"],
        "headings": data["headings"] ?? [],
        "keywords": data["keywords"] ?? [],
        "topics": data["topics"] ?? [],
        "raw": data,
        "createdAt": FieldValue.serverTimestamp(),
      });
    }

    debugPrint("✅ Firestore’a analiz + dosya URL’i kaydedildi.");
  }

  // UI ------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF592EC3),
        centerTitle: true,
        title: const Text(
          "ARG30 - Kullanıcı Paneli",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HistoryPage()),
                ),
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsPage()),
                ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _uploadCard(),
            const SizedBox(height: 20),
            _classSelectorCard(),
            const SizedBox(height: 20),
            _advancedSettingsCard(),
            const SizedBox(height: 20),
            _evaluateButton(),
            const SizedBox(height: 20),
            if (isLoading)
              const CircularProgressIndicator(color: Color(0xFF592EC3)),
            if (!isLoading) _resultsList(),
          ],
        ),
      ),
    );
  }

  Widget _uploadCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.cloud_upload, size: 60, color: Color(0xFF592EC3)),
            const SizedBox(height: 12),
            const Text(
              "Belgenizi yükleyin",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "ARG30, yüklediğiniz belgeleri yapay zeka ile sınıflandırır ve özetler.",
              style: TextStyle(color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: pickFile,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF592EC3),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
              ),
              child: const Text("Dosya Seç"),
            ),
            if (selectedFilename != null) ...[
              const SizedBox(height: 12),
              Text("Seçilen dosya: $selectedFilename"),
            ],
          ],
        ),
      ),
    );
  }

  Widget _classSelectorCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Belge Sınıfları (Opsiyonel)",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  availableClasses.map((c) {
                    final isSelected = selectedClasses.contains(c);

                    return ChoiceChip(
                      label: Text(c),
                      selected: isSelected,
                      selectedColor: const Color(0xFF592EC3),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                      onSelected: (_) {
                        setState(() {
                          isSelected
                              ? selectedClasses.remove(c)
                              : selectedClasses.add(c);
                        });
                      },
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _advancedSettingsCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Gelişmiş Ayarlar",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Özet Çıkar (Summarize)",
                  style: TextStyle(fontSize: 16),
                ),
                Switch(
                  value: summarize,
                  onChanged: (v) => setState(() => summarize = v),
                  activeColor: const Color(0xFF6C4DFF),
                ),
              ],
            ),

            const SizedBox(height: 25),

            const Text("Analiz Modu", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButton<String>(
                value: readMode,
                isExpanded: true,
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(
                    value: "short",
                    child: Text("Hızlı (Short)"),
                  ),
                  DropdownMenuItem(
                    value: "medium",
                    child: Text("Standart (Medium)"),
                  ),
                  DropdownMenuItem(
                    value: "full",
                    child: Text("Derin Analiz (Full)"),
                  ),
                ],
                onChanged: (value) => setState(() => readMode = value!),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _evaluateButton() {
    return ElevatedButton(
      onPressed: selectedBytes == null ? null : evaluateDocument,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF592EC3),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
      ),
      child: const Text("Değerlendir"),
    );
  }

  Widget _resultsList() {
    if (results.isEmpty) return const SizedBox();

    return Column(
      children:
          results.map((item) {
            return Card(
              child: ListTile(
                title: Text(item["filename"]),
                subtitle: Text(item["predicted_class_tr"] ?? "-"),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AnalysisDetailPage(result: item),
                    ),
                  );
                },
              ),
            );
          }).toList(),
    );
  }
}
