import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';

class CheckoutStep2Screen extends StatefulWidget {
  const CheckoutStep2Screen({super.key});
  @override
  State<CheckoutStep2Screen> createState() => _CheckoutStep2ScreenState();
}

class _CheckoutStep2ScreenState extends State<CheckoutStep2Screen> {
  String _selectedPayment = 'contraentrega';
  Map<String, dynamic> _checkoutData = {};

  final List<Map<String, dynamic>> _paymentMethods = [
    {'id': 'contraentrega', 'label': 'Contraentrega', 'subtitle': 'Pago al recibir el pedido',
     'badge': 'CASH', 'badgeColor': const Color(0xFF9A8A75)},
    {'id': 'pse', 'label': 'PSE', 'subtitle': 'Débito bancario en línea',
     'badge': 'PSE', 'badgeColor': const Color(0xFF00A651)},
    {'id': 'nequi', 'label': 'Nequi', 'subtitle': 'Pago con billetera digital',
     'badge': 'NEQUI', 'badgeColor': const Color(0xFF8C00FF)},
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      _checkoutData = args;
    }
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
        title: const Text('Checkout (2/3)',
            style: TextStyle(color: Color(0xFF4A3F30), fontSize: 17, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStepIndicator(2),
            const SizedBox(height: 24),
            _buildSectionTitle('Método de pago'),
            const SizedBox(height: 12),
            ..._paymentMethods.map((method) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildPaymentOption(method),
            )),
            const SizedBox(height: 32),
            _buildContinueButton(),
            const SizedBox(height: 20),
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

  Widget _buildSectionTitle(String title) => Text(title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF4A3F30)));

  Widget _buildPaymentOption(Map<String, dynamic> method) {
    final isSelected = _selectedPayment == method['id'];
    return GestureDetector(
      onTap: () => setState(() => _selectedPayment = method['id']),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFFB5976A) : const Color(0xFFE0D0BC),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(children: [
          Container(
            width: 20, height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? const Color(0xFFB5976A) : const Color(0xFFE0D0BC),
                width: 2,
              ),
            ),
            child: isSelected
                ? Center(child: Container(
                    width: 10, height: 10,
                    decoration: const BoxDecoration(color: Color(0xFFB5976A), shape: BoxShape.circle)))
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(method['label'], style: TextStyle(
                fontWeight: FontWeight.w500, fontSize: 14,
                color: isSelected ? const Color(0xFF4A3F30) : const Color(0xFF7A6A55))),
              Text(method['subtitle'], style: const TextStyle(fontSize: 12, color: Color(0xFF9A8A75))),
            ],
          )),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: (method['badgeColor'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: (method['badgeColor'] as Color).withOpacity(0.3)),
            ),
            child: Text(method['badge'],
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: method['badgeColor'])),
          ),
        ]),
      ),
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity, height: 52,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, '/checkout-3', arguments: {
            ..._checkoutData,
            'metodo_pago': _selectedPayment,
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFB5976A),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: const Text('Continuar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
