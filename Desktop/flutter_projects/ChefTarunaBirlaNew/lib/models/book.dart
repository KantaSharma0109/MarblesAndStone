class Book {
  final String? id;
  final String? title;
  final String? description;
  final String? price;
  final String? discount_price;
  final int? days;
  final int? video_days;
  final String? category;
  final String? image_path;
  final String? pdflink;
  final String? price_with_video;
  final String? only_video_price;
  final String? only_video_discount_price;
  final String? discount_price_with_video;
  final String? share_url;
  final String? include_videos;
  final int? count;

  Book({
    this.id,
    this.title,
    this.description,
    this.price,
    this.discount_price,
    this.days,
    this.category,
    this.image_path,
    this.pdflink,
    this.count,
    this.video_days,
    this.share_url,
    this.discount_price_with_video,
    this.include_videos,
    this.only_video_discount_price,
    this.only_video_price,
    this.price_with_video,
  });
}
