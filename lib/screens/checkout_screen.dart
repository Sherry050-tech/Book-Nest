import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

class CheckoutScreen extends StatefulWidget {
  final double totalAmount;
  final int itemCount;

  const CheckoutScreen({
    super.key,
    required this.totalAmount,
    required this.itemCount,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _zipController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  String _selectedPayment = 'Credit Card';
  bool _isLoading = false;

  final List<String> _paymentMethods = [
    'Credit Card',
    'Debit Card',
    'Cash on Delivery'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _zipController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  String? _required(String? v, String fieldName) {
    if (v == null || v.trim().isEmpty) return '$fieldName is required';
    return null;
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,4}$').hasMatch(v.trim())) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? _validatePhone(String? v) {
    if (v == null || v.trim().isEmpty) return 'Phone number is required';
    if (!RegExp(r'^\d{10,13}$').hasMatch(v.trim())) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  String? _validateCardNumber(String? v) {
    if (v == null || v.trim().isEmpty) return 'Card number is required';
    final digits = v.replaceAll(' ', '');
    if (digits.length != 16) return 'Card number must be 16 digits';
    return null;
  }

  String? _validateExpiry(String? v) {
    if (v == null || v.trim().isEmpty) return 'Expiry date is required';
    if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(v.trim())) {
      return 'Use MM/YY format';
    }
    return null;
  }

  String? _validateCVV(String? v) {
    if (v == null || v.trim().isEmpty) return 'CVV is required';
    if (v.length < 3 || v.length > 4) return 'CVV must be 3-4 digits';
    return null;
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      final cart = Provider.of<CartProvider>(context, listen: false);
      cart.clearCart();
      setState(() => _isLoading = false);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => OrderSuccessScreen(
            name: _nameController.text.trim(),
            totalAmount: widget.totalAmount,
            itemCount: widget.itemCount,
          ),
        ),
        (route) => route.isFirst,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
            horizontal: isWide ? screenWidth * 0.2 : 16, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionCard(
                title: 'Delivery Information',
                icon: Icons.local_shipping_outlined,
                children: [
                  _buildField(_nameController, 'Full Name', Icons.person_outline,
                      (v) => _required(v, 'Name')),
                  const SizedBox(height: 14),
                  _buildField(_emailController, 'Email Address',
                      Icons.email_outlined, _validateEmail,
                      keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 14),
                  _buildField(_phoneController, 'Phone Number',
                      Icons.phone_outlined, _validatePhone,
                      keyboardType: TextInputType.phone),
                  const SizedBox(height: 14),
                  _buildField(_addressController, 'Street Address',
                      Icons.home_outlined, (v) => _required(v, 'Address')),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildField(_cityController, 'City',
                            Icons.location_city_outlined,
                            (v) => _required(v, 'City')),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildField(
                          _zipController,
                          'ZIP Code',
                          Icons.pin_outlined,
                          (v) => _required(v, 'ZIP'),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Payment Method',
                icon: Icons.payment_outlined,
                children: [
                  ..._paymentMethods.map((method) => RadioListTile<String>(
                        value: method,
                        groupValue: _selectedPayment,
                        onChanged: (v) =>
                            setState(() => _selectedPayment = v!),
                        title: Text(method),
                        activeColor: const Color(0xFF1A237E),
                        contentPadding: EdgeInsets.zero,
                      )),
                  if (_selectedPayment != 'Cash on Delivery') ...[
                    const Divider(),
                    const SizedBox(height: 8),
                    _buildField(_cardNumberController, 'Card Number',
                        Icons.credit_card, _validateCardNumber,
                        keyboardType: TextInputType.number),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _buildField(_expiryController, 'MM/YY',
                              Icons.date_range_outlined, _validateExpiry),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildField(_cvvController, 'CVV',
                              Icons.lock_outline, _validateCVV,
                              keyboardType: TextInputType.number,
                              obscure: true),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Order Summary',
                icon: Icons.receipt_outlined,
                children: [
                  _summaryRow('Items (${widget.itemCount})',
                      '\$${widget.totalAmount.toStringAsFixed(2)}'),
                  const SizedBox(height: 8),
                  _summaryRow('Shipping', 'Included'),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total',
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.bold)),
                      Text(
                        '\$${widget.totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A237E),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _placeOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5),
                      )
                    : const Text('Place Order',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    IconData icon,
    String? Function(String?) validator, {
    TextInputType? keyboardType,
    bool obscure = false,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF1A237E), size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: Color(0xFF1A237E), width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade600)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF1A237E), size: 20),
                const SizedBox(width: 8),
                Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

class OrderSuccessScreen extends StatelessWidget {
  final String name;
  final double totalAmount;
  final int itemCount;

  const OrderSuccessScreen({
    super.key,
    required this.name,
    required this.totalAmount,
    required this.itemCount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: Color(0xFF1A237E),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded,
                    size: 64, color: Colors.white),
              ),
              const SizedBox(height: 28),
              const Text(
                'Order Placed!',
                style: TextStyle(
                    fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'Thank you, ${name.split(' ').first}! Your order of $itemCount book${itemCount > 1 ? 's' : ''} has been placed successfully.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.grey.shade600, height: 1.5),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Text('Total Charged',
                        style: TextStyle(color: Colors.grey.shade500)),
                    const SizedBox(height: 4),
                    Text(
                      '\$${totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A237E),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.local_shipping_outlined,
                              size: 16, color: Colors.green.shade700),
                          const SizedBox(width: 6),
                          Text('Estimated delivery: 3-5 days',
                              style: TextStyle(
                                  color: Colors.green.shade700, fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),
              ElevatedButton(
                onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Continue Shopping',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
