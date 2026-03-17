// Velasquez, ito yung model para sa mga food recalls galing sa USDA FSIS.
// Binase ko 'to sa documentation na binigay ni user (Recall-API-documentation.pdf).
class UsdaRecall {
  final String title;
  final String date;
  final String riskLevel;
  final String reason;
  final String summary;

  UsdaRecall({
    required this.title,
    required this.date,
    required this.riskLevel,
    required this.reason,
    required this.summary,
  });

  // Aguiluz: Factory para i-map yung mga "field_" keys galing sa API response.
  factory UsdaRecall.fromJson(Map<String, dynamic> json) {
    return UsdaRecall(
      title: json['field_title'] ?? 'No Title',
      date: json['field_recall_date'] ?? 'Unknown Date',
      riskLevel: json['field_risk_level'] ?? 'N/A',
      reason: json['field_recall_reason'] ?? 'N/A',
      summary: json['field_summary'] ?? '',
    );
  }

  // Helper para linisin yung HTML tags sa summary (kung meron man)
  String get cleanSummary {
    // Basic regex para tanggalin yung <p>, <strong>, etc. na nakita natin sa PDF sample.
    return summary.replaceAll(RegExp(r'<[^>]*>|&nbsp;'), ' ').trim();
  }
}
