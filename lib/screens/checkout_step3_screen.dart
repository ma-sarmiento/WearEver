import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';
import '../services/firestore_service.dart';

class CheckoutStep3Screen extends StatefulWidget {
  const CheckoutStep3Screen({super.key});
  @override
  State<CheckoutStep3Screen> createState() => _CheckoutStep3ScreenState();
}

class _CheckoutStep3ScreenState extends State<CheckoutStep3Screen> {
  final _firestoreService = FirestoreService();
  bool _placing = false;
  Map<String, dynamic> _checkoutData = {};
  List<Map<String, dynamic>> _cartItems = [];
  bool _loadingCart = true;

  double get _subtotal => _cartItems.fold(0, (sum, item) {
    final precio = (item['precio'] as num?)?.toDouble() ?? 0;
    final cantidad = (item['cantidad'] as num?)?.toInt() ?? 1;
    return sum + precio * cantidad;
  });

  double get _shippingCost => (_checkoutData['shipping_cost'] as num?)?.toDouble() ?? 9900;
  double get _total => _subtotal + _shippingCost;

  String _formatPrice(double p) =>
      '\$${p.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      _checkoutData = args;
    }
    _loadCart();
  }

  Future<void> _loadCart() async {
    final items = await _firestoreService.getCartStream().first;
    if (mounted) setState(() { _cartItems = items; _loadingCart = false; });
  }

  Future<void> _placeOrder() async {
    if (_placing || _cartItems.isEmpty) return;
    setState(() => _placing = true);
    try {
      final direccion = _checkoutData['direccion'] as Map<String, dynamic>? ?? {};
      final metodoPago = _checkoutData['metodo_pago'] as String? ?? 'contraentrega';
      final shipping = _checkoutData['shipping'] as String? ?? 'standard';

      final items = _cartItems.map((item) => {
        'product_id': item['product_id'],
        'nombre': item['nombre'],
        'precio': item['precio'],
        'talla': item['talla'],
        'cantidad': item['cantidad'],
        'vendedor_nombre': item['vendedor_nombre'],
        'foto': (item['fotos'] as List?)?.isNotEmpty == true ? item['fotos'][0] : '',
      }).toList();

      final orderId = await _firestoreService.createOrder(
        items: items,
        direccion: {...direccion, 'tipo_envio': shipping},
        metodoPago: metodoPago,
        subtotal: _subtotal,
        envio: _shippingCost,
        total: _total,
      );

      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          '/order-confirmed',
          arguments: {'order_id': orderId, 'total': _total},
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al procesar: $e'), backgroundColor: Colors.red),
        );
        setState(() => _placing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final direccion = _checkoutData['direccion'] as Map<String, dynamic>?;
    final metodo = _checkoutData['metodo_pago'] as String? ?? 'contraentrega';
    final shipping = _checkoutData['shipping'] as String? ?? 'standard';

    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5EFE6),
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4A3F30)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Checkout (3/3)',
            style: TextStyle(color: Color(0xFF4A3F30), fontSize: 17, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: _loadingCart
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFB5976A)))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStepIndicator(3),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Tu pedido'),
                  const SizedBox(height: 12),
                  ..._cartItems.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildCartItem(item),
                  )),
                  const SizedBox(height: 16),
                  _buildSectionTitle('Envío a'),
                  const SizedBox(height: 10),
                  _buildInfoCard(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(direccion?['direccion'] as String? ?? 'Sin dirección',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF4A3F30))),
                      Text(shipping == 'express' ? 'Exprés (24–48 h)' : 'Estándar (3–5 días)',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF9A8A75))),
                    ],
                  )),
                  const SizedBox(height: 16),
                  _buildSectionTitle('Pago'),
                  const SizedBox(height: 10),
                  _buildInfoCard(child: Text(
                    metodo == 'contraentrega' ? 'Contraentrega'
                        : metodo == 'pse' ? 'PSE – Débito bancario'
                        : 'Nequi',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF4A3F30)),
                  )),
                  const SizedBox(height: 20),
                  _buildSummary(),
                  const SizedBox(height: 12),
                  const Text('Al pagar aceptas nuestros Términos y Condiciones.',
                      style: TextStyle(fontSize: 11, color: Color(0xFF9A8A75))),
                  const SizedBox(height: 20),
                  _buildPayButton(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
      bottomNavigationBar: const BottomNavWidget(currentIndex: -1),
    );
  }

  Widget _buildStepIndicator(int currentStep) {
    return Row(children: List.generate(3, (i) {
      final step = i + 1;
      return Expanded(child: Row(children: [
        Expanded(child: Container(
          height: 4,
          decoration: BoxDecoration(
            color: step <= currentStep ? const Color(0xFFB5976A) : const Color(0xFFE0D0BC),
            borderRadius: BorderRadius.circular(2),
          ),
        )),
        if (i < 2) const SizedBox(width: 4),
      ]));
    }));
  }

  Widget _buildSectionTitle(String t) => Text(t,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF4A3F30)));

  Widget _buildCartItem(Map<String, dynamic> item) {
    final fotos = List<String>.from(item['fotos'] ?? []);
    final precio = (item['precio'] as num?)?.toDouble() ?? 0;
    final cantidad = (item['cantidad'] as num?)?.toInt() ?? 1;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: const Color(0xFFB5976A).withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Row(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: fotos.isNotEmpty
              ? Image.network(fotos.first, width: 56, height: 56, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(width: 56, height: 56,
                      color: const Color(0xFFE8D5C4),
                      child: const Icon(Icons.checkroom, color: Color(0xFFB5976A), size: 28)))
              : Container(width: 56, height: 56, color: const Color(0xFFE8D5C4),
                  child: const Icon(Icons.checkroom, color: Color(0xFFB5976A), size: 28)),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item['nombre'] as String? ?? '',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF4A3F30))),
            Text('Talla ${item['talla'] ?? ''} · x$cantidad',
                style: const TextStyle(fontSize: 12, color: Color(0xFF9A8A75))),
          ],
        )),
        Text(_formatPrice(precio * cantidad),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFB5976A))),
      ]),
    );
  }

  Widget _buildInfoCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: const Color(0xFFB5976A).withOpacity(0.07), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: child,
    );
  }

  Widget _buildSummary() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: const Color(0xFFB5976A).withOpacity(0.07), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(children: [
        _summaryRow('Subtotal', _formatPrice(_subtotal)),
        const SizedBox(height: 6),
        _summaryRow('Envío', _formatPrice(_shippingCost)),
        const Divider(height: 20, color: Color(0xFFE0D0BC)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF4A3F30))),
            Text(_formatPrice(_total), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFFB5976A))),
          ],
        ),
      ]),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF9A8A75))),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF4A3F30))),
      ],
    );
  }

  Widget _buildPayButton() {
    return SizedBox(
      width: double.infinity, height: 52,
      child: ElevatedButton(
        onPressed: _placing ? null : _placeOrder,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFB5976A),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: _placing
            ? const SizedBox(width: 20, height: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text('Pagar ahora', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
