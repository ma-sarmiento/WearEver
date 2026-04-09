import 'package:flutter/material.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final List<Map<String, dynamic>> _cartItems = [
    {
      'name': 'Blazer Premium en Lino',
      'seller': '@atelierrnova',
      'price': 189900,
      'size': 'M',
      'color': 'Negro',
      'quantity': 1,
      'icon': Icons.checkroom,
      'bgColor': const Color(0xFFE8D5C4),
    },
    {
      'name': 'Pantalón Wide Leg',
      'seller': '@unaurban',
      'price': 129900,
      'size': 'S',
      'color': 'Beige',
      'quantity': 2,
      'icon': Icons.accessibility_new,
      'bgColor': const Color(0xFFD4C4B0),
    },
  ];

  String _couponCode = '';
  final double _discount = 20000;
  final double _shipping = 9900;

  double get _subtotal =>
      _cartItems.fold(0, (sum, item) => sum + item['price'] * item['quantity']);

  double get _total => _subtotal + _shipping - _discount;

  void _updateQuantity(int index, int delta) {
    setState(() {
      final newQty = _cartItems[index]['quantity'] + delta;
      if (newQty > 0) {
        _cartItems[index]['quantity'] = newQty;
      } else {
        _cartItems.removeAt(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      appBar: _buildAppBar(),
      body: _cartItems.isEmpty ? _buildEmptyCart() : _buildCartBody(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF5EFE6),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF4A3F30)),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Carrito',
        style: TextStyle(
          color: Color(0xFF4A3F30),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.more_horiz, color: Color(0xFF4A3F30)),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined,
              size: 80, color: const Color(0xFFB5976A).withOpacity(0.4)),
          const SizedBox(height: 16),
          const Text(
            'Tu carrito está vacío',
            style: TextStyle(
                fontSize: 18,
                color: Color(0xFF9A8A75),
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
            child: const Text('Explorar productos',
                style: TextStyle(color: Color(0xFFB5976A))),
          ),
        ],
      ),
    );
  }

  Widget _buildCartBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ..._cartItems.asMap().entries.map((e) => _buildCartItem(e.key, e.value)),
          const SizedBox(height: 16),
          _buildCouponField(),
          const SizedBox(height: 16),
          _buildSummary(),
          const SizedBox(height: 16),
          _buildCheckoutButton(),
          const SizedBox(height: 12),
          _buildContinueShopping(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCartItem(int index, Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB5976A).withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image
          Container(
            width: 75,
            height: 85,
            decoration: BoxDecoration(
              color: item['bgColor'],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Icon(item['icon'],
                  size: 36, color: const Color(0xFFB5976A).withOpacity(0.5)),
            ),
          ),
          const SizedBox(width: 12),
          // Product info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF4A3F30),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item['seller'],
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF9A8A75)),
                ),
                const SizedBox(height: 8),
                // Size & color tags
                Row(
                  children: [
                    _buildTag(item['size']),
                    const SizedBox(width: 6),
                    _buildTag(item['color']),
                  ],
                ),
                const SizedBox(height: 8),
                // Quantity & price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Quantity control
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE0D0BC)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => _updateQuantity(index, -1),
                            child: Container(
                              width: 28,
                              height: 28,
                              alignment: Alignment.center,
                              child: const Icon(Icons.remove,
                                  size: 14, color: Color(0xFF9A8A75)),
                            ),
                          ),
                          Container(
                            width: 28,
                            height: 28,
                            alignment: Alignment.center,
                            child: Text(
                              '${item['quantity']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF4A3F30),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _updateQuantity(index, 1),
                            child: Container(
                              width: 28,
                              height: 28,
                              alignment: Alignment.center,
                              child: const Icon(Icons.add,
                                  size: 14, color: Color(0xFFB5976A)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '\$${_formatPrice(item['price'] * item['quantity'])}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFFB5976A),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF0E6D4),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, color: Color(0xFF7A6A55)),
      ),
    );
  }

  Widget _buildCouponField() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE0D0BC)),
            ),
            child: const TextField(
              decoration: InputDecoration(
                hintText: 'Código',
                hintStyle:
                TextStyle(color: Color(0xFFB0A090), fontSize: 14),
                border: InputBorder.none,
                contentPadding:
                EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: const Color(0xFFB5976A).withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: const Color(0xFFB5976A).withOpacity(0.3)),
          ),
          child: const Center(
            child: Text(
              'Aplicar',
              style: TextStyle(
                color: Color(0xFFB5976A),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummary() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB5976A).withOpacity(0.07),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Resumen',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: Color(0xFF4A3F30),
            ),
          ),
          const SizedBox(height: 12),
          _buildSummaryRow('Subtotal', '\$${_formatPrice(_subtotal)}'),
          const SizedBox(height: 6),
          _buildSummaryRow(
              'Envío (estimado)', '\$${_formatPrice(_shipping)}'),
          const SizedBox(height: 6),
          _buildSummaryRow('Descuento', '-\$${_formatPrice(_discount)}',
              isDiscount: true),
          const Divider(height: 20, color: Color(0xFFE0D0BC)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF4A3F30)),
              ),
              Text(
                '\$${_formatPrice(_total)}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFFB5976A)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13, color: Color(0xFF9A8A75))),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isDiscount
                ? const Color(0xFF4CAF50)
                : const Color(0xFF4A3F30),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () => Navigator.pushNamed(context, '/checkout-1'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFB5976A),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
        child: const Text(
          'Proceder al pago',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildContinueShopping() {
    return Center(
      child: GestureDetector(
        onTap: () => Navigator.pushReplacementNamed(context, '/home'),
        child: const Text(
          '← Seguir comprando',
          style: TextStyle(
            color: Color(0xFFB5976A),
            fontSize: 14,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    final items = [
      Icons.home_outlined,
      Icons.search_outlined,
      Icons.chat_bubble_outline,
      Icons.grid_view_outlined,
      Icons.person_outline,
    ];
    return Container(
      height: 65,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          return GestureDetector(
            onTap: () {
              if (i == 0) Navigator.pushReplacementNamed(context, '/home');
            },
            child: Icon(items[i],
                color: const Color(0xFF9A8A75), size: 24),
          );
        }),
      ),
    );
  }

  String _formatPrice(double price) {
    return price
        .toStringAsFixed(0)
        .replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]}.');
  }
}