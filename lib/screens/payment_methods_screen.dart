import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/bottom_nav.dart';
import '../services/firestore_service.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});
  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final _firestoreService = FirestoreService();
  Map<String, dynamic>? _paymentData;
  bool _loading = true;

  // Controllers for new card form
  final _numberCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _numberCtrl.dispose();
    _nameCtrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final data = await _firestoreService.getPaymentData();
    if (mounted) setState(() { _paymentData = data; _loading = false; });
  }

  // Cards stored as list inside payment_data doc
  List<Map<String, dynamic>> get _cards {
    final raw = _paymentData?['tarjetas'];
    if (raw == null) return [];
    return List<Map<String, dynamic>>.from(raw);
  }

  Future<void> _deleteCard(int index) async {
    final updated = List<Map<String, dynamic>>.from(_cards)..removeAt(index);
    await _firestoreService.savePaymentData({'tarjetas': updated});
    await _loadData();
  }

  void _showAddCardSheet() {
    _numberCtrl.clear(); _nameCtrl.clear(); _expiryCtrl.clear(); _cvvCtrl.clear();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(left: 20, right: 20, top: 24, bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Nueva tarjeta',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4A3F30))),
          const SizedBox(height: 20),
          _sheetField('Número de tarjeta', _numberCtrl,
              type: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(16)]),
          const SizedBox(height: 12),
          _sheetField('Nombre del titular', _nameCtrl),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _sheetField('MM/AA', _expiryCtrl, type: TextInputType.number,
                inputFormatters: [LengthLimitingTextInputFormatter(5)])),
            const SizedBox(width: 12),
            Expanded(child: _sheetField('CVV', _cvvCtrl, type: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)])),
          ]),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity, height: 50,
            child: ElevatedButton(
              onPressed: () async {
                final num = _numberCtrl.text.trim();
                final name = _nameCtrl.text.trim();
                final expiry = _expiryCtrl.text.trim();
                if (num.length < 16 || name.isEmpty || expiry.length < 4) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Completa todos los campos'), backgroundColor: Colors.red));
                  return;
                }
                final newCard = {
                  'last4': num.substring(num.length - 4),
                  'type': num.startsWith('4') ? 'VISA' : num.startsWith('5') ? 'Mastercard' : 'Tarjeta',
                  'expiry': expiry,
                  'nombre': name,
                };
                final updated = [..._cards, newCard];
                await _firestoreService.savePaymentData({'tarjetas': updated});
                if (ctx.mounted) Navigator.pop(ctx);
                await _loadData();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB5976A), foregroundColor: Colors.white,
                elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Guardar tarjeta', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _sheetField(String hint, TextEditingController ctrl,
      {TextInputType type = TextInputType.text, List<TextInputFormatter>? inputFormatters}) {
    return TextField(
      controller: ctrl, keyboardType: type, inputFormatters: inputFormatters,
      style: const TextStyle(color: Color(0xFF4A3F30), fontSize: 14),
      decoration: InputDecoration(
        hintText: hint, hintStyle: const TextStyle(color: Color(0xFFB0A090), fontSize: 13),
        filled: true, fillColor: const Color(0xFFF5EFE6),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5EFE6),
        elevation: 0,
        title: const Text('Métodos de pago',
            style: TextStyle(color: Color(0xFF4A3F30), fontSize: 18, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFB5976A)))
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(children: [
                // PSE / Nequi saved data
                _buildDigitalMethods(),
                const SizedBox(height: 16),
                // Cards
                const Align(alignment: Alignment.centerLeft,
                  child: Text('Tarjetas', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF4A3F30)))),
                const SizedBox(height: 10),
                Expanded(
                  child: _cards.isEmpty
                      ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(Icons.credit_card_off_outlined, size: 56, color: const Color(0xFFB5976A).withOpacity(0.3)),
                          const SizedBox(height: 12),
                          const Text('No tienes tarjetas guardadas', style: TextStyle(color: Color(0xFF9A8A75), fontSize: 14)),
                        ]))
                      : ListView.separated(
                          itemCount: _cards.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (_, i) {
                            final card = _cards[i];
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white, borderRadius: BorderRadius.circular(14),
                                boxShadow: [BoxShadow(color: const Color(0xFFB5976A).withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 3))],
                              ),
                              child: Row(children: [
                                Container(
                                  width: 48, height: 48,
                                  decoration: BoxDecoration(color: const Color(0xFFF0E6D4), borderRadius: BorderRadius.circular(10)),
                                  child: const Icon(Icons.credit_card, color: Color(0xFFB5976A), size: 26),
                                ),
                                const SizedBox(width: 14),
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text('${card['type']} **** ${card['last4']}',
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF4A3F30))),
                                  Text('Vence ${card['expiry']}',
                                      style: const TextStyle(fontSize: 12, color: Color(0xFF9A8A75))),
                                ])),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Color(0xFFD32F2F)),
                                  onPressed: () => _deleteCard(i),
                                ),
                              ]),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity, height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _showAddCardSheet,
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar tarjeta', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB5976A), foregroundColor: Colors.white,
                      elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ]),
            ),
      bottomNavigationBar: const BottomNavWidget(currentIndex: -1),
    );
  }

  Widget _buildDigitalMethods() {
    final pseBank = _paymentData?['pse_banco'] as String? ?? '';
    final nequiNum = _paymentData?['nequi_numero'] as String? ?? '';
    if (pseBank.isEmpty && nequiNum.isEmpty) return const SizedBox.shrink();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Métodos digitales',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF4A3F30))),
      const SizedBox(height: 10),
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: const Color(0xFFB5976A).withOpacity(0.07), blurRadius: 8)],
        ),
        child: Column(children: [
          if (pseBank.isNotEmpty) _methodRow('PSE', 'Banco: $pseBank', const Color(0xFF00A651)),
          if (pseBank.isNotEmpty && nequiNum.isNotEmpty)
            const Divider(height: 16, color: Color(0xFFF0E6D4)),
          if (nequiNum.isNotEmpty) _methodRow('Nequi', 'Cel: $nequiNum', const Color(0xFF8C00FF)),
        ]),
      ),
    ]);
  }

  Widget _methodRow(String name, String detail, Color color) {
    return Row(children: [
      Container(
        width: 40, height: 40,
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: Center(child: Text(name, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold))),
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF4A3F30))),
        Text(detail, style: const TextStyle(fontSize: 12, color: Color(0xFF9A8A75))),
      ])),
      const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 18),
    ]);
  }
}
