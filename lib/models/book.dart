import 'package:cloud_firestore/cloud_firestore.dart';

class Book {
  final String id;
  final String title;
  final String author;
  final double price;
  final double rating;
  final int reviews;
  final String category;
  final String description;
  final String coverColor;
  final String imageUrl;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.price,
    required this.rating,
    required this.reviews,
    required this.category,
    required this.description,
    required this.coverColor,
    this.imageUrl = '',
  });

  factory Book.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Book(
      id: doc.id,
      title: data['title'] ?? '',
      author: data['author'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      rating: (data['rating'] ?? 0).toDouble(),
      reviews: (data['reviews'] ?? 0).toInt(),
      category: data['category'] ?? '',
      description: data['description'] ?? '',
      coverColor: data['coverColor'] ?? '0xFF1A237E',
      imageUrl: data['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'author': author,
      'price': price,
      'rating': rating,
      'reviews': reviews,
      'category': category,
      'description': description,
      'coverColor': coverColor,
      'imageUrl': imageUrl,
    };
  }
}