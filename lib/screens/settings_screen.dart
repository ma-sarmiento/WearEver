import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _firestoreService = FirestoreService();
  bool _loading = true;

  bool _ofertasToggle = true;
  bool _mensajesToggle = true;
  bool _pedidosToggle = true;
  bool _perfilPublico = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final data = await _firestoreService.getUserSettings();
    if (mounted) {
      setState(() {
        _ofertasToggle = data['notif_ofertas'] as bool? ?? true;
        _mensajesToggle = data['notif_mensajes'] as bool? ?? true;
        _pedidosToggle = data['notif_pedidos'] as bool? ?? true;
        _perfilPublico = data['perfil_publico'] as bool? ?? true;
        _loading = false;
      });
    }
  }

  Future<void> _saveSettings() async {
    await _firestoreService.saveUserSettings({
      'notif_ofertas': _ofertasToggle,
      'notif_mensajes': _mensajesToggle,
      'notif_pedidos': _pedidosToggle,
      'perfil_publico': _perfilPublico,
    });
  }


  void _showInfoDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFF5EFE6),
        title: Text(title, style: const TextStyle(color: Color(0xFF4A3F30), fontSize: 16, fontWeight: FontWeight.w600)),
        content: Text(content, style: const TextStyle(color: Color(0xFF7A6A55), fontSize: 13, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cerrar', style: TextStyle(color: Color(0xFFB5976A), fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(left: 20, right: 20, top: 24, bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Cambiar contraseña',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4A3F30))),
          const SizedBox(height: 20),
          _sheetField('Contraseña actual', currentCtrl, obscure: true),
          const SizedBox(height: 12),
          _sheetField('Nueva contraseña', newCtrl, obscure: true),
          const SizedBox(height: 12),
          _sheetField('Confirmar nueva contraseña', confirmCtrl, obscure: true),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity, height: 48,
            child: ElevatedButton(
              onPressed: () async {
                if (newCtrl.text != confirmCtrl.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Las contraseñas no coinciden'), backgroundColor: Colors.red));
                  return;
                }
                try {
                  await AuthService().changePassword(
                      currentPassword: currentCtrl.text, newPassword: newCtrl.text);
                  if (ctx.mounted) Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Contraseña actualizada ✓'),
                        backgroundColor: Color(0xFFB5976A)));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB5976A), foregroundColor: Colors.white,
                elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Cambiar', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _sheetField(String hint, TextEditingController ctrl, {bool obscure = false}) {
    return TextField(
      controller: ctrl, obscureText: obscure,
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
        title: const Text('Configuración',
            style: TextStyle(color: Color(0xFF4A3F30), fontSize: 18, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFB5976A)))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _sectionTitle('Cuenta'),
                _card([
                  _tapItem('Cambiar contraseña', Icons.lock_outline, onTap: _showChangePasswordDialog),
                  _divider(),
                  _tapItem('Mis direcciones', Icons.location_on_outlined,
                      onTap: () => Navigator.pushNamed(context, '/addresses')),
                  _divider(),
                  _tapItem('Métodos de pago', Icons.credit_card_outlined,
                      onTap: () => Navigator.pushNamed(context, '/payment-methods')),
                ]),
                const SizedBox(height: 20),
                _sectionTitle('Notificaciones'),
                _card([
                  _toggleItem('Ofertas y promociones', _ofertasToggle, (v) {
                    setState(() => _ofertasToggle = v);
                    _saveSettings();
                  }),
                  _divider(),
                  _toggleItem('Nuevos mensajes', _mensajesToggle, (v) {
                    setState(() => _mensajesToggle = v);
                    _saveSettings();
                  }),
                  _divider(),
                  _toggleItem('Estado de pedidos', _pedidosToggle, (v) {
                    setState(() => _pedidosToggle = v);
                    _saveSettings();
                  }),
                ]),
                const SizedBox(height: 20),
                _sectionTitle('Privacidad'),
                _card([
                  _toggleItem('Perfil público', _perfilPublico, (v) {
                    setState(() => _perfilPublico = v);
                    _saveSettings();
                  }),
                ]),
                const SizedBox(height: 20),
                _sectionTitle('Sobre WearEver'),
                _card([
                  _tapItem('Términos y condiciones', Icons.description_outlined,
                      onTap: () => _showInfoDialog('Términos y condiciones',
                          'Al usar WearEver aceptas que los vendedores son responsables de sus productos. WearEver es una plataforma de intermediación y no se responsabiliza por disputas entre compradores y vendedores.')),
                  _divider(),
                  _tapItem('Política de privacidad', Icons.policy_outlined,
                      onTap: () => _showInfoDialog('Política de privacidad',
                          'Tus datos personales son usados únicamente para operar la plataforma. No compartimos tu información con terceros. Puedes eliminar tu cuenta en cualquier momento contactando a soporte.')),
                  _divider(),
                  _infoItem('Versión 1.0.0'),
                ]),
                const SizedBox(height: 24),
              ]),
            ),
      bottomNavigationBar: const BottomNavWidget(currentIndex: -1),
    );
  }

  Widget _sectionTitle(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 8, left: 4),
    child: Text(t, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
        color: Color(0xFF9A8A75), letterSpacing: 0.5)),
  );

  Widget _card(List<Widget> children) => Container(
    decoration: BoxDecoration(
      color: Colors.white, borderRadius: BorderRadius.circular(14),
      boxShadow: [BoxShadow(color: const Color(0xFFB5976A).withOpacity(0.07), blurRadius: 8, offset: const Offset(0, 3))],
    ),
    child: Column(children: children),
  );

  Widget _tapItem(String label, IconData icon, {VoidCallback? onTap}) => GestureDetector(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(children: [
        Icon(icon, size: 20, color: const Color(0xFF7A6A55)),
        const SizedBox(width: 14),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 14, color: Color(0xFF4A3F30)))),
        const Icon(Icons.chevron_right, size: 18, color: Color(0xFFB0A090)),
      ]),
    ),
  );

  Widget _toggleItem(String label, bool value, ValueChanged<bool> onChanged) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    child: Row(children: [
      Expanded(child: Text(label, style: const TextStyle(fontSize: 14, color: Color(0xFF4A3F30)))),
      Switch(value: value, onChanged: onChanged, activeColor: const Color(0xFFB5976A)),
    ]),
  );

  Widget _infoItem(String label) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    child: Row(children: [
      const Icon(Icons.info_outline, size: 20, color: Color(0xFF7A6A55)),
      const SizedBox(width: 14),
      Text(label, style: const TextStyle(fontSize: 14, color: Color(0xFF9A8A75))),
    ]),
  );

  Widget _divider() => const Divider(height: 1, color: Color(0xFFF0E6D4), indent: 52);
}
