import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';
import '../services/firestore_service.dart';

class CheckoutStep2Screen extends StatefulWidget {
  const CheckoutStep2Screen({super.key});
  @override
  State<CheckoutStep2Screen> createState() => _CheckoutStep2ScreenState();
}

class _CheckoutStep2ScreenState extends State<CheckoutStep2Screen> {
  final _firestoreService = FirestoreService();
  String _selectedPayment = 'contraentrega';
  Map<String, dynamic> _checkoutData = {};
  Map<String, dynamic>? _savedPaymentData;
  bool _loadingPayment = true;

  // PSE controllers
  final _bankCtrl = TextEditingController();
  // Nequi controllers
  final _nequiCtrl = TextEditingController();
  final _nequiNameCtrl = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) _checkoutData = args;
  }

  @override
  void initState() {
    super.initState();
    _loadSavedPaymentData();
  }

  Future<void> _loadSavedPaymentData() async {
    final data = await _firestoreService.getPaymentData();
    if (mounted) {
      setState(() {
        _savedPaymentData = data;
        if (data != null) {
          _bankCtrl.text = data['pse_banco'] as String? ?? '';
          _nequiNameCtrl.text = data['nequi_nombre'] as String? ?? '';
          _nequiCtrl.text = data['nequi_numero'] as String? ?? '';
        }
        _loadingPayment = false;
      });
    }
  }

  @override
  void dispose() {
    _bankCtrl.dispose();
    _nequiCtrl.dispose();
    _nequiNameCtrl.dispose();
    super.dispose();
  }

  String _formatPrice(double p) =>
      '\$${p.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';

  Future<void> _savePaymentData() async {
    await _firestoreService.savePaymentData({
      'pse_banco': _bankCtrl.text.trim(),
      'nequi_nombre': _nequiNameCtrl.text.trim(),
      'nequi_numero': _nequiCtrl.text.trim(),
    });
    if (mounted) {
      setState(() {
        _savedPaymentData = {
          'pse_banco': _bankCtrl.text.trim(),
          'nequi_nombre': _nequiNameCtrl.text.trim(),
          'nequi_numero': _nequiCtrl.text.trim(),
        };
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Datos guardados ✓'),
          backgroundColor: Color(0xFFB5976A),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  bool get _hasValidPayment {
    if (_selectedPayment == 'contraentrega') return true;
    if (_selectedPayment == 'pse') return _bankCtrl.text.trim().isNotEmpty;
    if (_selectedPayment == 'nequi') return _nequiCtrl.text.trim().isNotEmpty;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final total = (_checkoutData['total'] as num?)?.toDouble() ?? 0;

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
      body: _loadingPayment
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFB5976A)))
          : Column(children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _buildStepIndicator(),
                    const SizedBox(height: 24),
                    const Text('Método de pago',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF4A3F30))),
                    const SizedBox(height: 12),
                    _buildPaymentTile(
                      id: 'contraentrega',
                      label: 'Contraentrega',
                      subtitle: 'Pago al recibir el pedido',
                      badge: 'CASH',
                      badgeColor: const Color(0xFF9A8A75),
                    ),
                    const SizedBox(height: 10),
                    _buildPaymentTile(
                      id: 'pse',
                      label: 'PSE',
                      subtitle: 'Débito bancario en línea',
                      badge: 'PSE',
                      badgeColor: const Color(0xFF00A651),
                      expandedChild: _buildPseForm(),
                    ),
                    const SizedBox(height: 10),
                    _buildPaymentTile(
                      id: 'nequi',
                      label: 'Nequi',
                      subtitle: 'Billetera digital',
                      badge: 'NEQUI',
                      badgeColor: const Color(0xFF8C00FF),
                      expandedChild: _buildNequiForm(),
                    ),
                    const SizedBox(height: 20),
                  ]),
                ),
              ),
              _buildBottomTotal(total),
            ]),
      bottomNavigationBar: const BottomNavWidget(currentIndex: -1),
    );
  }

  Widget _buildPaymentTile({
    required String id,
    required String label,
    required String subtitle,
    required String badge,
    required Color badgeColor,
    Widget? expandedChild,
  }) {
    final isSelected = _selectedPayment == id;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? const Color(0xFFB5976A) : const Color(0xFFE0D0BC),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [BoxShadow(color: const Color(0xFFB5976A).withOpacity(0.06), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          // Header row
          GestureDetector(
            onTap: () => setState(() => _selectedPayment = id),
            child: Padding(
              padding: const EdgeInsets.all(14),
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
                  child: isSelected ? Center(child: Container(
                    width: 10, height: 10,
                    decoration: const BoxDecoration(color: Color(0xFFB5976A), shape: BoxShape.circle),
                  )) : null,
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(label, style: TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 14,
                    color: isSelected ? const Color(0xFF4A3F30) : const Color(0xFF7A6A55),
                  )),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF9A8A75))),
                ])),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: badgeColor.withOpacity(0.3)),
                  ),
                  child: Text(badge, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: badgeColor)),
                ),
              ]),
            ),
          ),
          // Formulario expandible
          if (isSelected && expandedChild != null) ...[
            const Divider(height: 1, color: Color(0xFFEEE4D8)),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: expandedChild,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPseForm() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Datos PSE', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF4A3F30))),
      const SizedBox(height: 10),
      _formField('Nombre del banco', _bankCtrl),
      const SizedBox(height: 12),
      _saveButton(() => _savePaymentData()),
    ]);
  }

  Widget _buildNequiForm() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Datos Nequi', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF4A3F30))),
      const SizedBox(height: 10),
      _formField('Nombre del titular', _nequiNameCtrl),
      const SizedBox(height: 8),
      _formField('Número de celular', _nequiCtrl, type: TextInputType.phone),
      const SizedBox(height: 12),
      _saveButton(() => _savePaymentData()),
    ]);
  }

  Widget _formField(String hint, TextEditingController ctrl, {TextInputType type = TextInputType.text}) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      onChanged: (_) => setState(() {}),
      style: const TextStyle(color: Color(0xFF4A3F30), fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFB0A090), fontSize: 13),
        filled: true,
        fillColor: const Color(0xFFF5EFE6),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        isDense: true,
      ),
    );
  }

  Widget _saveButton(Future<void> Function() onTap) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () async => await onTap(),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFB5976A)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
        child: const Text('Guardar datos',
            style: TextStyle(color: Color(0xFFB5976A), fontWeight: FontWeight.w600, fontSize: 13)),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(children: List.generate(3, (i) => Expanded(child: Row(children: [
      Expanded(child: Container(
        height: 4,
        decoration: BoxDecoration(
          color: i + 1 <= 2 ? const Color(0xFFB5976A) : const Color(0xFFE0D0BC),
          borderRadius: BorderRadius.circular(2),
        ),
      )),
      if (i < 2) const SizedBox(width: 4),
    ]))));
  }

  Widget _buildBottomTotal(double total) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, -3))],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Total a pagar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF4A3F30))),
          Text(_formatPrice(total), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFB5976A))),
        ]),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity, height: 50,
          child: ElevatedButton(
            onPressed: _hasValidPayment ? () {
              Navigator.pushNamed(context, '/checkout-3', arguments: {
                ..._checkoutData,
                'metodo_pago': _selectedPayment,
              });
            } : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB5976A),
              foregroundColor: Colors.white,
              elevation: 0,
              disabledBackgroundColor: const Color(0xFFB5976A).withOpacity(0.4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: Text(
              _hasValidPayment ? 'Continuar' : 'Completa los datos para continuar',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ]),
    );
  }
}
