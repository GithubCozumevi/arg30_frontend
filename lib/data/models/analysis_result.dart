class AnalysisResult {
  final String filename;
  final String predictedClassEn;
  final String predictedClassTr;
  final double confidenceClass;
  final List<String> contentDates;
  final double contentDatesConfidence;
  final List<String> contentVersions;
  final double contentVersionsConfidence;
  final List<String> keywords;
  final List<String> headings;
  final List<String> topics;
  final String summaryShortEn;
  final String summaryShortTr;
  final String summaryLongEn;
  final String summaryLongTr;
  final String explanationEn;
  final String explanationTr;
  final String filenameDate;
  final String filenameVersion;

  AnalysisResult({
    required this.filename,
    required this.predictedClassEn,
    required this.predictedClassTr,
    required this.confidenceClass,
    required this.contentDates,
    required this.contentDatesConfidence,
    required this.contentVersions,
    required this.contentVersionsConfidence,
    required this.keywords,
    required this.headings,
    required this.topics,
    required this.summaryShortEn,
    required this.summaryShortTr,
    required this.summaryLongEn,
    required this.summaryLongTr,
    required this.explanationEn,
    required this.explanationTr,
    required this.filenameDate,
    required this.filenameVersion,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      filename: json["filename"] ?? "",
      predictedClassEn: json["predicted_class_en"] ?? "",
      predictedClassTr: json["predicted_class_tr"] ?? "",
      confidenceClass: (json["confidence_class"] ?? 0).toDouble(),
      contentDates: List<String>.from(json["content_dates"] ?? []),
      contentDatesConfidence:
          (json["content_dates_confidence"] ?? 0).toDouble(),
      contentVersions: List<String>.from(json["content_versions"] ?? []),
      contentVersionsConfidence:
          (json["content_versions_confidence"] ?? 0).toDouble(),
      keywords: List<String>.from(json["keywords"] ?? []),
      headings: List<String>.from(json["headings"] ?? []),
      topics: List<String>.from(json["topics"] ?? []),
      summaryShortEn: json["summary_short_en"] ?? "",
      summaryShortTr: json["summary_short_tr"] ?? "",
      summaryLongEn: json["summary_long_en"] ?? "",
      summaryLongTr: json["summary_long_tr"] ?? "",
      explanationEn: json["explanation_en"] ?? "",
      explanationTr: json["explanation_tr"] ?? "",
      filenameDate: json["filename_date"] ?? "",
      filenameVersion: json["filename_version"] ?? "",
    );
  }
}
