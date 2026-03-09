// lib/data/mock_data.dart

// Velasquez: dito yung blueprint ng data natin para sa FoodSaver.
// Gawa muna tayo ng mock data para may ma-display si Aguiluz sa Home Feed
// MVP lang to OK?

class FoodListing {
  final String entryId;
  final String grabTitle;
  final String backstory;
  final String timeWindow;
  final String dropDistance;
  final String meetupSpot;
  final String posterAlias;
  final String offlineImage;

  // Standard constructor natin
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

  // Dummy data list natin. Velasquez: pwede nyo pa to dagdagan kung gusto nyo
  // para makita kung pano mag-scroll yung feed mamaya.
  
  // NOTE: Changed this to a method instead of a static property 
  // to make it cleaner when we eventually connect the real API ha
  static List<FoodListing> fetchMockData() {
    return [
      FoodListing(
        entryId: 'fs_001_pasta',
        grabTitle: 'Pasta Sauce (Unopened)',
        backstory: '3 jars of organic pasta sauce, unopened. Best before next week! Kuripot mode on.',
        timeWindow: 'Urgent',
        dropDistance: '0.1 mi',
        meetupSpot: 'Building A, Apt 105',
        posterAlias: 'Mark Dave',
        offlineImage: 'assets/images/pasta_sauce.png', // Yamzon, make sure this image exists ah
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
    ];
  }
}