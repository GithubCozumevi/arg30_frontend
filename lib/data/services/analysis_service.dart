import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/analysis_result.dart';

class AnalysisService {
  final String baseUrl = "https://arg30-backend.onrender.com";

  Future<List<AnalysisResult>> classifyDocument({
    required List<http.MultipartFile> files,
  }) async {
    var uri = Uri.parse("$baseUrl/classify/");

    var request = http.MultipartRequest("POST", uri);

    // Backend form-data key isimleri
    request.files.addAll(files);
    request.fields["classes"] = "[]";
    request.fields["summarize"] = "true";
    request.fields["analysis_mode"] = "full";

    var response = await request.send();

    if (response.statusCode == 200) {
      final body = await response.stream.bytesToString();
      final jsonBody = jsonDecode(body);

      List resultList = jsonBody["results"];

      return resultList.map((e) => AnalysisResult.fromJson(e)).toList();
    } else {
      throw Exception("Analysis failed: ${response.statusCode}");
    }
  }
}
