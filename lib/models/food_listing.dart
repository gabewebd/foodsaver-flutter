import 'dart:typed_data';

// Velasquez: Lead model natin 'to, wag niyo basta-basta babaguhin. 
// Mark Dave, paki-update if may kailangan sa sustainability metrics.
// Camus, paki-check pre kung okay yung naming convention natin dito sa model.
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
  // final DateTime? claimedAt; // Velasquez: Temporary disabled pre hangga't wala pang column sa DB.
  final bool isStrayFeed; // Velasquez: New feature para sa stray animals.

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
    // this.claimedAt,
    this.isStrayFeed = false,
  });

  factory FoodListing.fromJson(Map<String, dynamic> json) {
    return FoodListing(
      entryId: json['entry_id'].toString(),
      grabTitle: json['grab_title'] ?? '',
      backstory: json['backstory'] ?? '',
      timeWindow: json['time_window_text'] ?? '',
      dropDistance: json['drop_distance'] ?? '',
      meetupSpot: json['meetup_spot'] ?? '',
      posterAlias: json['poster_alias'] ?? '',
      posterAvatarUrl: json['poster_avatar_url'],
      userId: json['user_id'],
      claimerId: json['claimer_id'],
      offlineImage: json['image_url'] ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isClaimed: json['is_claimed'] ?? false,
      isCompleted: json['is_completed'] ?? false,
      claimerName: json['claimer_name'],
      category: json['category'],
      expiryDate: json['time_window'] != null 
          ? DateTime.tryParse(json['time_window'].toString())
          : null,
      // claimedAt: json['claimed_at'] != null 
      //     ? DateTime.tryParse(json['claimed_at'].toString())
      //     : null,
      isStrayFeed: json['is_stray_feed'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'grab_title': grabTitle,
      'backstory': backstory,
      'time_window_text': timeWindow,
      'drop_distance': dropDistance,
      'meetup_spot': meetupSpot,
      'poster_alias': posterAlias,
      'poster_avatar_url': posterAvatarUrl,
      'user_id': userId,
      'image_url': offlineImage,
      'is_claimed': isClaimed,
      'is_completed': isCompleted,
      'category': category,
      'time_window': expiryDate?.toIso8601String(),
      // 'claimed_at': claimedAt?.toIso8601String(),
      'is_stray_feed': isStrayFeed,
    };
  }
}
