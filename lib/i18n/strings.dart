import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../presentation/settings/language_provider.dart';

final Map<String, Map<String, String>> localizedStrings = {
  "tr": {
    "upload": "Belge Yükle",
    "history": "Geçmiş",
    "settings": "Ayarlar",
    "system_title": "Doküman Sınıflandırma Sistemi",
    "document_analysis": "Doküman Analizi",

    "upload_document": "Belgenizi Yükleyin",
    "upload_description":
        "ARG30, belgeyi otomatik olarak sınıflandırır ve özetler.",
    "choose_file": "Dosya Seç",

    "optional_classes": "Belge Sınıfları (Opsiyonel)",
    "advanced_settings": "Gelişmiş Ayarlar",
    "summarize": "Özet Çıkar (Summarize)",
    "analysis_mode": "Analiz Modu",

    "mode_short": "Hızlı (Short)",
    "mode_medium": "Standart (Medium)",
    "mode_full": "Derin Analiz (Full)",

    "evaluate": "Değerlendir",
    "select_file_warning": "Lütfen bir dosya seçin.",
    "error_occurred": "Bir hata oluştu.",

    // HISTORY PAGE
    "history_title": "Geçmiş Analizler",
    "history_empty": "Henüz kayıtlı analiz yok.",
    "history_error": "Bir hata oluştu:",

    // DETAIL PAGE LABELS
    "detail_class": "Belge Türü",
    "detail_date": "Tarih (Dosya Adı)",
    "detail_version": "Versiyon (Dosya Adı)",

    "detail_short_summary": "Kısa Özet",
    "detail_long_summary": "Uzun Özet",

    "detail_headings": "Başlıklar",
    "detail_keywords": "Anahtar Kelimeler",
    "detail_topics": "Konular",
    "detail_explanation": "Açıklama",

    "classes_offer": "Teklif",
    "classes_contract": "Sözleşme",
    "classes_invoice": "Fatura",
    "classes_rd": "Ar-Ge Projesi",
    "classes_meeting": "Toplantı Özeti",
    "classes_techdoc": "Teknik Doküman",
    "classes_report": "Rapor",
    "classes_tender": "İhale Dokümanı",
    "classes_presentation": "Sunum",
    "classes_policy": "Politika / Prosedür",
  },

  "en": {
    "upload": "Upload Document",
    "history": "History",
    "settings": "Settings",
    "system_title": "Document Classification System",
    "document_analysis": "Document Analysis",

    "upload_document": "Upload Your Document",
    "upload_description":
        "ARG30 automatically classifies and summarizes the uploaded file.",
    "choose_file": "Choose File",

    "optional_classes": "Document Classes (Optional)",
    "advanced_settings": "Advanced Settings",
    "summarize": "Extract Summary",
    "analysis_mode": "Analysis Mode",

    "mode_short": "Fast (Short)",
    "mode_medium": "Standard (Medium)",
    "mode_full": "Deep Analysis (Full)",

    "evaluate": "Evaluate",
    "select_file_warning": "Please select a file.",
    "error_occurred": "An error occurred.",

    // HISTORY PAGE
    "history_title": "Analysis History",
    "history_empty": "No saved analyses yet.",
    "history_error": "An error occurred:",

    // DETAIL PAGE LABELS
    "detail_class": "Document Type",
    "detail_date": "Date (From Filename)",
    "detail_version": "Version (From Filename)",

    "detail_short_summary": "Short Summary",
    "detail_long_summary": "Long Summary",

    "detail_headings": "Headings",
    "detail_keywords": "Keywords",
    "detail_topics": "Topics",
    "detail_explanation": "Explanation",

    "classes_offer": "Offer",
    "classes_contract": "Contract",
    "classes_invoice": "Invoice",
    "classes_rd": "R&D Project",
    "classes_meeting": "Meeting Summary",
    "classes_techdoc": "Technical Document",
    "classes_report": "Report",
    "classes_tender": "Tender Document",
    "classes_presentation": "Presentation",
    "classes_policy": "Policy / Procedure",
  },
};

String translate(BuildContext context, String key) {
  final lang = Provider.of<LanguageProvider>(context).lang;
  return localizedStrings[lang]?[key] ?? key;
}
