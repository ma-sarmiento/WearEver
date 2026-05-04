import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MySalesScreen extends StatefulWidget {
  const MySalesScreen({super.key});
  @override
  State<MySalesScreen> createState() => _MySalesScreenState();
}

class _MySalesScreenState extends State<MySalesScreen> {
  final _db = FirebaseFirestore.instance;
  final _uid = FirebaseAuth.instance.currentUser?.uid ?? '';
  String _selectedFilter = 'Todos';

  static const _filters = ['Todos', 'Pendiente', 'Preparando', 'Enviado', 'Entregado'];
  static const _nextStatus = {
    'Pendiente': 'Preparando',
    'Preparando': 'Enviado',
    'Enviado': 'Entregado',
  };

  Color _statusColor(String estado) {
    switch (estado) {
      case 'Pendiente': return const Color(0xFFF59E0B);
      case 'Preparando': return const Color(0xFF3B82F6);
      case 'Enviado': return const Color(0xFF8B5CF6);
      case 'Entregado': return const Color(0xFF10B981);
      default: return const Color(0xFF9A8A75);
    }
  }

  Stream<List<Map<String, dynamic>>> _salesStream() {
    return _db
        .collection('orders')
        .snapshots()
        .map((snap) {
      // Filter: orders that have at least one item with vendedor_id == _uid
      final result = <Map<String, dynamic>>[];
      for (final doc in snap.docs) {
        final data = doc.data();
        final items = List<Map<String, dynamic>>.from(data['items'] ?? []);
        final isMine = items.any((item) => item['vendedor_id'] == _uid);
        if (isMine) result.add({'id': doc.id, ...data});
      }
      result.sort((a, b) {
        final aTs = a['created_at'];
        final bTs = b['created_at'];
        if (aTs == null) return 1;
        if (bTs == null) return -1;
        try {
          return (bTs as dynamic).toDate().compareTo((aTs as dynamic).toDate());
        } catch (_) { return 0; }
      });
      return result;
    });
  }

  Future<void> _advanceStatus(String orderId, String currentStatus) async {
    final next = _nextStatus[currentStatus];
    if (next == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFF5EFE6),
        title: Text('Cambiar a "$next"',
            style: const TextStyle(color: Color(0xFF4A3F30), fontSize: 16, fontWeight: FontWeight.w600)),
        content: Text('¿Confirmas que el pedido está "$next"?',
            style: const TextStyle(color: Color(0xFF9A8A75), fontSize: 14)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar', style: TextStyle(color: Color(0xFF9A8A75)))),
          TextButton(onPressed: () => Navigator.pop(ctx, true),
              child: Text('Confirmar', style: TextStyle(color: _statusColor(next), fontWeight: FontWeight.w600))),
        ],
      ),
    );

    if (confirmed == true) {
      await _db.collection('orders').doc(orderId).update({'estado': next});
    }
  }

  String _formatPrice(double p) =>
      '\$${p.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';

  String _formatDate(dynamic ts) {
    if (ts == null) return '';
    try {
      final dt = (ts as dynamic).toDate() as DateTime;
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) { return ''; }
  }

  @override
  Widget build(BuildContext context) {
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
        title: const Text('Mis ventas',
            style: TextStyle(color: Color(0xFF4A3F30), fontSize: 18, fontWeight: FontWeight.w600)),
      ),
      body: Column(children: [
        // Filter bar
        SizedBox(
          height: 44,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            itemCount: _filters.length,
            itemBuilder: (_, i) {
              final filter = _filters[i];
              final isSelected = _selectedFilter == filter;
              return GestureDetector(
                onTap: () => setState(() => _selectedFilter = filter),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8, bottom: 4, top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF3D3025) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF3D3025) : const Color(0xFFE0D0BC),
                    ),
                  ),
                  child: Center(child: Text(filter, style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF4A3F30),
                    fontSize: 13, fontWeight: FontWeight.w500,
                  ))),
                ),
              );
            },
          ),
        ),
        // Orders list
        Expanded(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: _salesStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFFB5976A)));
              }

              final allOrders = snapshot.data ?? [];
              final orders = _selectedFilter == 'Todos'
                  ? allOrders
                  : allOrders.where((o) => o['estado'] == _selectedFilter).toList();

              if (orders.isEmpty) {
                return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.storefront_outlined, size: 60, color: const Color(0xFFB5976A).withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text(
                    _selectedFilter == 'Todos' ? 'Aún no tienes ventas' : 'No hay pedidos "$_selectedFilter"',
                    style: const TextStyle(color: Color(0xFF9A8A75), fontSize: 15),
                  ),
                ]));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(14),
                itemCount: orders.length,
                itemBuilder: (_, i) => _buildOrderCard(orders[i]),
              );
            },
          ),
        ),
      ]),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final orderId = order['id'] as String;
    final estado = order['estado'] as String? ?? 'Pendiente';
    final compradorNombre = order['comprador_nombre'] as String? ?? 'Cliente';
    final total = (order['total'] as num?)?.toDouble() ?? 0;
    final items = List<Map<String, dynamic>>.from(order['items'] ?? []);
    final fecha = _formatDate(order['created_at']);
    final shortId = '#${orderId.substring(0, 8).toUpperCase()}';
    final nextStatus = _nextStatus[estado];
    final direccion = order['direccion'] as Map<String, dynamic>?;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: const Color(0xFFB5976A).withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(shortId, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF4A3F30))),
              Text(compradorNombre, style: const TextStyle(fontSize: 12, color: Color(0xFF9A8A75))),
              if (fecha.isNotEmpty) Text(fecha, style: const TextStyle(fontSize: 11, color: Color(0xFFB0A090))),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor(estado).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _statusColor(estado).withOpacity(0.3)),
                ),
                child: Text(estado, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _statusColor(estado))),
              ),
              const SizedBox(height: 4),
              Text(_formatPrice(total), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFFB5976A))),
            ]),
          ]),
        ),
        const Divider(height: 1, color: Color(0xFFF0E6D4)),
        // Items
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Column(children: items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(children: [
              const Icon(Icons.checkroom, size: 14, color: Color(0xFFB5976A)),
              const SizedBox(width: 6),
              Expanded(child: Text(
                '${item['nombre'] ?? ''} · ${item['talla'] ?? ''} x${item['cantidad'] ?? 1}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF4A3F30)),
              )),
            ]),
          )).toList()),
        ),
        // Delivery address
        if (direccion != null) ...[
          const Divider(height: 1, color: Color(0xFFF0E6D4)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(children: [
              const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFFB5976A)),
              const SizedBox(width: 6),
              Expanded(child: Text(
                direccion['direccion'] as String? ?? '',
                style: const TextStyle(fontSize: 12, color: Color(0xFF7A6A55)),
              )),
            ]),
          ),
        ],
        // Action button
        if (nextStatus != null) ...[
          const Divider(height: 1, color: Color(0xFFF0E6D4)),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _advanceStatus(orderId, estado),
                icon: const Icon(Icons.arrow_forward, size: 16),
                label: Text('Marcar como "$nextStatus"',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _statusColor(nextStatus),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
        ] else ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 12),
            child: Row(children: [
              const Icon(Icons.check_circle, size: 14, color: Color(0xFF10B981)),
              const SizedBox(width: 6),
              const Text('Pedido completado', style: TextStyle(fontSize: 12, color: Color(0xFF10B981), fontWeight: FontWeight.w500)),
            ]),
          ),
        ],
      ]),
    );
  }
}
