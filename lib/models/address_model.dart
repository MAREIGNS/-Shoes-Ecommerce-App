class AddressModel {
  final String id;
  final String fullName;
  final String phone;
  final String addressLine;
  final String city;
  final String country;

  AddressModel({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.addressLine,
    required this.city,
    required this.country,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'].toString(),
      fullName: json['full_name'],
      phone: json['phone'],
      addressLine: json['address_line'],
      city: json['city'],
      country: json['country'],
    );
  }
}