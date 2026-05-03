import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/bottom_nav.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  final _firestoreService = FirestoreService();
  late TabController _tabController;

  String _nombre = '';
  String _username = '';
  String _fotoPerfilUrl = '';
  List<String> _savedStyles = [];
  int _compras = 0, _ventas = 0, _seguidores = 0, _seguidos = 0;
  bool _loadingStats = true;
  String _currentUid = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    _loadUserData();
    _loadStats();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final data = await AuthService().getUserData();
    if (mounted && data != null) {
      setState(() {
        _nombre = '${data['nombre'] ?? ''} ${data['apellido'] ?? ''}'.trim();
        _username = '@${data['username'] ?? ''}';
        _fotoPerfilUrl = data['foto_perfil'] as String? ?? '';
        _savedStyles = List<String>.from(data['gustos_estilos'] ?? []);
      });
    }
  }

  Future<void> _loadStats() async {
    final stats = await _firestoreService.getUserStats();
    if (mounted) {
      setState(() {
        _compras = stats['compras'] ?? 0;
        _ventas = stats['ventas'] ?? 0;
        _seguidores = stats['seguidores'] ?? 0;
        _seguidos = stats['seguidos'] ?? 0;
        _loadingStats = false;
      });
    }
  }

  Future<void> _pickAndUploadPhoto() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (picked == null) return;
      final url = await StorageService().uploadProfilePhoto(File(picked.path));
      if (url != null) {
        await _firestoreService.updateUserField('foto_perfil', url);
        if (mounted) setState(() => _fotoPerfilUrl = url);
      }
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Esta función requiere un dispositivo físico'), backgroundColor: Color(0xFFD32F2F)));
    }
  }

  Future<void> _handleLogout() async {
    await AuthService().logoutUser();
    if (mounted) Navigator.pushReplacementNamed(context, '/');
  }

  void _openFollowList(String mode) {
    Navigator.pushNamed(context, '/followers',
        arguments: {'mode': mode, 'uid': _currentUid});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5EFE6),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Perfil', style: TextStyle(color: Color(0xFF4A3F30), fontSize: 20, fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Color(0xFF9A8A75)),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverToBoxAdapter(child: Column(children: [
            _buildProfileHeader(),
            const SizedBox(height: 16),
            _buildStats(),
            const SizedBox(height: 16),
            _buildStylesCard(),
            const SizedBox(height: 8),
            _buildMenuList(),
            const SizedBox(height: 16),
          ])),
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(TabBar(
              controller: _tabController,
              labelColor: const Color(0xFFB5976A),
              unselectedLabelColor: const Color(0xFF9A8A75),
              indicatorColor: const Color(0xFFB5976A),
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              tabs: const [Tab(text: 'Mis publicaciones'), Tab(text: 'Favoritos')],
            )),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildMyProducts(),
            _buildSaved(),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavWidget(currentIndex: 4),
    );
  }

  Widget _buildProfileHeader() {
    return Column(children: [
      SizedBox(
        height: 170,
        child: Stack(clipBehavior: Clip.none, children: [
          Positioned(top: 0, left: 0, right: 0,
            child: Container(
              height: 110,
              decoration: const BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: [Color(0xFF8B7355), Color(0xFF6B5B45)]),
              ),
            ),
          ),
          Positioned(bottom: 0, left: 0, right: 0,
            child: Center(child: GestureDetector(
              onTap: _pickAndUploadPhoto,
              child: Stack(children: [
                Container(
                  width: 90, height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle, color: const Color(0xFFE8D5C4),
                    border: Border.all(color: const Color(0xFFC4A882), width: 3),
                    boxShadow: [BoxShadow(color: const Color(0xFFB5976A).withOpacity(0.25), blurRadius: 14, offset: const Offset(0, 5))],
                  ),
                  child: ClipOval(child: _fotoPerfilUrl.isNotEmpty
                      ? Image.network(_fotoPerfilUrl, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.person, color: Color(0xFFB5976A), size: 40))
                      : const Icon(Icons.person, color: Color(0xFFB5976A), size: 40)),
                ),
                Positioned(bottom: 0, right: 0,
                  child: Container(
                    width: 28, height: 28,
                    decoration: const BoxDecoration(color: Color(0xFFB5976A), shape: BoxShape.circle),
                    child: const Icon(Icons.edit, color: Colors.white, size: 14),
                  ),
                ),
              ]),
            )),
          ),
        ]),
      ),
      const SizedBox(height: 12),
      Text(_nombre.isEmpty ? 'Cargando...' : _nombre,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF4A3F30))),
      const SizedBox(height: 2),
      Text(_username, style: const TextStyle(fontSize: 13, color: Color(0xFF9A8A75))),
      const SizedBox(height: 8),
    ]);
  }

  Widget _buildStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: const Color(0xFFB5976A).withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: _loadingStats
            ? const Center(child: SizedBox(height: 40,
                child: CircularProgressIndicator(color: Color(0xFFB5976A), strokeWidth: 2)))
            : Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                _buildStatItem('Seguidores', '$_seguidores', onTap: () => _openFollowList('followers')),
                _buildDivider(),
                _buildStatItem('Seguidos', '$_seguidos', onTap: () => _openFollowList('following')),
                _buildDivider(),
                _buildStatItem('Compras', '$_compras'),
                _buildDivider(),
                _buildStatItem('Ventas', '$_ventas'),
              ]),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, {VoidCallback? onTap}) {
    final content = Column(children: [
      Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF4A3F30))),
      const SizedBox(height: 2),
      Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF9A8A75))),
    ]);
    if (onTap == null) return content;
    return GestureDetector(onTap: onTap, child: content);
  }

  Widget _buildDivider() => Container(width: 1, height: 36, color: const Color(0xFFE0D0BC));

  Widget _buildStylesCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: const Color(0xFFB5976A).withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Mis estilos', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF4A3F30))),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/style-selector').then((_) => _loadUserData()),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFB5976A).withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                child: const Row(children: [
                  Icon(Icons.edit_outlined, size: 13, color: Color(0xFFB5976A)),
                  SizedBox(width: 4),
                  Text('Editar', style: TextStyle(fontSize: 12, color: Color(0xFFB5976A), fontWeight: FontWeight.w500)),
                ]),
              ),
            ),
          ]),
          const SizedBox(height: 12),
          _savedStyles.isEmpty
              ? GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/style-selector'),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFB5976A).withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(child: Text('+ Seleccionar estilos',
                        style: TextStyle(color: Color(0xFFB5976A), fontSize: 13, fontWeight: FontWeight.w500))),
                  ),
                )
              : Wrap(
                  spacing: 8, runSpacing: 8,
                  children: _savedStyles.map((style) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFB5976A).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFB5976A).withOpacity(0.3)),
                    ),
                    child: Text(style, style: const TextStyle(fontSize: 12, color: Color(0xFFB5976A), fontWeight: FontWeight.w500)),
                  )).toList(),
                ),
        ]),
      ),
    );
  }

  Widget _buildMenuList() {
    final items = [
      {'icon': Icons.receipt_long_outlined, 'label': 'Mis pedidos', 'route': '/orders'},
      {'icon': Icons.credit_card_outlined, 'label': 'Métodos de pago', 'route': '/payment-methods'},
      {'icon': Icons.location_on_outlined, 'label': 'Mis direcciones', 'route': '/addresses'},
      {'icon': Icons.logout, 'label': 'Cerrar sesión', 'route': '', 'danger': true},
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: const Color(0xFFB5976A).withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Column(children: items.asMap().entries.map((e) {
          final i = e.key;
          final item = e.value;
          final isDanger = item['danger'] == true;
          return Column(children: [
            GestureDetector(
              onTap: () {
                if (isDanger) { _handleLogout(); }
                else if ((item['route'] as String).isNotEmpty) {
                  Navigator.pushNamed(context, item['route'] as String);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(children: [
                  Icon(item['icon'] as IconData, size: 22,
                      color: isDanger ? const Color(0xFFD32F2F) : const Color(0xFF7A6A55)),
                  const SizedBox(width: 14),
                  Expanded(child: Text(item['label'] as String,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500,
                          color: isDanger ? const Color(0xFFD32F2F) : const Color(0xFF4A3F30)))),
                  Icon(Icons.chevron_right, size: 18,
                      color: isDanger ? const Color(0xFFD32F2F).withOpacity(0.5) : const Color(0xFFB0A090)),
                ]),
              ),
            ),
            if (i < items.length - 1)
              const Divider(height: 1, color: Color(0xFFF0E6D4), indent: 52),
          ]);
        }).toList()),
      ),
    );
  }

  Widget _buildMyProducts() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _firestoreService.getProductsByVendedor(_currentUid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFB5976A)));
        }
        final products = snapshot.data ?? [];
        if (products.isEmpty) {
          return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.storefront_outlined, size: 56, color: const Color(0xFFB5976A).withOpacity(0.3)),
            const SizedBox(height: 12),
            const Text('Aún no has publicado nada',
                style: TextStyle(color: Color(0xFF9A8A75), fontSize: 14)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/create-product'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB5976A),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Publicar algo'),
            ),
          ]));
        }
        return GridView.builder(
          padding: const EdgeInsets.all(14),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.72,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) => _buildProductCard(products[index]),
        );
      },
    );
  }

  Widget _buildSaved() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _firestoreService.getSavedStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFB5976A)));
        }
        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.bookmark_border, size: 56, color: const Color(0xFFB5976A).withOpacity(0.3)),
            const SizedBox(height: 12),
            const Text('No tienes favoritos guardados',
                style: TextStyle(color: Color(0xFF9A8A75), fontSize: 14)),
          ]));
        }
        return GridView.builder(
          padding: const EdgeInsets.all(14),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.72,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) => _buildProductCard(items[index]),
        );
      },
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    final fotos = List<String>.from(product['fotos'] ?? []);
    final precio = (product['precio'] as num?)?.toDouble() ?? 0;
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/product-detail', arguments: product),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: const Color(0xFFB5976A).withOpacity(0.07), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            child: fotos.isNotEmpty
                ? Image.network(fotos.first, fit: BoxFit.cover, width: double.infinity,
                    errorBuilder: (_, __, ___) => Container(color: const Color(0xFFE8D5C4),
                        child: const Icon(Icons.checkroom, color: Color(0xFFB5976A), size: 36)))
                : Container(color: const Color(0xFFE8D5C4),
                    child: const Icon(Icons.checkroom, color: Color(0xFFB5976A), size: 36)),
          )),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(product['nombre'] as String? ?? '',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF4A3F30)),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text('\$${precio.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFB5976A))),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  const _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height + 1;
  @override
  double get maxExtent => tabBar.preferredSize.height + 1;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) => false;
}
