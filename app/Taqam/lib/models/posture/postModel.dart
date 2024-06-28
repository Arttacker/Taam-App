import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  String? postId;
  String? userId;
  double? price;
  String? color;
  String? coloredName;
  String? image;
  String? season;
  Timestamp? postDate;
  String? condition;
  String? gender;
  bool? isSold;
  String? category;
  double? productHeight;
  double? productWidth;
  String? size;
  String? description;

  PostModel({
    this.postId,
    this.userId,
    this.price,
    this.color,
    this.image,
    this.season,
    this.postDate,
    this.condition,
    this.gender,
    this.isSold,
    this.category,
    this.productHeight,
    this.productWidth,
    this.size,
    this.description,
    required this.coloredName,
  });

  // Create a PostModel object from a map
  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      postId: json['postId'],
      userId: json['userId'],
      price: json['price'],
      color: json['color'],
      image: json['image'],
      season: json['season'],
      postDate: json['postDate'],
      condition: json['condition'],
      gender: json['gender'],
      isSold: json['isSold'],
      category: json['category'],
      productHeight: json['productLength'],
      productWidth: json['productWidth'],
      size: json['size'],
      description: json['description'],
      coloredName: json['coloredName'],
    );
  }

  // Convert PostModel object to a map
  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'userId': userId,
      'price': price,
      'color': color,
      'image': image,
      'season': season,
      'postDate': postDate,
      'condition': condition,
      'gender': gender,
      'isSold': isSold,
      'category': category,
      'productLength': productHeight,
      'productWidth': productWidth,
      'size': size,
      'description': description,
      'coloredName': coloredName,
    };
  }
}
