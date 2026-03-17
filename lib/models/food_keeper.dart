import 'dart:convert';

// Velasquez, ito yung blueprint natin para sa USDA FoodKeeper data.
// Binase ko 'to sa JSON structure na nakuha natin online. 
class FoodKeeperProduct {
  final String id;
  final String productName;
  final String categoryName;
  final String? pantryTips;
  final String? refrigerateDuration;
  final String? freezeDuration;

  FoodKeeperProduct({
    required this.id,
    required this.productName,
    required this.categoryName,
    this.pantryTips,
    this.refrigerateDuration,
    this.freezeDuration,
  });

  // Aguiluz: Update natin 'to para maging flexible sa kahit anong JSON structure.
  factory FoodKeeperProduct.fromJson(Map<String, dynamic> json) {
    // Subtitle handling para mas detalyado yung tip
    final subtitle = json['name_subtitle'] ?? json['Name_subtitle'];
    final name = json['name'] ?? json['Name'] ?? 'Unknown Product';
    final fullProductName = subtitle != null ? '$name ($subtitle)' : name;

    // Mapping for Durations (pwedeng iba-iba yung keys depende sa source)
    final refrigerate = json['from_date_of_purchase_refrigerate_output_display_only'] ?? 
                        _formatDuration(json, 'DOP_Refrigerate');
    
    final freeze = json['from_date_of_purchase_freeze_output_display_only'] ?? 
                   _formatDuration(json, 'DOP_Freeze');

    final pantry = json['pantry_tips'] ?? json['Pantry_tips'];

    return FoodKeeperProduct(
      id: (json['id'] ?? json['ID'] ?? '0').toString(),
      productName: fullProductName,
      categoryName: (json['category_name_display_only'] ?? json['Category_ID'] ?? 'General').toString(),
      pantryTips: pantry?.toString(),
      refrigerateDuration: refrigerate,
      freezeDuration: freeze,
    );
  }

  // Helper para i-combine yung Min, Max, at Metric sa raw sheets
  static String? _formatDuration(Map<String, dynamic> json, String prefix) {
    final min = json['${prefix}_Min'];
    final max = json['${prefix}_Max'];
    final metric = json['${prefix}_Metric'];
    
    if (min == null && max == null) return null;
    if (min == max) return '$min $metric';
    return '$min-$max $metric';
  }

  // Helper para sa magandang format ng tip
  String get shelfLifeDescription {
    List<String> tips = [];
    if (refrigerateDuration != null) tips.add('Ref: $refrigerateDuration');
    if (freezeDuration != null) tips.add('Freeze: $freezeDuration');
    if (pantryTips != null) tips.add(pantryTips!);
    
    return tips.isEmpty ? 'Check food label for safety.' : tips.join(' | ');
  }
}
