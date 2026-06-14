import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book.dart';
import '../providers/cart_provider.dart';
import 'cart_screen.dart';
import 'edit_book_screen.dart';

class BookDetailScreen extends StatelessWidget {
  final Book book;
  final bool isAdmin;
  const BookDetailScreen({super.key, required this.book, this.isAdmin = false});

  Future<void> _deleteBook(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Book'),
        content: const Text('Are you sure you want to delete this book?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await FirebaseFirestore.instance.collection('books').doc(book.id).delete();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Book deleted!'), backgroundColor: Colors.red),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final inCart = cart.isInCart(book.id);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: Color(int.parse(book.coverColor)),
            foregroundColor: Colors.white,
            actions: [
              if (isAdmin) ...[
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => EditBookScreen(book: book)),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteBook(context),
                ),
              ],
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CartScreen()),
                    ),
                  ),
                  if (cart.itemCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle),
                        child: Text('${cart.itemCount}',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black)),
                      ),
                    ),
                ],
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: book.imageUrl.isNotEmpty
                  ? Image.network(
                book.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Color(int.parse(book.coverColor)),
                  child: const Center(child: Icon(Icons.menu_book_rounded, size: 72, color: Colors.white60)),
                ),
              )
                  : Container(
                color: Color(int.parse(book.coverColor)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    Container(
                      width: 120,
                      height: 160,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                      ),
                      child: const Icon(Icons.menu_book_rounded, size: 72, color: Colors.white60),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A237E).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(book.category,
                        style: const TextStyle(color: Color(0xFF1A237E), fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 12),
                  Text(book.title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text('by ${book.author}', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ...List.generate(5, (i) => Icon(
                        i < book.rating.floor() ? Icons.star_rounded : (i < book.rating ? Icons.star_half_rounded : Icons.star_outline_rounded),
                        color: Colors.amber, size: 22,
                      )),
                      const SizedBox(width: 8),
                      Text('${book.rating} (${book.reviews} reviews)',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text('About this book', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(book.description,
                      style: TextStyle(fontSize: 15, color: Colors.grey.shade700, height: 1.6)),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Price', style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                          Text('\$${book.price.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
                        ],
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            cart.addToCart(book);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(inCart ? 'Added another copy!' : '"${book.title}" added to cart!'),
                                backgroundColor: const Color(0xFF1A237E),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            );
                          },
                          icon: Icon(inCart ? Icons.add_shopping_cart : Icons.shopping_cart_outlined),
                          label: Text(inCart ? 'Add More' : 'Add to Cart'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A237E),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (inCart) ...[
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        side: const BorderSide(color: Color(0xFF1A237E)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('View Cart', style: TextStyle(color: Color(0xFF1A237E))),
                    ),
                  ],
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}