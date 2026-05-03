import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';
import '../services/firestore_service.dart';

class OrderConfirmedScreen extends StatefulWidget {
  const OrderConfirmedScreen({super.key});
  @override
  State<OrderConfirmedScreen> createState() => _OrderConfirmedScreenState();
}

class _OrderConfirmedScreenState extends State<OrderConfirmedScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  String _orderId = '';
  double _total = 0;
  Map<String, dynamic>? _order;
  bool _loading = true;

  String _formatPrice(double p) =>
      '\$${p.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _scaleAnim = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _animController, curve: Curves.elasticOut));
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      _orderId = args['order_id'] as String? ?? '';
      _total = (args['total'] as num?)?.toDouble() ?? 0;
      if (_orderId.isNotEmpty) _loadOrder();
    } else {
      setState(() => _loading = false);
    }
  }

  Future<void> _loadOrder() async {
    final order = await FirestoreService().getOrderById(_orderId);
    if (mounted) setState(() { _order = order; _loading = false; });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5EFE6),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Pedido confirmado',
            style: TextStyle(color: Color(0xFF4A3F30), fontSize: 17, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFB5976A)))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildCheckmark(),
                    const SizedBox(height: 20),
                    const Text('¡Gracias por tu compra!',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF4A3F30))),
                    const SizedBox(height: 6),
                    Text('Pedido #${_orderId.substring(0, 8).toUpperCase()}',
                        style: const TextStyle(fontSize: 14, color: Color(0xFFB5976A), fontWeight: FontWeight.w500)),
                    const SizedBox(height: 24),
                    _buildSummaryCard(),
                    const SizedBox(height: 24),
                    _buildTrackButton(context),
                    const SizedBox(height: 12),
                    _buildContinueButton(context),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: const BottomNavWidget(currentIndex: -1),
    );
  }

  Widget _buildCheckmark() {
    return ScaleTransition(
      scale: _scaleAnim,
      child: Container(
        width: 80, height: 80,
        decoration: BoxDecoration(
          color: const Color(0xFF4CAF50).withOpacity(0.12),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF4CAF50), width: 2),
        ),
        child: const Icon(Icons.check_rounded, color: Color(0xFF4CAF50), size: 44),
      ),
    );
  }

  Widget _buildSummaryCard() {
    final items = _order != null
        ? List<Map<String, dynamic>>.from(_order!['items'] ?? [])
        : [];
    final subtotal = (_order?['subtotal'] as num?)?.toDouble() ?? 0;
    final envio = (_order?['envio'] as num?)?.toDouble() ?? 0;
    final total = (_order?['total'] as num?)?.toDouble() ?? _total;
    final direccion = _order?['direccion'] as Map<String, dynamic>?;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: const Color(0xFFB5976A).withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Resumen del pedido',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF4A3F30))),
          const SizedBox(height: 12),
          if (items.isNotEmpty) ...[
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(children: [
                Expanded(child: Text(
                  '${item['nombre'] ?? ''} · ${item['talla'] ?? ''} x${item['cantidad'] ?? 1}',
                  style: const TextStyle(fontSize: 13, color: Color(0xFF4A3F30)),
                )),
                Text(_formatPrice(((item['precio'] as num?)?.toDouble() ?? 0) *
                    ((item['cantidad'] as num?)?.toInt() ?? 1)),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFFB5976A))),
              ]),
            )),
            const Divider(color: Color(0xFFE0D0BC)),
          ],
          if (direccion != null) ...[
            Row(children: [
              const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFFB5976A)),
              const SizedBox(width: 6),
              Expanded(child: Text(direccion['direccion'] as String? ?? '',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF7A6A55)))),
            ]),
            const SizedBox(height: 8),
          ],
          _summaryRow('Subtotal', _formatPrice(subtotal)),
          const SizedBox(height: 4),
          _summaryRow('Envío', _formatPrice(envio)),
          const Divider(height: 16, color: Color(0xFFE0D0BC)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total pagado',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF4A3F30))),
              Text(_formatPrice(total),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Color(0xFFB5976A))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF9A8A75))),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF4A3F30))),
      ],
    );
  }

  Widget _buildTrackButton(BuildContext context) {
    return SizedBox(
      width: double.infinity, height: 52,
      child: ElevatedButton.icon(
        onPressed: () => Navigator.pushNamed(context, '/order-tracking',
            arguments: {'order_id': _orderId}),
        icon: const Icon(Icons.local_shipping_outlined),
        label: const Text('Rastrear pedido', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFB5976A),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    return SizedBox(
      width: double.infinity, height: 50,
      child: OutlinedButton(
        onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: const Color(0xFFB5976A).withOpacity(0.5)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: const Text('Seguir comprando',
            style: TextStyle(fontSize: 15, color: Color(0xFFB5976A), fontWeight: FontWeight.w500)),
      ),
    );
  }
}
