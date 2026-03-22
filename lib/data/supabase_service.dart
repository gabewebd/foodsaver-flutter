import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/food_listing.dart';
import '../models/alert_listing.dart';
import 'package:flutter/foundation.dart';
import '../utils/error_utils.dart';

// Velasquez: ito na yung ating final engine!
// Aguiluz, Camus, Yamaguchi, Yamzon: Paki-check yung integration per module!
// Ripped out Supabase Auth completely. We now use custom profiles for everything.
class SupabaseService {
  static final _supabase = Supabase.instance.client;
  static String? currentUserId; // Velasquez: Synchronous auth state para iwas delay.

  // Mark Dave, kailangan nating i-load yung session pag-start ng app.
  // Velasquez: Gamit muna tayo SharedPreferences, sumasablay yung persist ng Supabase SDK sa Edge browser eh.
  static Future<void> initSession() async {
    final prefs = await SharedPreferences.getInstance();
    currentUserId = prefs.getString('foodsaver_user_id');
  }

  static Future<void> _saveSession(String userId) async {
    currentUserId = userId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('foodsaver_user_id', userId);
  }

  // Velasquez: ito yung direct insert logic natin. 2 steps na lang sa UI!
  static Future<String?> registerCustomUser(String email, String password, String fullName, String buildingNo) async {
    try {
      // Mark Dave: itong seed-based avatar ang "hack" natin para may mukha agad si user.
      // Velasquez: Paki-check if slowing down yung registration dahil sa external API call na 'to.
      final avatarUrl = 'https://api.dicebear.com/7.x/initials/png?seed=${Uri.encodeComponent(fullName)}&backgroundColor=0f9d58,e65100,4285f4&textColor=ffffff';

      final response = await _supabase.from('profiles').insert({
        'email': email,
        'password': password, 
        'full_name': fullName,
        'avatar_url': avatarUrl,
        'building_no': buildingNo,
      }).select();

      if (response.isEmpty) return 'Registration failed.';

      final newUser = response.first;
      await _saveSession(newUser['id'].toString());
      return null;
    } catch (e) {
      return ErrorUtils.getFriendlyErrorMessage(e);
    }
  }

  static Future<String?> loginCustomUser(String email, String password) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('email', email)
          .eq('password', password)
          .maybeSingle();

      if (response == null) return 'Invalid email or password.';

      // Velasquez: Save session manually kasi di natin gamit yung auth.user() ni Supabase.
      await _saveSession(response['id'].toString());
      return null;
    } catch (e) {
      return ErrorUtils.getFriendlyErrorMessage(e);
    }
  }

  static Future<void> logoutUser() async {
    currentUserId = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('foodsaver_user_id');
  }

  // Aguiluz, updated postListing para gamitin yung tamang column names sa database.
  static Future<void> postListing(FoodListing item, String? imageUrl) async {
    if (currentUserId == null) throw Exception("User not logged in!");

    // Velasquez: Hinila ko na yung totoong avatar at name sa profiles table bago mag-insert para hindi NULL sa food_listings pre.
    final profile = await _supabase.from('profiles').select('full_name, avatar_url').eq('id', currentUserId!).single();
    final posterAlias = profile['full_name'] ?? 'Anonymous';
    final posterAvatarUrl = profile['avatar_url'];

    await _supabase.from('food_listings').insert({
      'grab_title': item.grabTitle,
      'backstory': item.backstory,
      'meetup_spot': item.meetupSpot,
      'drop_distance': item.dropDistance,
      'poster_alias': posterAlias,
      'poster_avatar_url': posterAvatarUrl,
      'offline_image': imageUrl,
      'is_claimed': false,
      'is_stray_feed': item.isStrayFeed,
      'user_id': currentUserId,
      // Velasquez: Gamit muna tayo ng time_window column kasi di pa tapos migration.
      // Wag niyo babaguhin 'to, masisira yung fetch ni Aguiluz.
      'time_window': item.expiryDate?.toIso8601String() ?? item.timeWindow, 
    });
  }

  static Future<Map<String, int>> getUserMetrics() async {
    if (currentUserId == null) return {'shared': 0, 'claimed': 0};

    final sharedResponse = await _supabase
        .from('food_listings')
        .select()
        .eq('user_id', currentUserId!)
        .count(CountOption.exact);
        
    final claimedResponse = await _supabase
        .from('food_listings')
        .select()
        // Velasquez: Inayos ko na 'to, claimer_id dapat hindi user_id. 
        // Muntik na tayo ma-minus sa defense dahil dito.
        .eq('claimer_id', currentUserId!) 
        .count(CountOption.exact);
    
    return {
      'shared': sharedResponse.count,
      'claimed': claimedResponse.count,
    };
  }

  static Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    if (currentUserId == null) return null;
    try {
      final data = await _supabase
          .from('profiles')
          .select()
          .eq('id', currentUserId!)
          .single();
      return data;
    } catch (e) {
      return null;
    }
  }

  // Yamaguchi, updated stream para sarili mong alerts lang makikita mo.
  static Stream<List<AlertListing>> getAlertsStream() {
    if (currentUserId == null) return const Stream.empty();
    return _supabase
        .from('alerts')
        .stream(primaryKey: ['alert_id'])
        .eq('receiver_id', currentUserId!)
        .order('created_at', ascending: false)
        .asyncMap((data) async {
          final mapped = <AlertListing>[];
          for (final json in data) {
            // Yamaguchi, hila din natin avatar ng sender if available.
            // Velasquez: Medyo "unoptimized" 'to pre kasi loop, pero bahala na muna basta gumana sa presentation.
            // Using a simple select with inFilter for better performance if many alerts
            mapped.add(await _mapJsonToAlertListing(json));
          }
          return mapped;
        });
  }

  static Future<void> markAlertAsRead(String alertId) async {
    await _supabase.from('alerts').update({'is_new': false}).eq('alert_id', alertId);
  }

  static Future<FoodListing?> getFoodListingById(String entryId) async {
    try {
      final json = await _supabase
          .from('food_listings')
          .select('*, profiles!food_listings_user_id_fkey(full_name, avatar_url)')
          .eq('entry_id', entryId)
          .maybeSingle();
      if (json == null) return null;
      return _mapJsonToFoodListing(json);
    } catch (e) {
      return null;
    }
  }

  static Stream<List<FoodListing>> getFoodStream() {
    return _supabase
        .from('food_listings')
        .stream(primaryKey: ['entry_id']) 
        .order('created_at', ascending: false)
        .asyncMap((data) async {
          final ids = data.map((row) => row['entry_id']).toList();
          if (ids.isEmpty) return [];
          
          final joinedData = await _supabase
              .from('food_listings')
              .select('*, profiles!food_listings_user_id_fkey(full_name, avatar_url)')
              .inFilter('entry_id', ids)
              .order('created_at', ascending: false);
              
          return joinedData.map((json) => _mapJsonToFoodListing(json)).toList();
        });
  }

  // Aguiluz, updated signature para sa new migration columns.
  static Future<void> claimItem(String entryId, String title, String claimerName, String posterId, String claimerId) async {
    await _supabase.from('food_listings').update({
      'is_claimed': true,
      'claimer_id': claimerId,
      'claimer_name': claimerName,
      // 'claimed_at': DateTime.now().toIso8601String(), // Velasquez: Disabled muna para di mag-crash pre.
    }).eq('entry_id', entryId);

    // Velasquez: Nilagyan ko na ng listing_id at has_actions: true para lumabas yung View Details button sa UI.
    await _supabase.from('alerts').insert({
      'alert_type': 'claim',
      'title': 'New Claim!',
      'description': '$claimerName just claimed "$title". Reach out to them!',
      'receiver_id': posterId,
      'listing_id': entryId,
      'is_new': true,
      'has_actions': true,
    });
  }

  // Phase 1: Confirm Pickup Action
  static Future<void> confirmPickup(String entryId, String? claimerId) async {
    // Velasquez: Kuha muna tayo ng title pre para dynamic yung alert.
    final listing = await _supabase.from('food_listings').select('grab_title').eq('entry_id', entryId).single();
    final title = listing['grab_title'] ?? 'your item';

    await _supabase.from('food_listings').update({
      'is_completed': true, 
    }).eq('entry_id', entryId);

    if (claimerId != null && claimerId.isNotEmpty) {
      // Velasquez: Ginawa kong dynamic yung text para alam agad ng claimer kung anong pagkain yung na-confirm sa notifications nila.
      await _supabase.from('alerts').insert({
        'alert_type': 'success',
        'title': 'Pickup Confirmed',
        'description': 'The poster confirmed you picked up "$title".',
        'receiver_id': claimerId,
        'listing_id': entryId,
        'is_new': true,
        'has_actions': true,
      });
    }
  }

  // Phase 1: Reject Pickup Action
  static Future<void> rejectPickup(String entryId, String? claimerId) async {
    // Velasquez: Hila ulit tayo ng title para sa dynamic description.
    final listing = await _supabase.from('food_listings').select('grab_title').eq('entry_id', entryId).single();
    final title = listing['grab_title'] ?? 'your item';

    await _supabase.from('food_listings').update({
      'is_claimed': false,
      'claimer_id': null,
      'claimer_name': null,
    }).eq('entry_id', entryId);

    if (claimerId != null && claimerId.isNotEmpty) {
      // Velasquez: Dynamic cancelled message pre, para solid ang UX.
      await _supabase.from('alerts').insert({
        'alert_type': 'warning',
        'title': 'Pickup Cancelled',
        'description': 'The poster cancelled the pickup for "$title".',
        'receiver_id': claimerId,
        'listing_id': entryId,
        'is_new': true,
        'has_actions': true,
      });
    }
  }

  // Mark Dave, helper para mahila yung claimer details sa MyListingScreen.
  static Future<Map<String, dynamic>?> getClaimerProfile(String claimerId) async {
    try {
      return await _supabase
          .from('profiles')
          .select('full_name, avatar_url, building_no, phone_number')
          .eq('id', claimerId)
          .single();
    } catch (e) {
      return null;
    }
  }

  static Future<void> updateListing(String id, FoodListing item, String? imageUrl) async {
    // Velasquez: Dinagdag ko na yung is_stray_feed sa payload para isave na talaga ng Supabase yung toggle natin.
    await _supabase.from('food_listings').update({
      'grab_title': item.grabTitle,
      'backstory': item.backstory,
      'time_window': item.expiryDate?.toIso8601String() ?? item.timeWindow,
      'meetup_spot': item.meetupSpot,
      'is_stray_feed': item.isStrayFeed,
      'offline_image': imageUrl ?? item.offlineImage,
    }).eq('entry_id', id);
  }

  static Future<void> deleteListing(String id) async {
    await _supabase.from('food_listings').delete().eq('entry_id', id);
  }

  static Future<void> dismissAlert(String id) async {
    await _supabase.from('alerts').delete().eq('alert_id', id);
  }

  static Future<void> checkAndGenerateExpiryAlerts() async {
    try {
      final userId = currentUserId;
      if (userId == null) return;

      final now = DateTime.now();
      final tomorrow = now.add(const Duration(hours: 24));

      // Fetch active, unclaimed listings expiring within 24 hours
      // Velasquez: Background checker to para mag-generate ng expiry alerts. Wag niyo gagawing loop para di tayo ma-rate limit sa Supabase.
      final expiringItems = await _supabase
          .from('food_listings')
          .select()
          .eq('user_id', userId)
          .eq('is_completed', false)
          .eq('is_claimed', false)
          .gte('time_window', now.toIso8601String())
          .lte('time_window', tomorrow.toIso8601String());

      for (final item in expiringItems) {
        final entryId = item['entry_id'].toString();
        
        // Check if alert already exists
        final existingAlert = await _supabase
            .from('alerts')
            .select()
            .eq('listing_id', entryId)
            .eq('alert_type', 'expiring_soon')
            .maybeSingle();

        if (existingAlert == null) {
          // Velasquez: Added has_actions true para pwede silang dumerecho sa details para i-extend or i-edit.
          // Velasquez: Pati sa Expiry alerts, kailangan ng listing_id para ma-view nila kung anong item yung mapapanis na.
          await _supabase.from('alerts').insert({
            'alert_type': 'expiring_soon',
            'title': 'Expiring Soon!',
            'description':
                'Your ${item['grab_title']} is expiring in less than 24 hours.',
            'is_new': true,
            'listing_id': entryId, // CRITICAL FIX
            'receiver_id': userId,
            'has_actions': true,
          });
        }
      }
    } catch (e) {
      // Run silently
      debugPrint('Expiry alert generation error: $e');
    }
  }

  static Future<void> updatePhoneNumber(String newNumber) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id ?? currentUserId;
      if (userId == null) throw Exception("User session not found.");
      
      await _supabase
          .from('profiles')
          .update({'phone_number': newNumber})
          .eq('id', userId);
    } catch (e) {
      throw Exception(ErrorUtils.getFriendlyErrorMessage(e));
    }
  }

  // Velasquez: ito na yung updated upload method natin.
  // Bytes na yung tinatanggap natin para compatible sa Web at Android!
  static Future<String?> uploadImage(String fileName, Uint8List imageBytes) async {
    try {
      final path = 'listings/$fileName';
      
      // Mark Dave, using uploadBinary for seamless cross-platform support.
      // Velasquez: Pahirapan yung .upload() sa Web version ng Supabase, kaya naka-Binary tayo dito.
      await _supabase.storage.from('food_images').uploadBinary(
            path,
            imageBytes,
            fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true),
          );
          
      return _supabase.storage.from('food_images').getPublicUrl(path);
    } catch (e) {
      // Velasquez: log natin error if ever sumablay.
      debugPrint('Upload error: $e');
      return null;
    }
  }

  static FoodListing _mapJsonToFoodListing(Map<String, dynamic> json) {
    final profile = json['profiles'] as Map<String, dynamic>?;
    return FoodListing(
      // Yamzon: fallback to id muna pag entry_id is null. Ang gulo ng DB naming natin sa food_listings table.
      entryId: json['entry_id']?.toString() ?? json['id']?.toString() ?? '',                 
      grabTitle: json['grab_title'] ?? '',                 
      backstory: json['backstory'] ?? '',           
      timeWindow: json['time_window'] ?? '',          
      dropDistance: json['drop_distance']?.toString() ?? '0.1 km',     
      meetupSpot: json['meetup_spot'] ?? '',             
      posterAlias: profile?['full_name'] ?? json['poster_alias'] ?? 'Anonymous',
      posterAvatarUrl: profile?['avatar_url'], 
      userId: json['user_id']?.toString() ?? '', 
      claimerId: json['claimer_id']?.toString(), // Task 1: Mapping new column
      offlineImage: json['offline_image'] ?? 'assets/images/image.png',
      createdAt: json['created_at'] != null 
          ? (DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now().subtract(const Duration(seconds: 1))) 
          : DateTime.now().subtract(const Duration(seconds: 1)),
      isClaimed: json['is_claimed'] ?? false,         
      isCompleted: json['is_completed'] ?? false, // Velasquez: In-sync na 'to sa migration pre.
      claimerName: json['claimer_name'] ?? 'Eco Warrior', 
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

  static Future<AlertListing> _mapJsonToAlertListing(Map<String, dynamic> json) async {
    AlertType type = AlertType.claim;
    final alertTypeString = json['alert_type']?.toString();
    if (alertTypeString == 'nearby') type = AlertType.nearby;
    if (alertTypeString == 'follower') type = AlertType.follower;
    if (alertTypeString == 'expiry') type = AlertType.expiry;
    if (alertTypeString == 'success') type = AlertType.success;
    if (alertTypeString == 'warning') type = AlertType.warning;
    if (alertTypeString == 'expiring_soon') type = AlertType.expiringSoon;

    return AlertListing(
      alertId: json['alert_id'].toString(),
      type: type,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      createdAt: json['created_at'] != null 
          ? (DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now().subtract(const Duration(seconds: 1))) 
          : DateTime.now().subtract(const Duration(seconds: 1)),
      isNew: json['is_new'] ?? true,
      hasActions: json['has_actions'] ?? (type == AlertType.claim || type == AlertType.nearby || type == AlertType.success || type == AlertType.warning || type == AlertType.expiringSoon), 
      senderAvatar: json['sender_avatar'],
      listingId: json['listing_id']?.toString(), // Task 2: Mapping listing_id column
    );
  }
}
