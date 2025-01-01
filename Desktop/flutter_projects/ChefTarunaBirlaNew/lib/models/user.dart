class UserData {
  late final String id;
  late final String name;
  late final String phone_number;
  late final String email_id;
  late final String address;
  late final String pincode;
  late final int wallet;

  UserData({
    required this.id,
    required this.name,
    required this.phone_number,
    required this.email_id,
    required this.address,
    required this.pincode,
    required this.wallet,
  });
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone_number': phone_number,
      'email_id': email_id,
      'address': address,
      'pincode': pincode,
      'wallet': wallet,
    };
  }
}
