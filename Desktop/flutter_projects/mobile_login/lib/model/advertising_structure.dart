class AdvertisingStructure {
  final String title;
  final String subtitle;
  final String imagePath;
  final int categoryId;
  final int locationId;
  final bool? flexSelected;
  final String? flexType;
  final String cityName;
  final int cityId;
  final String imageUrl;

  AdvertisingStructure({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.categoryId,
    required this.locationId,
    this.flexSelected,
    this.flexType,
    required this.cityName,
    required this.cityId,
    required this.imageUrl,
  });
  factory AdvertisingStructure.fromJson(Map<String, dynamic> json) {
    return AdvertisingStructure(
      title: json['title'],
      subtitle: json['subtitle'],
      imagePath: json['img'],
      categoryId: json['id'],
      locationId: json['id'],
      flexSelected: json['flexSelected'],
      flexType: json['flexType'],
      cityName: json['city_name'],
      cityId: json['city_id'],
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'subtitle': subtitle,
      'img': imagePath,
      'categoryId': categoryId,
      'locationId': locationId,
      'flexSelected': flexSelected,
      'flexType': flexType,
      'cityName': cityName,
      'cityId': cityId,
      'imageUrl': imageUrl,
    };
  }
}
