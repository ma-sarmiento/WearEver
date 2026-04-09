import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OrderTrackingScreen extends StatefulWidget {
  const OrderTrackingScreen({super.key});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _steps = [
    {'label': 'Confirmado', 'done': true, 'active': true},
    {'label': 'Preparando', 'done': false, 'active': false},
    {'label': 'Enviado', 'done': false, 'active': false},
    {'label': 'Entregado', 'done': false, 'active': false},
  ];

  final List<Map<String, dynamic>> _updates = [
    {'title': 'En camino', 'subtitle': 'Salió del centro de distribución', 'time': '09:42'},
    {'title': 'Pedido despachado', 'subtitle': 'Guía generada', 'time': '08:05'},
    {'title': 'Preparando pedido', 'subtitle': 'La tienda aceptó tu compra', 'time': '07:20'},
  ];

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
        title: const Column(
          children: [
            Text('Seguimiento',
                style: TextStyle(color: Color(0xFF4A3F30), fontSize: 16, fontWeight: FontWeight.w600)),
            Text('#MNX-24819',
                style: TextStyle(color: Color(0xFFB5976A), fontSize: 12)),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProgressBar(),
            const SizedBox(height: 8),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFB5976A).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Jue 28 Ago – Sáb 30 Ago',
                    style: TextStyle(fontSize: 12, color: Color(0xFFB5976A), fontWeight: FontWeight.w500)),
              ),
            ),
            const SizedBox(height: 20),
            _buildCarrierCard(),
            const SizedBox(height: 12),
            _buildDestinationCard(context),
            const SizedBox(height: 20),
            const Text('Actualizaciones',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF4A3F30))),
            const SizedBox(height: 12),
            _buildTimeline(),
            const SizedBox(height: 20),
            _buildAiBubble(),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: const Color(0xFFB5976A).withOpacity(0.5)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Ver detalles',
                        style: TextStyle(color: Color(0xFFB5976A), fontSize: 13, fontWeight: FontWeight.w500)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/chat'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB5976A),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Contactar vendedor',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildProgressBar() {
    return Row(
      children: List.generate(_steps.length, (i) {
        final step = _steps[i];
        final isActive = step['active'] as bool;
        final isDone = step['done'] as bool;
        return Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  if (i > 0)
                    Expanded(
                      child: Container(
                        height: 3,
                        color: isDone || isActive ? const Color(0xFFB5976A) : const Color(0xFFE0D0BC),
                      ),
                    ),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isActive || isDone ? const Color(0xFFB5976A) : const Color(0xFFE0D0BC),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: isDone && !isActive
                          ? const Icon(Icons.check, size: 14, color: Colors.white)
                          : Text(
                              '${i + 1}',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isActive ? Colors.white : const Color(0xFF9A8A75)),
                            ),
                    ),
                  ),
                  if (i < _steps.length - 1)
                    Expanded(
                      child: Container(
                        height: 3,
                        color: const Color(0xFFE0D0BC),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                step['label'],
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                    color: isActive ? const Color(0xFFB5976A) : const Color(0xFF9A8A75)),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCarrierCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: const Color(0xFFB5976A).withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: const Color(0xFFE8D5C4), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.local_shipping_outlined, color: Color(0xFFB5976A), size: 22),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Servientrega',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF4A3F30))),
                Text('TRK-9F28-21C',
                    style: TextStyle(fontSize: 12, color: Color(0xFF9A8A75))),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Clipboard.setData(const ClipboardData(text: 'TRK-9F28-21C'));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Código copiado'), duration: Duration(seconds: 1)),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFB5976A).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('Copiar',
                  style: TextStyle(fontSize: 12, color: Color(0xFFB5976A), fontWeight: FontWeight.w500)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDestinationCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: const Color(0xFFB5976A).withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: const Color(0xFFE8D5C4), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.location_on_outlined, color: Color(0xFFB5976A), size: 22),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Cra 45 # 12-34, Bogotá',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF4A3F30))),
                Text('Destino de entrega',
                    style: TextStyle(fontSize: 12, color: Color(0xFF9A8A75))),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/map'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFB5976A).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('Ver en mapa',
                  style: TextStyle(fontSize: 12, color: Color(0xFFB5976A), fontWeight: FontWeight.w500)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    return Column(
      children: _updates.asMap().entries.map((e) {
        final i = e.key;
        final update = e.value;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: i == 0 ? const Color(0xFFB5976A) : const Color(0xFFE0D0BC),
                    shape: BoxShape.circle,
                  ),
                ),
                if (i < _updates.length - 1)
                  Container(
                    width: 2,
                    height: 46,
                    color: const Color(0xFFE0D0BC),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(update['title'],
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: i == 0 ? FontWeight.w600 : FontWeight.w500,
                                  color: const Color(0xFF4A3F30))),
                          Text(update['subtitle'],
                              style: const TextStyle(fontSize: 12, color: Color(0xFF9A8A75))),
                        ],
                      ),
                    ),
                    Text(update['time'],
                        style: const TextStyle(fontSize: 12, color: Color(0xFF9A8A75))),
                  ],
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildAiBubble() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0E6D4),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: const Color(0xFF3D3025), borderRadius: BorderRadius.circular(8)),
            child: const Center(
              child: Text('AI',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Recuerda que puedes preguntarle a Tito sobre el estado de tus pedidos en el chat',
              style: TextStyle(fontSize: 12, color: Color(0xFF4A3F30), height: 1.4),
            ),
          ),
        ],
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
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final isSelected = _selectedIndex == i;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedIndex = i);
              if (i == 0) Navigator.pushReplacementNamed(context, '/home');
              if (i == 1) Navigator.pushReplacementNamed(context, '/explore');
              if (i == 2) Navigator.pushReplacementNamed(context, '/chats-list');
              if (i == 3) Navigator.pushReplacementNamed(context, '/saved');
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: isSelected
                  ? BoxDecoration(
                      color: const Color(0xFFB5976A).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    )
                  : null,
              child: Icon(items[i],
                  color: isSelected ? const Color(0xFFB5976A) : const Color(0xFF9A8A75), size: 24),
            ),
          );
        }),
      ),
    );
  }
}
