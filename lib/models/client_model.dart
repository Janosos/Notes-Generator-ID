class Client {
  final String id;
  String name;
  String email;
  String phone;
  String address;

  Client({
    required this.id,
    required this.name,
    this.email = '',
    this.phone = '',
    this.address = '',
  });
}
