import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String? userId;
  String? fName;
  String? lName;
  Timestamp? registrationDate;
  int? age;
  double? height;
  double? weight;
  String? gender;
  String? image;
  int? NFollowers;
  String? phone;
  String? email;
  String? password;
  Timestamp? lastSeen;
  String? town;
  String? city;
  bool? isAdmin;

  UserModel({
    this.userId,
    this.fName,
    this.lName,
    this.registrationDate,
    this.age,
    this.height,
    this.weight,
    this.gender,
    this.image,
    this.NFollowers,
    this.phone,
    this.email,
    this.password,
    this.lastSeen,
    this.town,
    this.city,
    this.isAdmin,
  });

  // Create a UserModel object from a map
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'],
      fName: json['fName'],
      lName: json['lName'],
      registrationDate: json['registrationDate'],
      age: json['age'],
      height: json['height'],
      weight: json['weight'],
      gender: json['gender'],
      image: json['image'],
      NFollowers: json['NFollowers'],
      phone: json['phone'],
      email: json['email'],
      password: json['password'],
      lastSeen: json['lastSeen'],
      town: json['town'],
      city: json['city'],
      isAdmin: json['isAdmin'],
    );
  }

  // Convert UserModel object to a map
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'fName': fName,
      'lName': lName,
      'registrationDate': registrationDate,
      'age': age,
      'height': height,
      'weight': weight,
      'gender': gender,
      'image': image,
      'NFollowers': NFollowers,
      'phone': phone,
      'email': email,
      'password': password,
      'lastSeen': lastSeen,
      'town': town,
      'city': city,
      'isAdmin': isAdmin,
    };
  }
}
