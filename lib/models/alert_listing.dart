// Yamaguchi: Wag mo muna galawin 'tong AlertType, baka mag-crash yung fetch function.
// Inayos ko na 'to para sa real-time updates natin.
enum AlertType { claim, nearby, follower, expiry, success, warning }

class AlertListing {
  final String alertId;
  final AlertType type;
  final String title;
  final String description;
  final DateTime createdAt;
  final bool isNew;
  final bool hasActions;
  final String? senderAvatar;

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
}
