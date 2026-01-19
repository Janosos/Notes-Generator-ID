class Client {
  final String id;
  String name;
  String email;
  String phone;
  String countryCode; // e.g. +52
  String address;

  Client({
    required this.id,
    required this.name,
    this.email = '',
    this.phone = '',
    this.countryCode = '+52',
    this.address = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'countryCode': countryCode,
      'address': address,
    };
  }

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      countryCode: json['countryCode'] ?? '+52',
      address: json['address'] ?? '',
    );
  }
}
