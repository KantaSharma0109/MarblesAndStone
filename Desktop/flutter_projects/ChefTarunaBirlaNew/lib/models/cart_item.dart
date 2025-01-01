import '../common/common.dart';

class CartItem {
  late final String cart_id;
  late final String name;
  late final int price;
  int? totalAmount = 0;
  late final int quantity;
  String? address;
  String? description;
  late final String image_path;
  late final String item_id;
  late final String item_category;
  late final String cart_category;
  String? pincode;
  bool? isPlusMinus;

  CartItem({
    required this.cart_id,
    required this.item_id,
    required this.name,
    required this.price,
    required this.cart_category,
    required this.image_path,
    required this.quantity,
    required this.item_category,
    this.totalAmount,
    this.address,
    this.description,
    this.pincode,
    this.isPlusMinus,
  });

  factory CartItem.fromJson(Map<String, dynamic> jsonData) {
    return CartItem(
      cart_id: jsonData[ApiKeys.id].toString(),
      name: jsonData[ApiKeys.name].toString(),
      item_category: jsonData[ApiKeys.category].toString(),
      price: jsonData[ApiKeys.discount_price],
      cart_category: jsonData[ApiKeys.cart_category].toString() != 'null'
          ? jsonData[ApiKeys.cart_category].toString()
          : 'cart',
      image_path: jsonData[ApiKeys.image_path].toString() != 'null'
          ? jsonData[ApiKeys.image_path].toString()
          : "",
      item_id: jsonData[ApiKeys.item_id].toString(),
      quantity: jsonData[ApiKeys.quantity],
      totalAmount: jsonData[ApiKeys.totalAmount],
      address: jsonData[ApiKeys.address] != null
          ? jsonData[ApiKeys.address].toString()
          : '',
      description: jsonData[ApiKeys.description] != null
          ? jsonData[ApiKeys.description].toString()
          : '',
      pincode: jsonData[ApiKeys.pincode] != null
          ? jsonData[ApiKeys.pincode].toString()
          : '',
      isPlusMinus: jsonData[ApiKeys.isPlusMinus] ?? false,
    );
  }
}
