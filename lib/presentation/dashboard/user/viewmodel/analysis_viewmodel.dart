import 'package:flutter/material.dart';
import '../../../../data/models/analysis_result.dart';
import '../../../../data/services/analysis_service.dart';
import 'package:http/http.dart' as http;

class AnalysisViewModel extends ChangeNotifier {
  final AnalysisService _service = AnalysisService();

  bool isLoading = false;
  List<AnalysisResult> results = [];

  Future<void> analyzeFiles(List<http.MultipartFile> files) async {
    isLoading = true;
    notifyListeners();

    try {
      results = await _service.classifyDocument(files: files);
    } catch (e) {
      print("Error: $e");
    }

    isLoading = false;
    notifyListeners();
  }
}
