import 'package:flutter/foundation.dart'; 

// Velasquez: Ito yung updated blueprint natin para sa mga pagkain.
// Ginamit natin yung 'Uint8List' para sa real-time image preview bago i-upload.
class FoodListing {
  final String entryId;
  final String grabTitle;
  final String backstory;
  final String timeWindow;
  final String dropDistance;
  final String meetupSpot;
  final String posterAlias;
  final String? posterAvatarUrl; // Velasquez: Optional 'to para iwas null pointer.
  final String? userId; 
  final String? claimerId; 
  final String offlineImage;
  final Uint8List? imageBytes; // Velasquez: Preview muna pre bago i-upload.
  final String? claimerName;
  final String? category; 
  final DateTime? expiryDate; 

  FoodListing({
    required this.entryId,
    required this.grabTitle,
    required this.backstory,
    required this.timeWindow,
    required this.dropDistance,
    required this.meetupSpot,
    required this.posterAlias,
    this.posterAvatarUrl, 
    this.userId, 
    this.claimerId, 
    required this.offlineImage,
    this.imageBytes,
    required this.createdAt,
    this.isClaimed = false, 
    this.isCompleted = false, // New
    this.claimerName,
    this.category,
    this.expiryDate,
  });

  // Velasquez: Centralized list natin na reactive.
  // Pero sa production, dapat direct hila na to sa Supabase stream ni Aguiluz.
  static final ValueNotifier<List<FoodListing>> foodListNotifier = ValueNotifier<List<FoodListing>>([
    FoodListing(
      entryId: 'fs_001_pasta',
      grabTitle: 'Pasta Sauce (Unopened)',
      backstory: '3 jars of organic pasta sauce, unopened. Best before next week! Kuripot mode on.',
      timeWindow: 'Urgent',
      dropDistance: '0.1 mi',
      meetupSpot: 'Building A, Apt 105',
      posterAlias: 'Mark Dave',
      offlineImage: 'assets/images/pasta_sauce.png',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      isClaimed: true, 
      claimerName: 'Aguiluz J.',
      expiryDate: DateTime.now().add(const Duration(days: 2)),
    ),
    FoodListing(
      entryId: 'fs_002_bread',
      grabTitle: 'Fresh Bagels Pack',
      backstory: 'Bought too much for my roommates. Still very soft and safe to eat.',
      timeWindow: '2 Days',
      dropDistance: '0.2 mi',
      meetupSpot: 'Holy Angel University, Canteen area', 
      posterAlias: 'Mika Yamaguchi',
      offlineImage: 'assets/images/bagels.png',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      isClaimed: false, 
      expiryDate: DateTime.now().add(const Duration(days: 5)),
    ),
    FoodListing(
      entryId: 'fs_003_fruits',
      grabTitle: 'Organic Oranges',
      backstory: 'Extra oranges from the province. Get it before it goes bad guys.',
      timeWindow: '12 hours',
      dropDistance: '1.1 mi',
      meetupSpot: 'Building C, Apt 205',
      posterAlias: 'Josh Aguiluz',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      offlineImage: 'assets/images/oranges.png',
      expiryDate: DateTime.now().add(const Duration(hours: 12)),
    ),
  ]);

  static void addListing(FoodListing newListing) {
    foodListNotifier.value = [...foodListNotifier.value, newListing];
  }
}

// Yamaguchi pre, dito mo tignan yung data ng alerts mo.
enum AlertType { claim, nearby, follower, expiry, success, warning }
class AlertListing {
  final String alertId;
  final AlertType type;
  final String title;
  final String description;
  final DateTime createdAt;
  final bool isNew;
  final bool hasActions;
  final String? senderAvatar; // Add sender info for correct avatar display

  AlertListing({
    required this.alertId,
    required this.type,
    required this.title,
    required this.description,
    required this.createdAt,
    this.isNew = false,
    this.hasActions = false,
    this.senderAvatar,
  });

  // Yamaguchi, Mock alerts to para makita yung UI logic natin.
  static List<AlertListing> fetchMockAlerts() {
    return [
      AlertListing(
        alertId: 'al_001',
        type: AlertType.claim,
        title: 'Item Claimed!',
        description: 'Aguiluz claimed your "Pasta Sauce"',
        createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
        isNew: true,
        hasActions: true,
      ),
    ];
  }
}
