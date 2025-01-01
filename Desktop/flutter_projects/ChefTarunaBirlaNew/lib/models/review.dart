import '../common/common.dart';

class Review {
  final String name;
  final String message;
  final String date;

  Review({
    required this.name,
    required this.message,
    required this.date,
  });

  factory Review.fromJson(Map<String, dynamic> jsonData) {
    return Review(
      name: jsonData[ApiKeys.username].toString(),
      message: jsonData[ApiKeys.message].toString(),
      date: jsonData[ApiKeys.date].toString(),
    );
  }
}
