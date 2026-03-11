import 'package:flutter/foundation.dart'; // Velasquez, kailangan natin 'to para sa ValueNotifier at Uint8List.

// Velasquez: Ito yung updated blueprint natin.
// Nag-add ako ng 'imageBytes' para pag may pinick si user, yun ang gagamitin.
// Pag wala, fallback tayo sa 'offlineImage' na asset path.
class FoodListing {
  final String entryId;
  final String grabTitle;
  final String backstory;
  final String timeWindow;
  final String dropDistance;
  final String meetupSpot;
  final String posterAlias;
  final String offlineImage;
  final Uint8List? imageBytes; // Velasquez, ito yung key para sa dynamic images!

  FoodListing({
    required this.entryId,
    required this.grabTitle,
    required this.backstory,
    required this.timeWindow,
    required this.dropDistance,
    required this.meetupSpot,
    required this.posterAlias,
    required this.offlineImage,
    this.imageBytes,
  });

  // Velasquez: Centralized list natin na reactive.
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
    ),
    FoodListing(
      entryId: 'fs_003_fruits',
      grabTitle: 'Organic Oranges',
      backstory: 'Extra oranges from the province. Get it before it goes bad guys.',
      timeWindow: '12 hours',
      dropDistance: '1.1 mi',
      meetupSpot: 'Building C, Apt 205',
      posterAlias: 'Josh Aguiluz',
      offlineImage: 'assets/images/oranges.png',
    ),
  ]);

  static void addListing(FoodListing newListing) {
    // Velasquez: Spread operator para ma-trigger yung ValueNotifier refresh.
    foodListNotifier.value = [...foodListNotifier.value, newListing];
  }
}

// Yamaguchi: Standard alerts logic, no changes needed here yet.
enum AlertType { claim, nearby, follower, expiry }
class AlertListing {
  final String alertId;
  final AlertType type;
  final String title;
  final String description;
  final String timeAgo;
  final bool isNew;
  final bool hasActions;

  AlertListing({
    required this.alertId,
    required this.type,
    required this.title,
    required this.description,
    required this.timeAgo,
    this.isNew = false,
    this.hasActions = false,
  });

  static List<AlertListing> fetchMockAlerts() {
    return [
      AlertListing(
        alertId: 'al_001',
        type: AlertType.claim,
        title: 'Item Claimed!',
        description: 'Aguiluz claimed your "Pasta Sauce"',
        timeAgo: '2 min ago',
        isNew: true,
        hasActions: true,
      ),
    ];
  }
}
