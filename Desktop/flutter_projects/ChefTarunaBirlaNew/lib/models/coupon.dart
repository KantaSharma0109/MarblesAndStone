import '../common/common.dart';

class Coupon {
  late final String id;
  late final String couponName;
  late final String category;
  late final int discount;
  late final double totalAmount;
  late final bool isApplied;

  Coupon({
    required this.id,
    required this.couponName,
    required this.discount,
    required this.totalAmount,
    required this.category,
    required this.isApplied,
  });

  factory Coupon.fromJson(Map<String, dynamic> jsonData) {
    return Coupon(
      id: jsonData[ApiKeys.id].toString(),
      couponName: jsonData[ApiKeys.couponName].toString(),
      discount: jsonData[ApiKeys.discount],
      totalAmount: double.parse(jsonData[ApiKeys.totalAmount].toString()),
      category: jsonData[ApiKeys.category].toString(),
      isApplied: jsonData[ApiKeys.isApplied],
    );
  }
}
