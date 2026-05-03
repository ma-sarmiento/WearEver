import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../widgets/smart_back_button.dart';
import '../widgets/bottom_nav.dart';
import '../services/firestore_service.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  final _firestoreService = FirestoreService();

  final _labelController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalController = TextEditingController();

  @override
  void dispose() {
    _labelController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalController.dispose();
    super.dispose();
  }

  void _showAddAddressSheet() {
    _labelController.clear();
    _addressController.clear();
    _cityController.clear();
    _postalController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nueva dirección',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A3F30),
              ),
            ),
            const SizedBox(height: 20),
            _buildSheetField(
                _labelController, 'Etiqueta (Casa / Oficina / Otro)',
                TextInputType.text),
            const SizedBox(height: 12),
            _buildSheetField(
                _addressController, 'Dirección completa',
                TextInputType.streetAddress),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildSheetField(
                      _cityController, 'Ciudad', TextInputType.text),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSheetField(
                      _postalController, 'Código postal', TextInputType.number),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  final label = _labelController.text.trim();
                  final address = _addressController.text.trim();
                  final city = _cityController.text.trim();
                  if (label.isEmpty || address.isEmpty || city.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Completa los campos requeridos'),
                        backgroundColor: Color(0xFFD32F2F),
                      ),
                    );
                    return;
                  }
                  await _firestoreService.addAddress({
                    'alias': label,
                    'direccion': address,
                    'ciudad': city,
                    'codigo_postal': _postalController.text.trim(),
                  });
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB5976A),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Guardar dirección',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSheetField(TextEditingController controller, String hint,
      TextInputType keyboardType) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Color(0xFF4A3F30)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFB0A090), fontSize: 14),
        filled: true,
        fillColor: const Color(0xFFF5EFE6),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      appBar: AppBar(
      automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFF5EFE6),
        elevation: 0,
        title: const Text(
          'Mis Direcciones',
          style: TextStyle(
              color: Color(0xFF4A3F30),
              fontSize: 18,
              fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _firestoreService.getAddressesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFB5976A)),
            );
          }

          final addresses = snapshot.data ?? [];

          if (addresses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_off_outlined,
                      size: 64,
                      color: const Color(0xFFB5976A).withOpacity(0.3)),
                  const SizedBox(height: 16),
                  const Text(
                    'No tienes direcciones guardadas',
                    style: TextStyle(
                        color: Color(0xFF9A8A75), fontSize: 15),
                  ),
                  const SizedBox(height: 20),
                  _buildAddButton(),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ...addresses.map((addr) => _buildAddressCard(addr)),
              const SizedBox(height: 8),
              _buildAddButton(),
            ],
          );
        },
      ),
      bottomNavigationBar: const BottomNavWidget(currentIndex: -1),
    );
  }

  Widget _buildAddressCard(Map<String, dynamic> addr) {
    final isPrimary = addr['is_primary'] as bool? ?? false;
    final id = addr['id'] as String;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: isPrimary
            ? Border.all(color: const Color(0xFFB5976A), width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB5976A).withOpacity(0.07),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFB5976A).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.location_on_outlined,
                color: Color(0xFFB5976A), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      addr['alias'] as String? ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4A3F30),
                      ),
                    ),
                    if (isPrimary) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFB5976A).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Principal',
                          style: TextStyle(
                              fontSize: 10,
                              color: Color(0xFFB5976A),
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${addr['address'] ?? ''}, ${addr['city'] ?? ''}',
                  style: const TextStyle(
                      fontSize: 13, color: Color(0xFF9A8A75)),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Color(0xFF9A8A75)),
            onSelected: (value) async {
              if (value == 'primary') {
                await _firestoreService.setPrimaryAddress(id);
              } else if (value == 'delete') {
                await _firestoreService.deleteAddress(id);
              }
            },
            itemBuilder: (_) => [
              if (!isPrimary)
                const PopupMenuItem(
                  value: 'primary',
                  child: Text('Establecer como principal'),
                ),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Eliminar',
                    style: TextStyle(color: Color(0xFFD32F2F))),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: _showAddAddressSheet,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFB5976A).withOpacity(0.4),
            style: BorderStyle.solid,
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: Color(0xFFB5976A)),
            SizedBox(width: 8),
            Text(
              'Agregar nueva dirección',
              style: TextStyle(
                color: Color(0xFFB5976A),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}