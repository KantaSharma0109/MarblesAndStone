import '../common/common.dart';

class Live {
  late final String id;
  late final String title;
  late final String url;
  late final String description;
  late final String promo_video;
  late final String price;
  late final String discount_price;
  late final String image_path;
  late final String created_at;
  late final String live_date;
  late final int subscribed;
  late final int liveUsersCount;
  late final String share_url;
  String? course_id;

  Live({
    required this.id,
    required this.title,
    required this.url,
    required this.description,
    required this.promo_video,
    required this.price,
    required this.discount_price,
    required this.image_path,
    required this.created_at,
    required this.live_date,
    required this.subscribed,
    required this.liveUsersCount,
    required this.share_url,
    this.course_id,
  });

  factory Live.fromJson(Map<String, dynamic> jsonData) {
    return Live(
      id: jsonData[ApiKeys.id].toString(),
      title: jsonData[ApiKeys.title].toString(),
      description: jsonData[ApiKeys.description].toString(),
      promo_video: jsonData[ApiKeys.promo_video].toString() != 'null'
          ? jsonData[ApiKeys.promo_video].toString()
          : "",
      price: jsonData[ApiKeys.price].toString(),
      discount_price: jsonData[ApiKeys.discount_price].toString(),
      image_path: jsonData[ApiKeys.image_path].toString() != 'null'
          ? jsonData[ApiKeys.image_path].toString()
          : "",
      share_url: jsonData[ApiKeys.share_url].toString(),
      subscribed: jsonData[ApiKeys.subscribed].toString() != 'null'
          ? jsonData[ApiKeys.subscribed] > 0
              ? jsonData[ApiKeys.subscribed]
              : 0
          : 0,
      liveUsersCount: jsonData[ApiKeys.live_users_count],
      live_date: jsonData[ApiKeys.live_date].toString(),
      url: jsonData[ApiKeys.url].toString(),
      created_at: jsonData[ApiKeys.created_at].toString(),
      course_id: jsonData[ApiKeys.course_id].toString() != 'null'
          ? jsonData[ApiKeys.course_id].toString()
          : '',
    );
  }
}
