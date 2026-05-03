import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';
import '../services/firestore_service.dart';

class CheckoutStep1Screen extends StatefulWidget {
  const CheckoutStep1Screen({super.key});
  @override
  State<CheckoutStep1Screen> createState() => _CheckoutStep1ScreenState();
}

class _CheckoutStep1ScreenState extends State<CheckoutStep1Screen> {
  final _firestoreService = FirestoreService();
  String _selectedShipping = 'standard';
  Map<String, dynamic>? _selectedAddress;
  bool _loadingAddresses = true;
  List<Map<String, dynamic>> _addresses = [];

  static const double _shippingStandard = 9900;
  static const double _shippingExpress = 19900;

  double get _shippingCost =>
      _selectedShipping == 'express' ? _shippingExpress : _shippingStandard;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    final snap = await _firestoreService.getAddressesStream().first;
    if (mounted) {
      setState(() {
        _addresses = snap;
        _selectedAddress = snap.firstWhere(
          (a) => a['is_primary'] == true,
          orElse: () => snap.isNotEmpty ? snap.first : {},
        );
        if (_selectedAddress!.isEmpty) _selectedAddress = null;
        _loadingAddresses = false;
      });
    }
  }

  String _formatPrice(double p) =>
      '\$${p.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5EFE6),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Checkout (1/3)',
            style: TextStyle(color: Color(0xFF4A3F30), fontSize: 17, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: _loadingAddresses
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFB5976A)))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStepIndicator(1),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Dirección de envío'),
                  const SizedBox(height: 12),
                  if (_selectedAddress != null)
                    _buildAddressCard(_selectedAddress!)
                  else
                    _buildNoAddress(),
                  const SizedBox(height: 10),
                  if (_addresses.length > 1) _buildChangeAddressButton(),
                  const SizedBox(height: 8),
                  _buildAddNewAddress(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Envío'),
                  const SizedBox(height: 12),
                  _buildShippingOption(
                    id: 'standard',
                    label: 'Estándar (3–5 días)',
                    subtitle: _formatPrice(_shippingStandard),
                    price: _formatPrice(_shippingStandard),
                  ),
                  const SizedBox(height: 10),
                  _buildShippingOption(
                    id: 'express',
                    label: 'Exprés (24–48 h)',
                    subtitle: _formatPrice(_shippingExpress),
                    price: _formatPrice(_shippingExpress),
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

  Widget _buildStepIndicator(int currentStep) {
    return Row(
      children: List.generate(3, (i) {
        final step = i + 1;
        final isActive = step == currentStep;
        final isCompleted = step < currentStep;
        return Expanded(
          child: Row(children: [
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
          ]),
        );
      }),
    );
  }

  Widget _buildSectionTitle(String title) => Text(title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF4A3F30)));

  Widget _buildAddressCard(Map<String, dynamic> addr) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFB5976A), width: 1.5),
        boxShadow: [
          BoxShadow(color: const Color(0xFFB5976A).withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(addr['alias'] as String? ?? 'Dirección',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF4A3F30))),
          const SizedBox(height: 4),
          Text(addr['direccion'] as String? ?? '',
              style: const TextStyle(fontSize: 13, color: Color(0xFF7A6A55))),
          if ((addr['ciudad'] as String? ?? '').isNotEmpty)
            Text(addr['ciudad'] as String,
                style: const TextStyle(fontSize: 13, color: Color(0xFF7A6A55))),
        ],
      ),
    );
  }

  Widget _buildNoAddress() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0D0BC)),
      ),
      child: const Text('No tienes direcciones guardadas.',
          style: TextStyle(color: Color(0xFF9A8A75), fontSize: 13)),
    );
  }

  Widget _buildChangeAddressButton() {
    return GestureDetector(
      onTap: () async {
        final selected = await showModalBottomSheet<Map<String, dynamic>>(
          context: context,
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
          builder: (_) => _AddressPicker(addresses: _addresses),
        );
        if (selected != null) setState(() => _selectedAddress = selected);
      },
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFB5976A).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text('Cambiar dirección',
              style: TextStyle(color: Color(0xFFB5976A), fontSize: 12, fontWeight: FontWeight.w500)),
        ),
      ),
    );
  }

  Widget _buildAddNewAddress() {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: OutlinedButton.icon(
        onPressed: () => Navigator.pushNamed(context, '/addresses').then((_) => _loadAddresses()),
        icon: const Icon(Icons.add, size: 18, color: Color(0xFFB5976A)),
        label: const Text('Agregar nueva dirección',
            style: TextStyle(color: Color(0xFFB5976A), fontSize: 14, fontWeight: FontWeight.w500)),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: const Color(0xFFB5976A).withOpacity(0.4)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildShippingOption({required String id, required String label, required String subtitle, required String price}) {
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
              Text(label, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14,
                  color: isSelected ? const Color(0xFF4A3F30) : const Color(0xFF7A6A55))),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF9A8A75))),
            ],
          )),
          Text(price, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14,
              color: isSelected ? const Color(0xFFB5976A) : const Color(0xFF7A6A55))),
        ]),
      ),
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity, height: 52,
      child: ElevatedButton(
        onPressed: _selectedAddress == null ? null : () {
          Navigator.pushNamed(context, '/checkout-2', arguments: {
            'direccion': _selectedAddress,
            'shipping': _selectedShipping,
            'shipping_cost': _shippingCost,
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFB5976A),
          foregroundColor: Colors.white,
          elevation: 0,
          disabledBackgroundColor: const Color(0xFFB5976A).withOpacity(0.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: const Text('Continuar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _AddressPicker extends StatelessWidget {
  final List<Map<String, dynamic>> addresses;
  const _AddressPicker({required this.addresses});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 16),
        const Text('Seleccionar dirección',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF4A3F30))),
        const SizedBox(height: 12),
        ...addresses.map((addr) => ListTile(
          title: Text(addr['alias'] as String? ?? 'Dirección',
              style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF4A3F30))),
          subtitle: Text(addr['direccion'] as String? ?? ''),
          onTap: () => Navigator.pop(context, addr),
        )),
        const SizedBox(height: 8),
      ],
    );
  }
}
