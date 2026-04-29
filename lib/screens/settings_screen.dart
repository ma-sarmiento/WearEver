import 'package:flutter/material.dart';
import '../widgets/smart_back_button.dart';
import '../widgets/bottom_nav.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _ofertasToggle = true;
  bool _mensajesToggle = true;
  bool _pedidosToggle = true;
  bool _titoToggle = false;
  bool _perfilPublico = true;
  bool _mostrarBusquedas = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      appBar: AppBar(
      automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFF5EFE6),
        elevation: 0,
        title: const Text(
          'Configuración',
          style: TextStyle(color: Color(0xFF4A3F30), fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Cuenta'),
            _buildCard([
              _buildTapItem('Cambiar contraseña', Icons.lock_outline),
              _buildDivider(),
              _buildTapItem('Cambiar correo', Icons.email_outlined),
              _buildDivider(),
              _buildTapItem('Verificar identidad', Icons.verified_user_outlined),
            ]),
            const SizedBox(height: 20),
            _buildSectionTitle('Notificaciones'),
            _buildCard([
              _buildToggleItem('Ofertas y promociones', _ofertasToggle,
                  (v) => setState(() => _ofertasToggle = v)),
              _buildDivider(),
              _buildToggleItem('Nuevos mensajes', _mensajesToggle,
                  (v) => setState(() => _mensajesToggle = v)),
              _buildDivider(),
              _buildToggleItem('Estado de pedidos', _pedidosToggle,
                  (v) => setState(() => _pedidosToggle = v)),
              _buildDivider(),
              _buildToggleItem('Recomendaciones de Tito', _titoToggle,
                  (v) => setState(() => _titoToggle = v)),
            ]),
            const SizedBox(height: 20),
            _buildSectionTitle('Privacidad'),
            _buildCard([
              _buildToggleItem('Perfil público', _perfilPublico,
                  (v) => setState(() => _perfilPublico = v)),
              _buildDivider(),
              _buildToggleItem('Mostrar en búsquedas', _mostrarBusquedas,
                  (v) => setState(() => _mostrarBusquedas = v)),
            ]),
            const SizedBox(height: 20),
            _buildSectionTitle('Sobre WearEver'),
            _buildCard([
              _buildTapItem('Términos y condiciones', Icons.description_outlined),
              _buildDivider(),
              _buildTapItem('Política de privacidad', Icons.policy_outlined),
              _buildDivider(),
              _buildInfoItem('Versión 1.0.0'),
            ]),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavWidget(currentIndex: -1),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF9A8A75),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
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
      child: Column(children: children),
    );
  }

  Widget _buildTapItem(String label, IconData icon) {
    return GestureDetector(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF7A6A55)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 14, color: Color(0xFF4A3F30), fontWeight: FontWeight.w500),
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: Color(0xFFB0A090)),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleItem(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, color: Color(0xFF4A3F30), fontWeight: FontWeight.w500),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFFB5976A),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 20, color: Color(0xFF7A6A55)),
          const SizedBox(width: 14),
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Color(0xFF9A8A75), fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, color: Color(0xFFF0E6D4), indent: 50);
  }
}
