class User {
  int? id;
  String name;
  String email;
  String phone;
  String? avatar;
  DateTime dateOfBirth;
  double price;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.avatar,
    required this.dateOfBirth,
    required this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatar': avatar,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'price': price,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      name: map['name'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String,
      avatar: map['avatar'] as String?,
      dateOfBirth: DateTime.parse(map['dateOfBirth'] as String),
      price: (map['price'] as num).toDouble(),
    );
  }

  User copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? avatar,
    DateTime? dateOfBirth,
    double? price,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      price: price ?? this.price,
    );
  }

  @override
  String toString() {
    return 'User{id: $id, name: $name, email: $email, phone: $phone, avatar: $avatar, dateOfBirth: $dateOfBirth, price: $price}';
  }
}