import '../common/common.dart';

class Course {
  late final String id;
  late final String title;
  late final String description;
  late final String promo_video;
  late final String price;
  late final String discount_price;
  late final int days;
  late final String category;
  late final String image_path;
  late final int subscribed;
  late final String share_url;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.promo_video,
    required this.price,
    required this.discount_price,
    required this.days,
    required this.category,
    required this.image_path,
    required this.subscribed,
    required this.share_url,
  });

  factory Course.fromJson(Map<String, dynamic> jsonData) {
    return Course(
      id: jsonData[ApiKeys.id].toString(),
      title: jsonData[ApiKeys.title].toString(),
      description: jsonData[ApiKeys.description].toString(),
      promo_video: jsonData[ApiKeys.promo_video].toString() != 'null'
          ? jsonData[ApiKeys.promo_video].toString()
          : "",
      price: jsonData[ApiKeys.price].toString(),
      discount_price: jsonData[ApiKeys.discount_price].toString(),
      days: int.parse(jsonData[ApiKeys.days].toString()),
      category: jsonData[ApiKeys.category].toString(),
      image_path: jsonData[ApiKeys.image_path].toString() != 'null'
          ? jsonData[ApiKeys.image_path].toString()
          : "",
      share_url: jsonData[ApiKeys.share_url].toString(),
      subscribed: jsonData[ApiKeys.subscribedDays].toString() != 'null'
          ? jsonData[ApiKeys.subscribedDays] > 0
              ? jsonData[ApiKeys.subscribedDays]
              : 0
          : 0,
    );
  }
}

class Videos {
  final String name;
  final String path;
  final bool isFullScreen;

  Videos({
    required this.name,
    required this.path,
    required this.isFullScreen,
  });

  factory Videos.fromJson(Map<String, dynamic> jsonData) {
    return Videos(
      name: jsonData[ApiKeys.name].toString(),
      path: jsonData[ApiKeys.path].toString(),
      isFullScreen: jsonData[ApiKeys.isFullScreen] == 1 ? true : false,
    );
  }
}

class Pdf {
  final String path;

  Pdf({
    required this.path,
  });

  factory Pdf.fromJson(Map<String, dynamic> jsonData) {
    return Pdf(
      path: jsonData[ApiKeys.pdflink].toString(),
    );
  }
}
