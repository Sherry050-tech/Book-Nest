import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shimmer/shimmer.dart';
import '../models/book.dart';
import '../providers/cart_provider.dart';
import 'book_detail_screen.dart';
import 'cart_screen.dart';
import 'add_book_screen.dart';
import 'login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  final String userEmail;
  const HomeScreen({super.key, required this.userEmail});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final _searchController = TextEditingController();
  final List<String> _categories = ['All', 'Fiction', 'Technology', 'Self-Help'];

  bool get isAdmin => widget.userEmail == 'admin@booknest.com';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
            (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 600 ? 3 : 2;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(Icons.menu_book_rounded, size: 26),
            SizedBox(width: 8),
            Text('BookNest',
                style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
          ],
        ),
        actions: [
          if (isAdmin)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text('ADMIN',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 11,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const CartScreen())),
              ),
              if (cart.itemCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                        color: Colors.amber, shape: BoxShape.circle),
                    child: Text('${cart.itemCount}',
                        style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.black)),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AddBookScreen())),
        icon: const Icon(Icons.add),
        label: const Text('Add Book'),
      )
          : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInDown(
            child: Container(
              color: const Color(0xFF1A237E),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isAdmin
                        ? 'Welcome Admin! 👋'
                        : 'Hello, ${widget.userEmail.split('@').first}! 👋',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const Text('Find your next great read',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _searchQuery = v),
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      hintText: 'Search books or authors...',
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      prefixIcon:
                      const Icon(Icons.search, color: Color(0xFF1A237E)),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.clear,
                            color: Color(0xFF1A237E)),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                      const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
          FadeInLeft(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final isSelected = cat == _selectedCategory;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategory = cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF1A237E)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF1A237E)
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Text(cat,
                            style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey.shade700,
                                fontWeight: FontWeight.w600,
                                fontSize: 13)),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('books')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildShimmer(crossAxisCount);
                }

                List<Book> books = snapshot.data!.docs
                    .map((doc) => Book.fromFirestore(doc))
                    .where((book) {
                  final matchesCategory = _selectedCategory == 'All' ||
                      book.category == _selectedCategory;
                  final matchesSearch = book.title
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase()) ||
                      book.author
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase());
                  return matchesCategory && matchesSearch;
                }).toList();

                if (books.isEmpty) {
                  return FadeIn(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.menu_book_outlined,
                              size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text('No books found',
                              style: TextStyle(
                                  color: Colors.grey.shade500, fontSize: 16)),
                          if (isAdmin) ...[
                            const SizedBox(height: 8),
                            Text('Tap + to add a book',
                                style: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontSize: 14)),
                          ],
                        ],
                      ),
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('${books.length} books found',
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 13)),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: GridView.builder(
                        padding:
                        const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: 0.65,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: books.length,
                        itemBuilder: (context, index) {
                          return FadeInUp(
                            delay: Duration(milliseconds: index * 100),
                            child: _BookCard(
                                book: books[index], isAdmin: isAdmin),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer(int crossAxisCount) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.65,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        );
      },
    );
  }
}

class _BookCard extends StatelessWidget {
  final Book book;
  final bool isAdmin;
  const _BookCard({required this.book, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final inCart = cart.isInCart(book.id);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) =>
              BookDetailScreen(book: book, isAdmin: isAdmin),
          transitionsBuilder: (_, animation, __, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                  parent: animation, curve: Curves.easeInOut)),
              child: child,
            );
          },
        ),
      ),
      child: Card(
        elevation: 3,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(14)),
              child: SizedBox(
                height: 140,
                width: double.infinity,
                child: book.imageUrl.isNotEmpty
                    ? Image.network(
                  book.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Color(int.parse(book.coverColor)),
                    child: const Center(
                        child: Icon(Icons.menu_book_rounded,
                            size: 48, color: Colors.white54)),
                  ),
                )
                    : Container(
                  color: Color(int.parse(book.coverColor)),
                  child: Stack(
                    children: [
                      const Center(
                          child: Icon(Icons.menu_book_rounded,
                              size: 48, color: Colors.white54)),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                              color: Colors.black38,
                              borderRadius: BorderRadius.circular(12)),
                          child: Text(book.category,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 10)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(book.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 2),
                    Text(book.author,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 11)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            size: 14, color: Colors.amber),
                        const SizedBox(width: 2),
                        Text(book.rating.toString(),
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('\$${book.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Color(0xFF1A237E))),
                        GestureDetector(
                          onTap: () => cart.addToCart(book),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: inCart
                                  ? const Color(0xFF1A237E)
                                  : const Color(0xFF1A237E).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                                inCart
                                    ? Icons.check
                                    : Icons.add_shopping_cart,
                                size: 16,
                                color: inCart
                                    ? Colors.white
                                    : const Color(0xFF1A237E)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}