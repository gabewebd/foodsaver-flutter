import 'dart:typed_data';

// Velasquez: Lead model natin 'to, wag niyo basta-basta babaguhin. 
// Mark Dave, paki-update if may kailangan sa sustainability metrics.
class FoodListing {
  final String entryId;
  final String grabTitle;
  final String backstory;
  final String timeWindow;
  final String dropDistance;
  final String meetupSpot;
  final String posterAlias;
  final String? posterAvatarUrl; 
  final String? userId; 
  final String? claimerId; 
  final String offlineImage;
  final Uint8List? imageBytes; 
  final DateTime createdAt; 
  final bool isClaimed;
  final bool isCompleted;
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
    this.isCompleted = false,
    this.claimerName,
    this.category,
    this.expiryDate,
  });
}
