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

  // Helper para linisin yung HTML tags at redundant headers sa summary
  String get cleanSummary {
    // 1. Tanggalin muna yung HTML tags (<p>, etc.)
    String text = summary.replaceAll(RegExp(r'<[^>]*>|&nbsp;'), ' ').trim();
    
    // 2. Tanggalin yung common news location/date headers (e.g., "WASHINGTON, March 13, 2026 – ")
    // Naghahanap tayo ng pattern na nagtatapos sa " – " or " -- "
    final headerDashIndex = text.indexOf(' – ');
    if (headerDashIndex != -1 && headerDashIndex < 100) {
      text = text.substring(headerDashIndex + 3).trim();
    }
    
    return text;
  }

  // Getter para sa mas maikling title na hindi paulit-ulit yung "FSIS Issues..."
  String get shortTitle {
    String t = title;
    // Tanggalin yung common prefixes para diretso sa point
    t = t.replaceFirst(RegExp(r'FSIS Issues (a )?Public Health Alert For ', caseSensitive: false), '');
    t = t.replaceFirst(RegExp(r'FSIS Issues (a )?Recall For ', caseSensitive: false), '');
    
    // Capitalize first letter kung sakali
    if (t.isNotEmpty) {
      t = t[0].toUpperCase() + t.substring(1);
    }
    return t;
  }
}
