class User {
  int? id;
  String name;
  String email;
  double price;
  String password;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.price,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'price': price,
      'password': password,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      name: map['name'] as String,
      email: map['email'] as String,
      price: (map['price'] as num).toDouble(),
      password: (map['price'] as String),
    );
  }

  User copyWith({
    int? id,
    String? name,
    String? email,
    double? price,
    String? password,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      price: price ?? this.price,
      password: password ?? this.password,
    );
  }

  @override
  String toString() {
    return 'User{id: $id, name: $name, email: $email, price: $price}';
  }
}
