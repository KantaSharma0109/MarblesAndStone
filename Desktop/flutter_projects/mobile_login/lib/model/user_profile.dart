class UserProfile {
  final String name;
  final String email;
  final String number;
  final String city;

  UserProfile({
    required this.name,
    required this.email,
    required this.number,
    required this.city,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'],
      email: json['email'],
      number: json['number'],
      city: json['city'],
    );
  }
}
