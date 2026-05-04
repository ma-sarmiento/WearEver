import 'package:flutter/material.dart';
import '../widgets/smart_back_button.dart';
import '../widgets/bottom_nav.dart';
import '../services/firestore_service.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  String _selectedFilter = 'Todos';
  final _firestoreService = FirestoreService();

  final List<String> _filters = [
    'Todos',
    'Pendiente',
    'Alistando',
    'Enviado',
    'Entregado',
  ];

  Color _statusColor(String estado) {
    switch (estado) {
      case 'Alistando':
        return const Color(0xFFE8A000);
      case 'Enviado':
        return const Color(0xFF4CAF50);
      case 'Entregado':
        return const Color(0xFF2196F3);
      default:
        return const Color(0xFF9A8A75);
    }
  }

  String _formatPrice(double price) {
    return '\$${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return '';
    try {
      final dt = (timestamp as dynamic).toDate() as DateTime;
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return '';
    }
  }

  Future<void> _cancelOrder(String orderId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancelar pedido',
            style: TextStyle(color: Color(0xFF4A3F30), fontWeight: FontWeight.w600)),
        content: const Text(
          '¿Seguro que quieres cancelar este pedido? Esta acción no se puede deshacer.',
          style: TextStyle(color: Color(0xFF9A8A75), fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No, mantener',
                style: TextStyle(color: Color(0xFF9A8A75))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sí, cancelar',
                style: TextStyle(color: Color(0xFFD32F2F), fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await _firestoreService.cancelOrder(orderId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pedido cancelado'),
            backgroundColor: Color(0xFF4A3F30),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: const Color(0xFFD32F2F),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFF5EFE6),
        elevation: 0,
        title: const Text('Pedidos',
            style: TextStyle(
                color: Color(0xFF4A3F30),
                fontSize: 18,
                fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(child: _buildOrdersList()),
        ],
      ),
      bottomNavigationBar: const BottomNavWidget(currentIndex: -1),
    );
  }

  Widget _buildFilterBar() {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = filter),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF3D3025)
                    : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF3D3025)
                      : const Color(0xFFE0D0BC),
                ),
              ),
              child: Center(
                child: Text(
                  filter,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : const Color(0xFF4A3F30),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrdersList() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _firestoreService.getOrdersStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFB5976A)),
          );
        }

        final allOrders = snapshot.data ?? [];
        final orders = _selectedFilter == 'Todos'
            ? allOrders
            : allOrders
            .where((o) => o['estado'] == _selectedFilter)
            .toList();

        if (orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long_outlined,
                    size: 64,
                    color: const Color(0xFFB5976A).withOpacity(0.3)),
                const SizedBox(height: 16),
                Text(
                  _selectedFilter == 'Todos'
                      ? 'Aún no tienes pedidos'
                      : 'No hay pedidos en "$_selectedFilter"',
                  style: const TextStyle(
                      color: Color(0xFF9A8A75), fontSize: 15),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(14),
          itemCount: orders.length,
          itemBuilder: (context, index) =>
              _buildOrderCard(orders[index]),
        );
      },
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final orderId = order['id'] as String? ?? '';
    final estado = order['estado'] as String? ?? 'Pendiente';
    final total = (order['total'] as num?)?.toDouble() ?? 0;
    final items = List<dynamic>.from(order['items'] ?? []);
    final date = _formatDate(order['created_at']);
    final shortId = '#${orderId.substring(0, orderId.length.clamp(0, 8)).toUpperCase()}';
    final isPendiente = estado == 'Pendiente';

    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        '/order-tracking',
        arguments: order,
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFB5976A).withOpacity(0.07),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  shortId,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A3F30),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _statusColor(estado).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        estado,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _statusColor(estado),
                        ),
                      ),
                    ),
                    // Botón cancelar solo en Pendiente
                    if (isPendiente) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _cancelOrder(orderId),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD32F2F).withOpacity(0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: const Color(0xFFD32F2F).withOpacity(0.3)),
                          ),
                          child: const Text(
                            'Cancelar',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFD32F2F),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${items.length} artículo${items.length != 1 ? 's' : ''}',
              style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF9A8A75)),
            ),
            if (date.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                date,
                style: const TextStyle(
                    fontSize: 12, color: Color(0xFFB0A090)),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatPrice(total),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFB5976A),
                  ),
                ),
                const Row(
                  children: [
                    Text(
                      'Ver detalle',
                      style: TextStyle(
                          fontSize: 13, color: Color(0xFFB5976A)),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios,
                        size: 12, color: Color(0xFFB5976A)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}