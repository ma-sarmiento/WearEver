import 'package:flutter/material.dart';

class CheckoutStep2Screen extends StatefulWidget {
  const CheckoutStep2Screen({super.key});

  @override
  State<CheckoutStep2Screen> createState() => _CheckoutStep2ScreenState();
}

class _CheckoutStep2ScreenState extends State<CheckoutStep2Screen> {
  String _selectedPayment = 'card';

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'card',
      'label': 'Tarjeta terminada en **** 1234',
      'subtitle': 'VISA • 12/27',
      'badge': 'VISA',
      'badgeColor': const Color(0xFF1A1F71),
    },
    {
      'id': 'pse',
      'label': 'PSE',
      'subtitle': 'Débito bancario',
      'badge': 'PSE',
      'badgeColor': const Color(0xFF00A651),
    },
    {
      'id': 'cash',
      'label': 'Contraentrega',
      'subtitle': 'Pago al recibir',
      'badge': 'CASH',
      'badgeColor': const Color(0xFF9A8A75),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      appBar: _buildAppBar(),
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
            const SizedBox(height: 8),
            _buildAddNewCard(),
            const SizedBox(height: 24),
            _buildAiRecommendation(),
            const SizedBox(height: 24),
            _buildSelectPaymentButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF5EFE6),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF4A3F30)),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Checkout (2/3)',
        style: TextStyle(
          color: Color(0xFF4A3F30),
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.more_horiz, color: Color(0xFF4A3F30)),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildStepIndicator(int currentStep) {
    return Row(
      children: List.generate(3, (i) {
        final step = i + 1;
        final isActive = step == currentStep;
        final isCompleted = step < currentStep;
        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: isActive || isCompleted
                        ? const Color(0xFFB5976A)
                        : const Color(0xFFE0D0BC),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              if (i < 2) const SizedBox(width: 4),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFF4A3F30),
      ),
    );
  }

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
            color: isSelected
                ? const Color(0xFFB5976A)
                : const Color(0xFFE0D0BC),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFB5976A).withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Radio button
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFB5976A)
                      : const Color(0xFFE0D0BC),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFFB5976A),
                    shape: BoxShape.circle,
                  ),
                ),
              )
                  : null,
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method['label'],
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: isSelected
                          ? const Color(0xFF4A3F30)
                          : const Color(0xFF7A6A55),
                    ),
                  ),
                  Text(
                    method['subtitle'],
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF9A8A75)),
                  ),
                ],
              ),
            ),
            // Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: (method['badgeColor'] as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                    color: (method['badgeColor'] as Color).withOpacity(0.3)),
              ),
              child: Text(
                method['badge'],
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: method['badgeColor'],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddNewCard() {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.add, size: 18, color: Color(0xFFB5976A)),
        label: const Text(
          'Agregar nueva tarjeta',
          style: TextStyle(
              color: Color(0xFFB5976A),
              fontSize: 14,
              fontWeight: FontWeight.w500),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: const Color(0xFFB5976A).withOpacity(0.4)),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildAiRecommendation() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0E6D4),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF3D3025),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text('AI',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Tito sabe con qué puedes complementar tu outfit',
              style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF4A3F30),
                  height: 1.4,
                  fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            children: [
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  color: const Color(0xFFD4C4B0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.person_outline,
                    color: Color(0xFFB5976A), size: 28),
              ),
              const SizedBox(height: 4),
              const Text(
                'Nombre prenda',
                style: TextStyle(fontSize: 9, color: Color(0xFF9A8A75)),
              ),
              const Text(
                '\$33,543',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A3F30)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSelectPaymentButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () => Navigator.pushNamed(context, '/checkout-3'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFB5976A),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
        child: const Text(
          'Seleccionar pago',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
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
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(
          items.length,
              (i) => GestureDetector(
            onTap: () {
              if (i == 0) Navigator.pushReplacementNamed(context, '/home');
              if (i == 2) Navigator.pushReplacementNamed(context, '/chats-list');
            },
            child: Icon(items[i],
                color: const Color(0xFF9A8A75), size: 24),
          ),
        ),
      ),
    );
  }
}