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
  List<Map<String, dynamic>> _cartItems = [];
  bool _loadingCart = true;

  static const double _shippingStandard = 9900;
  static const double _shippingExpress = 19900;

  double get _shippingCost =>
      _selectedShipping == 'express' ? _shippingExpress : _shippingStandard;

  double get _subtotal => _cartItems.fold(0, (sum, item) {
    final precio = (item['precio'] as num?)?.toDouble() ?? 0;
    final cantidad = (item['cantidad'] as num?)?.toInt() ?? 1;
    return sum + precio * cantidad;
  });

  double get _total => _subtotal + _shippingCost;

  String _formatPrice(double p) =>
      '\$${p.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';

  @override
  void initState() {
    super.initState();
    _loadAddresses();
    _loadCart();
  }

  Future<void> _loadAddresses() async {
    final snap = await _firestoreService.getAddressesStream().first;
    if (mounted) {
      setState(() {
        _addresses = snap;
        final primary = snap.where((a) => a['is_primary'] == true).toList();
        _selectedAddress = primary.isNotEmpty ? primary.first
            : snap.isNotEmpty ? snap.first : null;
        _loadingAddresses = false;
      });
    }
  }

  Future<void> _loadCart() async {
    final items = await _firestoreService.getCartStream().first;
    if (mounted) setState(() { _cartItems = items; _loadingCart = false; });
  }

  void _showAddressPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          const Text('Seleccionar dirección',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF4A3F30))),
          const SizedBox(height: 8),
          ..._addresses.map((addr) => ListTile(
            leading: const Icon(Icons.location_on_outlined, color: Color(0xFFB5976A)),
            title: Text(addr['alias'] as String? ?? 'Dirección',
                style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF4A3F30))),
            subtitle: Text(addr['direccion'] as String? ?? ''),
            trailing: _selectedAddress?['id'] == addr['id']
                ? const Icon(Icons.check_circle, color: Color(0xFFB5976A))
                : null,
            onTap: () {
              setState(() => _selectedAddress = addr);
              Navigator.pop(context);
            },
          )),
          ListTile(
            leading: const Icon(Icons.add, color: Color(0xFFB5976A)),
            title: const Text('Agregar nueva dirección',
                style: TextStyle(color: Color(0xFFB5976A), fontWeight: FontWeight.w500)),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/addresses').then((_) => _loadAddresses());
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = _loadingAddresses || _loadingCart;
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
        title: const Text('Checkout (1/3)',
            style: TextStyle(color: Color(0xFF4A3F30), fontSize: 17, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFB5976A)))
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStepIndicator(1),
                        const SizedBox(height: 24),
                        // Dirección
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Dirección de envío',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF4A3F30))),
                            if (_addresses.isNotEmpty)
                              GestureDetector(
                                onTap: _showAddressPicker,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFB5976A).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text('Cambiar',
                                      style: TextStyle(color: Color(0xFFB5976A), fontSize: 12, fontWeight: FontWeight.w500)),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (_selectedAddress != null)
                          _buildAddressCard(_selectedAddress!)
                        else
                          _buildNoAddress(),
                        const SizedBox(height: 24),
                        // Envío
                        const Text('Tipo de envío',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF4A3F30))),
                        const SizedBox(height: 12),
                        _buildShippingOption(id: 'standard', label: 'Estándar (3–5 días)',
                            price: _formatPrice(_shippingStandard)),
                        const SizedBox(height: 10),
                        _buildShippingOption(id: 'express', label: 'Exprés (24–48 h)',
                            price: _formatPrice(_shippingExpress)),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                // Total fijo abajo
                _buildBottomTotal(),
              ],
            ),
      bottomNavigationBar: const BottomNavWidget(currentIndex: -1),
    );
  }

  Widget _buildStepIndicator(int step) {
    return Row(children: List.generate(3, (i) {
      return Expanded(child: Row(children: [
        Expanded(child: Container(
          height: 4,
          decoration: BoxDecoration(
            color: i + 1 <= step ? const Color(0xFFB5976A) : const Color(0xFFE0D0BC),
            borderRadius: BorderRadius.circular(2),
          ),
        )),
        if (i < 2) const SizedBox(width: 4),
      ]));
    }));
  }

  Widget _buildAddressCard(Map<String, dynamic> addr) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFB5976A), width: 1.5),
        boxShadow: [BoxShadow(color: const Color(0xFFB5976A).withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Row(children: [
        const Icon(Icons.location_on_outlined, color: Color(0xFFB5976A), size: 20),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(addr['alias'] as String? ?? 'Mi dirección',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF4A3F30))),
          Text(addr['direccion'] as String? ?? '',
              style: const TextStyle(fontSize: 13, color: Color(0xFF7A6A55))),
          if ((addr['ciudad'] as String? ?? '').isNotEmpty)
            Text(addr['ciudad'] as String, style: const TextStyle(fontSize: 12, color: Color(0xFF9A8A75))),
        ])),
      ]),
    );
  }

  Widget _buildNoAddress() {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/addresses').then((_) => _loadAddresses()),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFB5976A).withOpacity(0.4), style: BorderStyle.solid),
        ),
        child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.add_location_outlined, color: Color(0xFFB5976A), size: 20),
          SizedBox(width: 8),
          Text('Agregar una dirección de envío',
              style: TextStyle(color: Color(0xFFB5976A), fontSize: 14, fontWeight: FontWeight.w500)),
        ]),
      ),
    );
  }

  Widget _buildShippingOption({required String id, required String label, required String price}) {
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
              border: Border.all(color: isSelected ? const Color(0xFFB5976A) : const Color(0xFFE0D0BC), width: 2),
            ),
            child: isSelected ? Center(child: Container(
                width: 10, height: 10,
                decoration: const BoxDecoration(color: Color(0xFFB5976A), shape: BoxShape.circle))) : null,
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: TextStyle(
              fontWeight: FontWeight.w500, fontSize: 14,
              color: isSelected ? const Color(0xFF4A3F30) : const Color(0xFF7A6A55)))),
          Text(price, style: TextStyle(
              fontWeight: FontWeight.w600, fontSize: 14,
              color: isSelected ? const Color(0xFFB5976A) : const Color(0xFF7A6A55))),
        ]),
      ),
    );
  }

  Widget _buildBottomTotal() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, -3))],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Subtotal', style: TextStyle(fontSize: 13, color: Color(0xFF9A8A75))),
          Text(_formatPrice(_subtotal), style: const TextStyle(fontSize: 13, color: Color(0xFF4A3F30))),
        ]),
        const SizedBox(height: 4),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Envío', style: TextStyle(fontSize: 13, color: Color(0xFF9A8A75))),
          Text(_formatPrice(_shippingCost), style: const TextStyle(fontSize: 13, color: Color(0xFF4A3F30))),
        ]),
        const SizedBox(height: 6),
        const Divider(height: 1, color: Color(0xFFE0D0BC)),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF4A3F30))),
          Text(_formatPrice(_total), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFB5976A))),
        ]),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity, height: 50,
          child: ElevatedButton(
            onPressed: _selectedAddress == null ? null : () {
              Navigator.pushNamed(context, '/checkout-2', arguments: {
                'direccion': _selectedAddress,
                'shipping': _selectedShipping,
                'shipping_cost': _shippingCost,
                'subtotal': _subtotal,
                'total': _total,
                'cart_items': _cartItems,
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
        ),
      ]),
    );
  }
}
