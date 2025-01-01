import '../common/common.dart';

class Notifications {
  late final String id;
  late final String item_id;
  late final String message;
  late final String category;
  late final String user_id;
  late final String created_at;

  Notifications({
    required this.id,
    required this.item_id,
    required this.message,
    required this.category,
    required this.user_id,
    required this.created_at,
  });

  factory Notifications.fromJson(Map<String, dynamic> jsonData) {
    return Notifications(
      id: jsonData[ApiKeys.id].toString(),
      item_id: jsonData[ApiKeys.item_id].toString(),
      message: jsonData[ApiKeys.message].toString(),
      category: jsonData[ApiKeys.category],
      user_id: jsonData[ApiKeys.user_id].toString(),
      created_at: jsonData[ApiKeys.created_at].toString(),
    );
  }
}
