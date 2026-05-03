import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/bottom_nav.dart';
import '../services/firestore_service.dart';

class OrderTrackingScreen extends StatefulWidget {
  const OrderTrackingScreen({super.key});
  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  String _orderId = '';
  Map<String, dynamic>? _order;
  bool _loading = true;

  // Mapeo de estado a paso
  static const _statusSteps = ['Pendiente', 'Preparando', 'Enviado', 'Entregado'];

  int get _currentStep {
    final estado = _order?['estado'] as String? ?? 'Pendiente';
    final idx = _statusSteps.indexOf(estado);
    return idx < 0 ? 0 : idx;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      _orderId = args['order_id'] as String? ?? '';
    } else if (args is String) {
      _orderId = args;
    }
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    if (_orderId.isEmpty) { setState(() => _loading = false); return; }
    final order = await FirestoreService().getOrderById(_orderId);
    if (mounted) setState(() { _order = order; _loading = false; });
  }

  String _formatPrice(double p) =>
      '\$${p.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';

  @override
  Widget build(BuildContext context) {
    final estado = _order?['estado'] as String? ?? 'Pendiente';
    final shortId = _orderId.isNotEmpty ? '#${_orderId.substring(0, 8).toUpperCase()}' : '';
    final direccion = _order?['direccion'] as Map<String, dynamic>?;
    final metodo = _order?['metodo_pago'] as String? ?? '';
    final total = (_order?['total'] as num?)?.toDouble() ?? 0;
    final vendedorId = (_order?['items'] as List?)?.isNotEmpty == true
        ? (_order!['items'][0]['vendedor_id'] as String? ?? '')
        : '';

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
        title: Column(children: [
          const Text('Seguimiento',
              style: TextStyle(color: Color(0xFF4A3F30), fontSize: 16, fontWeight: FontWeight.w600)),
          if (shortId.isNotEmpty)
            Text(shortId, style: const TextStyle(color: Color(0xFFB5976A), fontSize: 12)),
        ]),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFB5976A)))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProgressBar(estado),
                  const SizedBox(height: 20),
                  // Estado actual
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [BoxShadow(color: const Color(0xFFB5976A).withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 3))],
                    ),
                    child: Row(children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(color: const Color(0xFFE8D5C4), borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.local_shipping_outlined, color: Color(0xFFB5976A), size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(estado, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF4A3F30))),
                          Text(_statusDescription(estado), style: const TextStyle(fontSize: 12, color: Color(0xFF9A8A75))),
                        ],
                      )),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: _orderId));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('ID copiado'), duration: Duration(seconds: 1)),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFB5976A).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('Copiar ID', style: TextStyle(fontSize: 11, color: Color(0xFFB5976A), fontWeight: FontWeight.w500)),
                        ),
                      ),
                    ]),
                  ),
                  if (direccion != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [BoxShadow(color: const Color(0xFFB5976A).withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 3))],
                      ),
                      child: Row(children: [
                        Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(color: const Color(0xFFE8D5C4), borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.location_on_outlined, color: Color(0xFFB5976A), size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(direccion['direccion'] as String? ?? direccion['address'] as String? ?? '',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF4A3F30))),
                            const Text('Destino de entrega', style: TextStyle(fontSize: 12, color: Color(0xFF9A8A75))),
                          ],
                        )),
                      ]),
                    ),
                  ],
                  const SizedBox(height: 20),
                  // Resumen del pedido
                  const Text('Detalle del pedido',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF4A3F30))),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [BoxShadow(color: const Color(0xFFB5976A).withOpacity(0.08), blurRadius: 8)],
                    ),
                    child: Column(children: [
                      ...List<Map<String, dynamic>>.from(_order?['items'] ?? []).map((item) =>
                        Padding(
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
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        const Text('Método de pago', style: TextStyle(fontSize: 12, color: Color(0xFF9A8A75))),
                        Text(_formatMetodo(metodo), style: const TextStyle(fontSize: 12, color: Color(0xFF4A3F30), fontWeight: FontWeight.w500)),
                      ]),
                      const SizedBox(height: 4),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        const Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF4A3F30))),
                        Text(_formatPrice(total), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFB5976A))),
                      ]),
                    ]),
                  ),
                  const SizedBox(height: 20),
                  Row(children: [
                    Expanded(child: OutlinedButton(
                      onPressed: () => Navigator.pushNamed(context, '/orders'),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: const Color(0xFFB5976A).withOpacity(0.5)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Ver pedidos', style: TextStyle(color: Color(0xFFB5976A), fontSize: 13, fontWeight: FontWeight.w500)),
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: ElevatedButton(
                      onPressed: vendedorId.isNotEmpty
                          ? () => Navigator.pushNamed(context, '/chat', arguments: {'other_uid': vendedorId})
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB5976A),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Contactar vendedor', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                    )),
                  ]),
                  const SizedBox(height: 20),
                ],
              ),
            ),
      bottomNavigationBar: const BottomNavWidget(currentIndex: -1),
    );
  }

  Widget _buildProgressBar(String estado) {
    final steps = ['Confirmado', 'Preparando', 'Enviado', 'Entregado'];
    return Row(
      children: steps.asMap().entries.map((e) {
        final i = e.key;
        final label = e.value;
        final isDone = i < _currentStep;
        final isActive = i == _currentStep;
        return Expanded(child: Column(children: [
          Row(children: [
            if (i > 0) Expanded(child: Container(
              height: 3,
              color: isDone || isActive ? const Color(0xFFB5976A) : const Color(0xFFE0D0BC),
            )),
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: isActive || isDone ? const Color(0xFFB5976A) : const Color(0xFFE0D0BC),
                shape: BoxShape.circle,
              ),
              child: Center(child: isDone
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : Text('${i + 1}', style: TextStyle(
                      fontSize: 11, fontWeight: FontWeight.bold,
                      color: isActive ? Colors.white : const Color(0xFF9A8A75)))),
            ),
            if (i < steps.length - 1) Expanded(child: Container(
              height: 3,
              color: isDone ? const Color(0xFFB5976A) : const Color(0xFFE0D0BC),
            )),
          ]),
          const SizedBox(height: 5),
          Text(label, style: TextStyle(
            fontSize: 9,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            color: isActive ? const Color(0xFFB5976A) : const Color(0xFF9A8A75),
          )),
        ]));
      }).toList(),
    );
  }

  String _statusDescription(String estado) {
    switch (estado) {
      case 'Pendiente': return 'Pedido recibido, esperando confirmación';
      case 'Preparando': return 'El vendedor está preparando tu pedido';
      case 'Enviado': return 'Tu pedido está en camino';
      case 'Entregado': return '¡Tu pedido fue entregado!';
      default: return estado;
    }
  }

  String _formatMetodo(String metodo) {
    switch (metodo) {
      case 'contraentrega': return 'Contraentrega';
      case 'pse': return 'PSE';
      case 'nequi': return 'Nequi';
      default: return metodo;
    }
  }
}
