// ignore_for_file: use_build_context_synchronously

import 'dart:typed_data';
import 'dart:convert';
import 'dart:html' as html;

import 'package:arg30_frontend/i18n/strings.dart';
import 'package:arg30_frontend/presentation/core/layout/main_layout.dart';
import 'package:arg30_frontend/presentation/settings/language_provider.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';

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

  List<String> availableClasses(BuildContext context) => [
    translate(context, "classes_offer"),
    translate(context, "classes_contract"),
    translate(context, "classes_invoice"),
    translate(context, "classes_rd"),
    translate(context, "classes_meeting"),
    translate(context, "classes_techdoc"),
    translate(context, "classes_report"),
    translate(context, "classes_tender"),
    translate(context, "classes_presentation"),
    translate(context, "classes_policy"),
  ];

  // ---------------------------------------------------------------------------
  // FILE PICKER
  // ---------------------------------------------------------------------------
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

  // ---------------------------------------------------------------------------
  // ANALYZE + FIRESTORE SAVE
  // ---------------------------------------------------------------------------
  Future<void> evaluateDocument() async {
    if (selectedBytes == null || selectedFilename == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(translate(context, "select_file_warning"))),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("Not logged in");

      // Firebase Storage upload
      final storageRef = FirebaseStorage.instance.ref().child(
        "uploads/${user.uid}/${DateTime.now().millisecondsSinceEpoch}_${selectedFilename}",
      );

      await storageRef.putData(selectedBytes!);
      final fileUrl = await storageRef.getDownloadURL();

      // Backend request payload
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

      await _saveToFirestore(user.uid, fileUrl, apiResults);
    } catch (e, s) {
      debugPrint("🔥 $e\n$s");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(translate(context, "error_occurred"))),
      );
    }

    setState(() => isLoading = false);
  }

  Future<void> _saveToFirestore(
    String userId,
    String fileUrl,
    List<dynamic> results,
  ) async {
    final analysesRef = FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("analyses");

    for (final item in results) {
      final data = item as Map<String, dynamic>;

      await analysesRef.add({
        "userId": userId,
        "fileUrl": fileUrl,

        // UI / Firestore alan isimleri (camelCase)
        "filename": data["filename"],
        "predictedClassTr": data["predicted_class_tr"],
        "predictedClassEn": data["predicted_class_en"],
        "confidenceClass": data["confidence_class"],

        "filenameDate": data["filename_date"],
        "filenameVersion": data["filename_version"],

        "summaryShortTr": data["summary_short_tr"],
        "summaryShortEn": data["summary_short_en"],
        "summaryLongTr": data["summary_long_tr"],
        "summaryLongEn": data["summary_long_en"],

        "headings": data["headings"] ?? [],
        "keywords": data["keywords"] ?? [],
        "topics": data["topics"] ?? [],

        "explanationTr": data["explanation_tr"],
        "explanationEn": data["explanation_en"],

        "createdAt": FieldValue.serverTimestamp(),
      });
    }
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    Provider.of<LanguageProvider>(context).lang;

    return MainLayout(
      titleKey: "document_analysis",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _uploadCard(context),
          const SizedBox(height: 20),
          _classSelectorCard(context),
          const SizedBox(height: 20),
          _advancedSettingsCard(context),
          const SizedBox(height: 20),
          _evaluateButton(context),
          const SizedBox(height: 20),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(color: Color(0xFF592EC3)),
            ),
          if (!isLoading) _resultsList(context),
        ],
      ),
    );
  }

  // ---------------- UPLOAD CARD ----------------
  Widget _uploadCard(BuildContext context) {
    return _sectionCard(
      context,
      child: Column(
        children: [
          const Icon(Icons.cloud_upload, size: 60, color: Color(0xFF592EC3)),
          const SizedBox(height: 12),

          Text(
            translate(context, "upload_document"),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          Text(
            translate(context, "upload_description"),
            style: const TextStyle(color: Colors.black54),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: pickFile,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF592EC3),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            ),
            child: Text(translate(context, "choose_file")),
          ),

          if (selectedFilename != null) ...[
            const SizedBox(height: 12),
            Text(selectedFilename!),
          ],
        ],
      ),
    );
  }

  // ---------------- CLASS SELECTOR ----------------
  Widget _classSelectorCard(BuildContext context) {
    return _sectionCard(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            translate(context, "optional_classes"),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                availableClasses(context).map((c) {
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
    );
  }

  // ---------------- ADVANCED SETTINGS ----------------
  Widget _advancedSettingsCard(BuildContext context) {
    return _sectionCard(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            translate(context, "advanced_settings"),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(translate(context, "summarize")),
              Switch(
                value: summarize,
                onChanged: (v) => setState(() => summarize = v),
                activeColor: const Color(0xFF592EC3),
              ),
            ],
          ),

          const SizedBox(height: 25),

          Text(translate(context, "analysis_mode")),
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
              underline: const SizedBox.shrink(),
              items: [
                DropdownMenuItem(
                  value: "short",
                  child: Text(translate(context, "mode_short")),
                ),
                DropdownMenuItem(
                  value: "medium",
                  child: Text(translate(context, "mode_medium")),
                ),
                DropdownMenuItem(
                  value: "full",
                  child: Text(translate(context, "mode_full")),
                ),
              ],
              onChanged: (value) => setState(() => readMode = value!),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- ANALYSIS RESULT LIST ----------------
  Widget _resultsList(BuildContext context) {
    if (results.isEmpty) return const SizedBox();

    final lang = Localizations.localeOf(context).languageCode;

    return Column(
      children:
          results.map((item) {
            final classLabel =
                lang == "tr"
                    ? item["predicted_class_tr"]
                    : item["predicted_class_en"];

            return Card(
              child: ListTile(
                title: Text(item["filename"]),
                subtitle: Text(classLabel ?? "-"),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  final mapped = _mapBackendToUi(item as Map<String, dynamic>);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AnalysisDetailPage(result: mapped),
                    ),
                  );
                },
              ),
            );
          }).toList(),
    );
  }

  // ---------------- SECTION WRAPPER ----------------
  Widget _sectionCard(BuildContext context, {required Widget child}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(padding: const EdgeInsets.all(20), child: child),
    );
  }

  Widget _evaluateButton(BuildContext context) {
    return ElevatedButton(
      onPressed: selectedBytes == null ? null : evaluateDocument,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF592EC3),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
      ),
      child: Text(translate(context, "evaluate")),
    );
  }

  Map<String, dynamic> _mapBackendToUi(Map<String, dynamic> data) {
    return {
      "filename": data["filename"],
      "predictedClassTr": data["predicted_class_tr"],
      "predictedClassEn": data["predicted_class_en"],
      "confidenceClass": data["confidence_class"],

      "filenameDate": data["filename_date"],
      "filenameVersion": data["filename_version"],

      "summaryShortTr": data["summary_short_tr"],
      "summaryShortEn": data["summary_short_en"],
      "summaryLongTr": data["summary_long_tr"],
      "summaryLongEn": data["summary_long_en"],

      "headings": data["headings"] ?? [],
      "keywords": data["keywords"] ?? [],
      "topics": data["topics"] ?? [],

      "explanationTr": data["explanation_tr"],
      "explanationEn": data["explanation_en"],
    };
  }
}
