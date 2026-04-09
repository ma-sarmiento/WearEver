import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';

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

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scaleAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _animController.forward();
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
        title: const Text(
          'Pedido confirmado',
          style: TextStyle(
            color: Color(0xFF4A3F30),
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildCheckmark(),
              const SizedBox(height: 20),
              const Text(
                '¡Gracias por tu compra!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A3F30),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Pedido #MNX-24819',
                style: TextStyle(fontSize: 14, color: Color(0xFFB5976A), fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 24),
              _buildShippingCard(),
              const SizedBox(height: 16),
              _buildOrderSummary(),
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
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: const Color(0xFF4CAF50).withOpacity(0.12),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF4CAF50), width: 2),
        ),
        child: const Icon(Icons.check_rounded, color: Color(0xFF4CAF50), size: 44),
      ),
    );
  }

  Widget _buildShippingCard() {
    return Container(
      padding: const EdgeInsets.all(14),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Envío',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF4A3F30))),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFFB5976A)),
              const SizedBox(width: 6),
              const Text('Cra 45 # 12-34, Medellín',
                  style: TextStyle(fontSize: 13, color: Color(0xFF7A6A55))),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 16, color: Color(0xFFB5976A)),
              const SizedBox(width: 6),
              const Text('Jue 28 Ago – Sáb 30 Ago',
                  style: TextStyle(fontSize: 13, color: Color(0xFF7A6A55))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(14),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Resumen',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF4A3F30))),
          const SizedBox(height: 12),
          _buildProductRow('Blazer Premium en Lino', '\$189.900', Icons.checkroom, const Color(0xFFE8D5C4)),
          const SizedBox(height: 8),
          _buildProductRow('Pantalón Wide Leg', '\$259.900', Icons.accessibility_new, const Color(0xFFD4C4B0)),
          const Divider(height: 20, color: Color(0xFFE0D0BC)),
          _buildSummaryRow('Subtotal', '\$449.700'),
          const SizedBox(height: 4),
          _buildSummaryRow('Envío', '\$9.900'),
          const SizedBox(height: 4),
          _buildSummaryRow('Descuento', '-\$20.000', isDiscount: true),
          const Divider(height: 16, color: Color(0xFFE0D0BC)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Total pagado',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF4A3F30))),
              Text('\$439.600',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Color(0xFFB5976A))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductRow(String name, String price, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 20, color: const Color(0xFFB5976A).withOpacity(0.6)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(name,
              style: const TextStyle(fontSize: 13, color: Color(0xFF4A3F30), fontWeight: FontWeight.w500)),
        ),
        Text(price, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFFB5976A))),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF9A8A75))),
        Text(value,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDiscount ? const Color(0xFF4CAF50) : const Color(0xFF4A3F30))),
      ],
    );
  }

  Widget _buildTrackButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: () => Navigator.pushNamed(context, '/order-tracking'),
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
      width: double.infinity,
      height: 50,
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
