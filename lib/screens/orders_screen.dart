import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  String _selectedFilter = 'Todos';

  final List<String> _filters = ['Todos', 'Pendientes', 'Preparando', 'Enviado'];

  final List<Map<String, dynamic>> _orders = [
    {
      'id': '#MNX-24819',
      'store': 'Atelier Nova',
      'items': '2 artículos',
      'price': '\$439.600',
      'status': 'Preparando',
      'statusColor': const Color(0xFFE8A000),
    },
    {
      'id': '#MNX-24410',
      'store': 'Bubble',
      'items': '1 artículo',
      'price': '\$180.900',
      'status': 'Pendiente',
      'statusColor': const Color(0xFF9A8A75),
    },
    {
      'id': '#MNX-24320',
      'store': 'Zara',
      'items': '1 artículo',
      'price': '\$129.900',
      'status': 'Enviado',
      'statusColor': const Color(0xFF4CAF50),
    },
  ];

  List<Map<String, dynamic>> get _filteredOrders {
    if (_selectedFilter == 'Todos') return _orders;
    return _orders.where((o) => o['status'] == _selectedFilter.replaceAll('s', '')).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5EFE6),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4A3F30)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Pedidos',
            style: TextStyle(color: Color(0xFF4A3F30), fontSize: 18, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          Expanded(child: _buildOrderList()),
        ],
      ),
      bottomNavigationBar: const BottomNavWidget(currentIndex: -1),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
        child: const Row(
          children: [
            SizedBox(width: 12),
            Icon(Icons.search, color: Color(0xFFB5976A), size: 20),
            SizedBox(width: 8),
            Text('Buscar pedido, comprador...',
                style: TextStyle(color: Color(0xFFB0A090), fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = filter),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFB5976A) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? const Color(0xFFB5976A) : const Color(0xFFE0D0BC),
                ),
              ),
              child: Text(filter,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? Colors.white : const Color(0xFF7A6A55))),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderList() {
    final orders = _filteredOrders;
    if (orders.isEmpty) {
      return const Center(
        child: Text('No hay pedidos en esta categoría',
            style: TextStyle(color: Color(0xFF9A8A75), fontSize: 14)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) => _buildOrderCard(orders[index]),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFFB5976A).withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(order['id'],
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF4A3F30))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (order['statusColor'] as Color).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(order['status'],
                    style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w600, color: order['statusColor'])),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.store_outlined, size: 14, color: Color(0xFF9A8A75)),
              const SizedBox(width: 5),
              Text(order['store'],
                  style: const TextStyle(fontSize: 12, color: Color(0xFF9A8A75))),
              const SizedBox(width: 12),
              const Icon(Icons.inventory_2_outlined, size: 14, color: Color(0xFF9A8A75)),
              const SizedBox(width: 5),
              Text(order['items'],
                  style: const TextStyle(fontSize: 12, color: Color(0xFF9A8A75))),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(order['price'],
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFFB5976A))),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/order-tracking'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB5976A),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Ver detalle',
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

}
