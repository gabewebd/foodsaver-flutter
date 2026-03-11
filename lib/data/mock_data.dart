import 'package:flutter/foundation.dart'; // Velasquez, kailangan natin 'to para sa ValueNotifier.

// Velasquez: dito yung blueprint ng data natin para sa FoodSaver.
// Gawa muna tayo ng mock data para may ma-display si Aguiluz sa Home Feed.
// Velasquez: Ginawa ko na itong centralized mutable list para pag nag-post si Velasquez, 
// automatic na lalabas sa Home Feed ni Aguiluz. OK?

class FoodListing {
  final String entryId;
  final String grabTitle;
  final String backstory;
  final String timeWindow;
  final String dropDistance;
  final String meetupSpot;
  final String posterAlias;
  final String offlineImage;

  FoodListing({
    required this.entryId,
    required this.grabTitle,
    required this.backstory,
    required this.timeWindow,
    required this.dropDistance,
    required this.meetupSpot,
    required this.posterAlias,
    required this.offlineImage,
  });

  // Velasquez: Eto yung centralized "mutable list in memory".
  // Ginamit natin ang ValueNotifier para makapag-listen yung UI sa mga updates.
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

  // Maintain natin itong method pero point na lang sa notifier value.
  static List<FoodListing> fetchMockData() {
    return foodListNotifier.value;
  }

  // Velasquez: Logic para mag-add ng bagong item sa global state.
  static void addListing(FoodListing newListing) {
    foodListNotifier.value = [...foodListNotifier.value, newListing];
  }
}

// Yamaguchi: Dito ko nilagay yung Alerts logic natin. 
// Para 'to sa dynamic list mo sa Alerts Screen.
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
      AlertListing(
        alertId: 'al_002',
        type: AlertType.nearby,
        title: 'New Item Nearby',
        description: 'Fresh bread available in Building C',
        timeAgo: '15 min ago',
        isNew: true,
      ),
      AlertListing(
        alertId: 'al_003',
        type: AlertType.follower,
        title: 'New Follower',
        description: 'John started following your posts',
        timeAgo: '1 hour ago',
      ),
      AlertListing(
        alertId: 'al_004',
        type: AlertType.expiry,
        title: 'Expiry Alert',
        description: 'Your yogurt expires in 2 days',
        timeAgo: '3 hours ago',
      ),
    ];
  }
}
