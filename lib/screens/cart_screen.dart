import 'package:flutter/material.dart';
import '../widgets/smart_back_button.dart';
import '../widgets/bottom_nav.dart';
import '../services/firestore_service.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  String _formatPrice(double price) {
    return '\$${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      appBar: _buildAppBar(context, firestoreService),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: firestoreService.getCartStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFB5976A)),
            );
          }

          final items = snapshot.data ?? [];

          if (items.isEmpty) {
            return _buildEmptyCart(context);
          }

          final subtotal = items.fold<double>(
            0,
            (sum, item) =>
                sum +
                ((item['precio'] as num?)?.toDouble() ?? 0) *
                    ((item['cantidad'] as int?) ?? 1),
          );
          const shipping = 9900.0;
          final total = subtotal + shipping;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  itemCount: items.length,
                  itemBuilder: (context, index) =>
                      _buildCartItem(context, items[index], firestoreService),
                ),
              ),
              _buildSummary(context, subtotal, shipping, total, items),
            ],
          );
        },
      ),
      bottomNavigationBar: const BottomNavWidget(currentIndex: -1),
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, FirestoreService service) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: const Color(0xFFF5EFE6),
      elevation: 0,
        title: const Text(
        'Carrito',
        style: TextStyle(
            color: Color(0xFF4A3F30),
            fontSize: 18,
            fontWeight: FontWeight.w600),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.delete_outline, color: Color(0xFF9A8A75)),
          tooltip: 'Vaciar carrito',
          onPressed: () async {
            await service.clearCart();
          },
        ),
      ],
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined,
              size: 72,
              color: const Color(0xFFB5976A).withOpacity(0.3)),
          const SizedBox(height: 16),
          const Text(
            'Tu carrito está vacío',
            style: TextStyle(
                color: Color(0xFF9A8A75),
                fontSize: 16,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          const Text(
            'Agrega prendas desde el catálogo',
            style: TextStyle(color: Color(0xFFB0A090), fontSize: 13),
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/explore'),
            child: const Text('Explorar',
                style: TextStyle(color: Color(0xFFB5976A))),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, Map<String, dynamic> item,
      FirestoreService service) {
    final fotos = List<String>.from(item['fotos'] ?? []);
    final precio = (item['precio'] as num?)?.toDouble() ?? 0;
    final cantidad = (item['cantidad'] as int?) ?? 1;
    final cartItemId = item['cartItemId'] as String;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFFB5976A).withOpacity(0.07),
              blurRadius: 8,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          // Imagen
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 80,
              height: 80,
              child: fotos.isNotEmpty
                  ? Image.network(fotos.first, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder())
                  : _placeholder(),
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['nombre'] as String? ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4A3F30),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${item['vendedor_nombre'] ?? ''} · Talla ${item['talla'] ?? ''}',
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF9A8A75)),
                ),
                const SizedBox(height: 6),
                Text(
                  _formatPrice(precio),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFB5976A),
                  ),
                ),
              ],
            ),
          ),
          // Cantidad
          Column(
            children: [
              _buildQtyButton(
                icon: Icons.add,
                onTap: () =>
                    service.updateCartQuantity(cartItemId, cantidad + 1),
              ),
              const SizedBox(height: 4),
              Text(
                '$cantidad',
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4A3F30)),
              ),
              const SizedBox(height: 4),
              _buildQtyButton(
                icon: Icons.remove,
                onTap: () =>
                    service.updateCartQuantity(cartItemId, cantidad - 1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQtyButton(
      {required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE0D0BC)),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Icon(icon, size: 16, color: const Color(0xFF4A3F30)),
      ),
    );
  }

  Widget _buildSummary(BuildContext context, double subtotal, double shipping,
      double total, List<Map<String, dynamic>> items) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 12,
              offset: const Offset(0, -3)),
        ],
      ),
      child: Column(
        children: [
          _buildSummaryRow('Subtotal', _formatPrice(subtotal)),
          const SizedBox(height: 6),
          _buildSummaryRow('Envío estimado', _formatPrice(shipping)),
          const Divider(height: 20, color: Color(0xFFE8DDD0)),
          _buildSummaryRow('Total', _formatPrice(total), isBold: true),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () =>
                  Navigator.pushNamed(context, '/checkout-1',
                      arguments: {'items': items, 'total': total}),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB5976A),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text(
                'Ir al pago',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {bool isBold = false}) {
    final style = TextStyle(
      fontSize: isBold ? 16 : 14,
      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
      color: isBold ? const Color(0xFF4A3F30) : const Color(0xFF9A8A75),
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(value,
            style: style.copyWith(color: const Color(0xFF4A3F30))),
      ],
    );
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xFFE8D5C4),
      child: Center(
        child: Icon(Icons.checkroom,
            color: const Color(0xFFB5976A).withOpacity(0.4)),
      ),
    );
  }
}