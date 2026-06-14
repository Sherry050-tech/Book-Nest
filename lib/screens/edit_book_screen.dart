import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book.dart';

class EditBookScreen extends StatefulWidget {
  final Book book;
  const EditBookScreen({super.key, required this.book});

  @override
  State<EditBookScreen> createState() => _EditBookScreenState();
}

class _EditBookScreenState extends State<EditBookScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  late TextEditingController _imageUrlController;
  late String _selectedCategory;
  late String _selectedColor;
  bool _isLoading = false;

  final List<String> _categories = ['Fiction', 'Technology', 'Self-Help'];
  final List<Map<String, dynamic>> _colors = [
    {'name': 'Blue', 'value': '0xFF1A237E'},
    {'name': 'Purple', 'value': '0xFF4A148C'},
    {'name': 'Green', 'value': '0xFF004D40'},
    {'name': 'Red', 'value': '0xFFBF360C'},
    {'name': 'Grey', 'value': '0xFF37474F'},
    {'name': 'Pink', 'value': '0xFF880E4F'},
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.book.title);
    _authorController = TextEditingController(text: widget.book.author);
    _priceController = TextEditingController(text: widget.book.price.toString());
    _descriptionController = TextEditingController(text: widget.book.description);
    _imageUrlController = TextEditingController(text: widget.book.imageUrl);
    _selectedCategory = widget.book.category;
    _selectedColor = widget.book.coverColor;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _updateBook() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance
          .collection('books')
          .doc(widget.book.id)
          .update({
        'title': _titleController.text.trim(),
        'author': _authorController.text.trim(),
        'price': double.parse(_priceController.text.trim()),
        'description': _descriptionController.text.trim(),
        'category': _selectedCategory,
        'coverColor': _selectedColor,
        'imageUrl': _imageUrlController.text.trim(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Book updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        title: const Text('Edit Book'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(_titleController, 'Title', Icons.book),
              const SizedBox(height: 16),
              _buildTextField(_authorController, 'Author', Icons.person),
              const SizedBox(height: 16),
              _buildTextField(_priceController, 'Price', Icons.attach_money, isNumber: true),
              const SizedBox(height: 16),
              _buildTextField(_descriptionController, 'Description', Icons.description, maxLines: 4),
              const SizedBox(height: 16),
              _buildTextField(_imageUrlController, 'Image URL (optional)', Icons.image),
              const SizedBox(height: 8),
              if (_imageUrlController.text.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    _imageUrlController.text,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox(),
                  ),
                ),
              const SizedBox(height: 16),
              const Text('Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                onChanged: (val) => setState(() => _selectedCategory = val!),
              ),
              const SizedBox(height: 16),
              const Text('Cover Color', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                children: _colors.map((color) {
                  final isSelected = _selectedColor == color['value'];
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = color['value']),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Color(int.parse(color['value'])),
                        shape: BoxShape.circle,
                        border: isSelected ? Border.all(color: Colors.black, width: 3) : null,
                      ),
                      child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateBook,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A237E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Update Book', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label,
      IconData icon, {
        bool isNumber = false,
        int maxLines = 1,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          maxLines: maxLines,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFF1A237E)),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          validator: (val) {
            if (label != 'Image URL (optional)' && (val == null || val.isEmpty)) return '$label is required';
            if (isNumber && val!.isNotEmpty && double.tryParse(val) == null) return 'Enter a valid number';
            return null;
          },
        ),
      ],
    );
  }
}