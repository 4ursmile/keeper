import 'dart:convert';

class User {
  String userId;
  String name;
  String email;
  String phone;
  String address;
  int rating;
  List<String> reviews;
  double balance;
  List<String> transactionHistory;

  User({
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.rating,
    required this.reviews,
    required this.balance,
    required this.transactionHistory,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'rating': rating,
      'reviews': reviews,
      'balance': balance,
      'transactionHistory': transactionHistory,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      userId: map['userId'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      address: map['address'],
      rating: map['rating'],
      reviews: List<String>.from(map['reviews']),
      balance: map['balance'],
      transactionHistory: List<String>.from(map['transactionHistory']),
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source));
}

void main() {
  // Mock data instances
  User user1 = User(
    userId: "user001",
    name: "Alice Smith",
    email: "alice@example.com",
    phone: "+1234567890",
    address: "123 Main St, Anytown",
    rating: 4,
    reviews: ["review001", "review002"],
    balance: 500.0,
    transactionHistory: ["txn001", "txn002"],
  );

  User user2 = User(
    userId: "user002",
    name: "Bob Johnson",
    email: "bob@example.com",
    phone: "+1987654321",
    address: "456 Elm St, Othertown",
    rating: 5,
    reviews: ["review003"],
    balance: 1000.0,
    transactionHistory: ["txn003"],
  );

  User user3 = User(
    userId: "user003",
    name: "Charlie Brown",
    email: "charlie@example.com",
    phone: "+1654321897",
    address: "789 Oak St, Another Town",
    rating: 3,
    reviews: [],
    balance: 200.0,
    transactionHistory: ["txn004", "txn005"],
  );

  User user4 = User(
    userId: "user004",
    name: "Diana Lee",
    email: "diana@example.com",
    phone: "+1765432987",
    address: "321 Pine St, Someplace",
    rating: 4,
    reviews: ["review004"],
    balance: 750.0,
    transactionHistory: ["txn006"],
  );

  User user5 = User(
    userId: "user005",
    name: "Ethan Miller",
    email: "ethan@example.com",
    phone: "+1876543210",
    address: "987 Cedar St, Anywhere",
    rating: 5,
    reviews: ["review005", "review006"],
    balance: 300.0,
    transactionHistory: [],
  );

 
}
