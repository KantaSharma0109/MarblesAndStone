import '../common/common.dart';

class Products {
  late final String id;
  late final String name;
  late final String description;
  late final String c_name;
  late final String category_id;
  late final String price;
  late final String discount_price;
  late final int stock;
  late final String image_path;
  late final String share_url;
  // late final int count;
  // late final int whislistcount;

  Products({
    required this.id,
    required this.name,
    required this.description,
    required this.c_name,
    required this.category_id,
    required this.price,
    required this.discount_price,
    required this.stock,
    required this.image_path,
    required this.share_url,
    // required this.count,
    // required this.whislistcount,
  });

  factory Products.fromJson(Map<String, dynamic> jsonData) {
    return Products(
      id: jsonData[ApiKeys.id].toString(),
      name: jsonData[ApiKeys.name].toString(),
      description: jsonData[ApiKeys.description].toString(),
      c_name: jsonData[ApiKeys.c_name].toString(),
      category_id: jsonData[ApiKeys.category_id].toString(),
      price: jsonData[ApiKeys.price].toString(),
      discount_price: jsonData[ApiKeys.discount_price].toString(),
      stock: int.parse(jsonData[ApiKeys.stock].toString()),
      image_path: jsonData[ApiKeys.image_path].toString(),
      share_url: jsonData[ApiKeys.share_url].toString(),
    );
  }
}
