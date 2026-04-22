import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/bottom_nav.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<String> _savedStyles = [];

  @override
  void initState() {
    super.initState();
    _loadStyles();
  }

  Future<void> _loadStyles() async {
    final prefs = await SharedPreferences.getInstance();
    final styles = prefs.getStringList('saved_styles') ?? [];
    if (mounted) setState(() => _savedStyles = styles);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5EFE6),
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF4A3F30)),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: const Text(
          'Perfil',
          style: TextStyle(
            color: Color(0xFF4A3F30),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Color(0xFF9A8A75)),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 16),
            _buildStats(),
            const SizedBox(height: 16),
            _buildStylesCard(),
            const SizedBox(height: 16),
            _buildMenuList(),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavWidget(currentIndex: 4),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        // Cover photo + avatar overlap
        SizedBox(
          height: 170,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Cover gradient banner
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 110,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF8B7355), Color(0xFF6B5B45)],
                    ),
                  ),
                ),
              ),
              // Avatar centered, overlapping cover bottom
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFE8D5C4),
                          border: Border.all(
                              color: const Color(0xFFC4A882), width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFB5976A).withOpacity(0.25),
                              blurRadius: 14,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'MS',
                            style: TextStyle(
                              color: Color(0xFFB5976A),
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: Color(0xFFB5976A),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit,
                              color: Colors.white, size: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Miguel Sarmiento',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4A3F30),
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          '@miguelsar',
          style: TextStyle(fontSize: 13, color: Color(0xFF9A8A75)),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFB5976A).withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatItem('Compras', '12'),
            _buildDivider(),
            _buildStatItem('Ventas', '3'),
            _buildDivider(),
            _buildStatItem('Puntos', '450'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4A3F30),
          ),
        ),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF9A8A75))),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(width: 1, height: 36, color: const Color(0xFFE0D0BC));
  }

  Widget _buildStylesCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFB5976A).withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Mis estilos',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4A3F30),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/style-selector'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFB5976A).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 13, color: Color(0xFFB5976A)),
                        SizedBox(width: 4),
                        Text('Editar',
                            style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFFB5976A),
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _savedStyles.isEmpty
                ? GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/style-selector'),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: const Color(0xFFB5976A).withOpacity(0.3),
                            style: BorderStyle.solid),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text(
                          '+ Seleccionar estilos',
                          style: TextStyle(
                              color: Color(0xFFB5976A),
                              fontSize: 13,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  )
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _savedStyles.map((style) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFB5976A).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: const Color(0xFFB5976A).withOpacity(0.3)),
                        ),
                        child: Text(
                          style,
                          style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFFB5976A),
                              fontWeight: FontWeight.w500),
                        ),
                      );
                    }).toList(),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuList() {
    final items = [
      {'icon': Icons.receipt_long_outlined, 'label': 'Mis pedidos', 'route': '/orders', 'danger': false},
      {'icon': Icons.bookmark_outline, 'label': 'Favoritos', 'route': '/saved', 'danger': false},
      {'icon': Icons.credit_card_outlined, 'label': 'Métodos de pago', 'route': '', 'danger': false},
      {'icon': Icons.location_on_outlined, 'label': 'Mis direcciones', 'route': '', 'danger': false},
      {'icon': Icons.settings_outlined, 'label': 'Configuración', 'route': '', 'danger': false},
      {'icon': Icons.logout, 'label': 'Cerrar sesión', 'route': '/login', 'danger': true},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFB5976A).withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: items.asMap().entries.map((e) {
            final i = e.key;
            final item = e.value;
            final isDanger = item['danger'] as bool;
            final route = item['route'] as String;
            return Column(
              children: [
                GestureDetector(
                  onTap: () {
                    if (route.isNotEmpty) {
                      if (route == '/login') {
                        Navigator.pushReplacementNamed(context, route);
                      } else {
                        Navigator.pushNamed(context, route);
                      }
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Icon(
                          item['icon'] as IconData,
                          size: 22,
                          color: isDanger
                              ? const Color(0xFFD32F2F)
                              : const Color(0xFF7A6A55),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            item['label'] as String,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDanger
                                  ? const Color(0xFFD32F2F)
                                  : const Color(0xFF4A3F30),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          size: 18,
                          color: isDanger
                              ? const Color(0xFFD32F2F).withOpacity(0.5)
                              : const Color(0xFFB0A090),
                        ),
                      ],
                    ),
                  ),
                ),
                if (i < items.length - 1)
                  const Divider(height: 1, color: Color(0xFFF0E6D4), indent: 52),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
