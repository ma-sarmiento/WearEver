import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';

class CheckoutStep1Screen extends StatefulWidget {
  const CheckoutStep1Screen({super.key});

  @override
  State<CheckoutStep1Screen> createState() => _CheckoutStep1ScreenState();
}

class _CheckoutStep1ScreenState extends State<CheckoutStep1Screen> {
  String _selectedShipping = 'standard';

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
            _buildStepIndicator(1),
            const SizedBox(height: 24),
            _buildSectionTitle('Dirección de envío'),
            const SizedBox(height: 12),
            _buildAddressCard(),
            const SizedBox(height: 12),
            _buildAddNewAddress(),
            const SizedBox(height: 24),
            _buildSectionTitle('Envío'),
            const SizedBox(height: 12),
            _buildShippingOption(
              id: 'standard',
              label: 'Estándar (3–5 días)',
              subtitle: '\$8.900',
              price: '\$9.900',
            ),
            const SizedBox(height: 10),
            _buildShippingOption(
              id: 'express',
              label: 'Exprés (24–48 h)',
              subtitle: '\$19.900',
              price: '\$19.900',
            ),
            const SizedBox(height: 32),
            _buildContinueButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavWidget(currentIndex: -1),
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
        'Checkout (1/3)',
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

  Widget _buildAddressCard() {
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Juliana Pérez',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Color(0xFF4A3F30),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Cra 45 # 12-34, Apto 402',
                  style: TextStyle(fontSize: 13, color: Color(0xFF7A6A55)),
                ),
                Text(
                  'Medellín, Antioquia',
                  style: TextStyle(fontSize: 13, color: Color(0xFF7A6A55)),
                ),
                Text(
                  '+57 300 123 4567',
                  style: TextStyle(fontSize: 13, color: Color(0xFF7A6A55)),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              backgroundColor: const Color(0xFFB5976A).withOpacity(0.1),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text(
              'Cambiar',
              style: TextStyle(
                  color: Color(0xFFB5976A),
                  fontSize: 12,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddNewAddress() {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.add, size: 18, color: Color(0xFFB5976A)),
        label: const Text(
          'Agregar nueva dirección',
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

  Widget _buildShippingOption({
    required String id,
    required String label,
    required String subtitle,
    required String price,
  }) {
    final isSelected = _selectedShipping == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedShipping = id),
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: isSelected
                          ? const Color(0xFF4A3F30)
                          : const Color(0xFF7A6A55),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF9A8A75)),
                  ),
                ],
              ),
            ),
            Text(
              price,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: isSelected
                    ? const Color(0xFFB5976A)
                    : const Color(0xFF7A6A55),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () => Navigator.pushNamed(context, '/checkout-2'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFB5976A),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
        child: const Text(
          'Continuar',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

}