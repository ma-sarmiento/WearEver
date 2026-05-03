import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';
import '../services/firestore_service.dart';

class SellerProfileScreen extends StatefulWidget {
  const SellerProfileScreen({super.key});
  @override
  State<SellerProfileScreen> createState() => _SellerProfileScreenState();
}

class _SellerProfileScreenState extends State<SellerProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _firestoreService = FirestoreService();

  String? _vendedorId;
  Map<String, dynamic>? _vendedorData;
  bool _loading = true; // single loading flag — show nothing until ready
  bool _isFollowing = false;
  bool _followLoading = false;
  int _followersCount = 0;
  int _seguidos = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      final newId = args['vendedor_id'] as String?;
      if (newId != null && newId != _vendedorId) {
        _vendedorId = newId;
        _loadAll();
      }
    }
  }

  Future<void> _loadAll() async {
    if (_vendedorId == null) return;
    setState(() => _loading = true);
    final results = await Future.wait([
      _firestoreService.getUserById(_vendedorId!),
      _firestoreService.isFollowing(_vendedorId!),
      _firestoreService.getFollowersCount(_vendedorId!),
      _firestoreService.getFollowingCount(_vendedorId!),
    ]);
    if (mounted) {
      setState(() {
        _vendedorData = results[0] as Map<String, dynamic>?;
        _isFollowing = results[1] as bool;
        _followersCount = results[2] as int;
        _seguidos = results[3] as int;
        _loading = false;
      });
    }
  }

  Future<void> _toggleFollow() async {
    if (_vendedorId == null || _followLoading) return;
    setState(() => _followLoading = true);
    try {
      if (_isFollowing) {
        await _firestoreService.unfollowUser(_vendedorId!);
        if (mounted) setState(() { _isFollowing = false; _followersCount = (_followersCount - 1).clamp(0, 9999); });
      } else {
        await _firestoreService.followUser(_vendedorId!);
        if (mounted) setState(() { _isFollowing = true; _followersCount++; });
      }
    } finally {
      if (mounted) setState(() => _followLoading = false);
    }
  }

  String _formatPrice(double p) =>
      '\$${p.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show full-screen loader until ALL data is ready — no "Vendedor" flash
    if (_loading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5EFE6),
        body: const Center(child: CircularProgressIndicator(color: Color(0xFFB5976A))),
        bottomNavigationBar: const BottomNavWidget(currentIndex: -1),
      );
    }

    final nombre = '${_vendedorData?['nombre'] ?? ''} ${_vendedorData?['apellido'] ?? ''}'.trim();
    final username = '@${_vendedorData?['username'] ?? ''}';
    final fotoUrl = _vendedorData?['foto_perfil'] as String? ?? '';
    final initial = nombre.isNotEmpty ? nombre[0].toUpperCase() : '?';

    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: const Color(0xFFF5EFE6),
            elevation: 0,
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF4A3F30)),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: const Color(0xFFF5EFE6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: const Color(0xFFB5976A).withOpacity(0.15),
                      backgroundImage: fotoUrl.isNotEmpty ? NetworkImage(fotoUrl) : null,
                      child: fotoUrl.isEmpty
                          ? Text(initial, style: const TextStyle(color: Color(0xFFB5976A), fontSize: 28, fontWeight: FontWeight.bold))
                          : null,
                    ),
                    const SizedBox(height: 10),
                    Text(nombre, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4A3F30))),
                    const SizedBox(height: 2),
                    Text(username, style: const TextStyle(fontSize: 13, color: Color(0xFF9A8A75))),
                    const SizedBox(height: 12),
                    // Stats row
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      _statChip('$_followersCount', 'Seguidores', onTap: () => Navigator.pushNamed(context, '/followers',
                          arguments: {'mode': 'followers', 'uid': _vendedorId})),
                      const SizedBox(width: 20),
                      _statChip('$_seguidos', 'Seguidos', onTap: () => Navigator.pushNamed(context, '/followers',
                          arguments: {'mode': 'following', 'uid': _vendedorId})),
                    ]),
                    const SizedBox(height: 12),
                    // Action buttons
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      GestureDetector(
                        onTap: _followLoading ? null : _toggleFollow,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            color: _isFollowing ? Colors.transparent : const Color(0xFFB5976A),
                            border: Border.all(color: const Color(0xFFB5976A)),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: _followLoading
                              ? const SizedBox(width: 14, height: 14,
                                  child: CircularProgressIndicator(color: Color(0xFFB5976A), strokeWidth: 2))
                              : Text(_isFollowing ? 'Siguiendo' : 'Seguir',
                                  style: TextStyle(
                                    color: _isFollowing ? const Color(0xFFB5976A) : Colors.white,
                                    fontWeight: FontWeight.w600, fontSize: 13)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/chat',
                            arguments: {'other_uid': _vendedorId}),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: const Color(0xFFE0D0BC)),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text('Mensaje', style: TextStyle(
                              color: Color(0xFF4A3F30), fontWeight: FontWeight.w600, fontSize: 13)),
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabDelegate(TabBar(
              controller: _tabController,
              labelColor: const Color(0xFFB5976A),
              unselectedLabelColor: const Color(0xFF9A8A75),
              indicatorColor: const Color(0xFFB5976A),
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              tabs: const [Tab(text: 'Publicaciones'), Tab(text: 'Info')],
            )),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildProductsTab(),
            _buildInfoTab(),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavWidget(currentIndex: -1),
    );
  }

  Widget _statChip(String value, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4A3F30))),
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF9A8A75))),
      ]),
    );
  }

  Widget _buildProductsTab() {
    if (_vendedorId == null) return const SizedBox.shrink();
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _firestoreService.getProductsByVendedor(_vendedorId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFB5976A)));
        }
        final products = snapshot.data ?? [];
        if (products.isEmpty) {
          return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.storefront_outlined, size: 56, color: const Color(0xFFB5976A).withOpacity(0.3)),
            const SizedBox(height: 12),
            const Text('Sin publicaciones aún', style: TextStyle(color: Color(0xFF9A8A75), fontSize: 14)),
          ]));
        }
        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 0.72),
          itemCount: products.length,
          itemBuilder: (_, i) => _buildProductCard(products[i]),
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
          color: Colors.white, borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: const Color(0xFFB5976A).withOpacity(0.07), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            child: fotos.isNotEmpty
                ? Image.network(fotos.first, fit: BoxFit.cover, width: double.infinity,
                    errorBuilder: (_, __, ___) => _placeholder())
                : _placeholder(),
          )),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(product['nombre'] as String? ?? '',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF4A3F30)),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text(_formatPrice(precio),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFB5976A))),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _placeholder() => Container(
      color: const Color(0xFFE8D5C4),
      child: const Center(child: Icon(Icons.checkroom, color: Color(0xFFB5976A), size: 36)));

  Widget _buildInfoTab() {
    final descripcion = _vendedorData?['descripcion'] as String? ?? '';
    final ciudad = _vendedorData?['ciudad'] as String? ?? '';
    final email = _vendedorData?['email'] as String? ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (descripcion.isNotEmpty) ...[
          _infoCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Sobre mí', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF4A3F30))),
            const SizedBox(height: 8),
            Text(descripcion, style: const TextStyle(fontSize: 13, color: Color(0xFF5A4E40), height: 1.5)),
          ])),
          const SizedBox(height: 12),
        ],
        _infoCard(child: Column(children: [
          if (ciudad.isNotEmpty) _infoRow(Icons.location_on_outlined, ciudad),
          if (email.isNotEmpty) _infoRow(Icons.email_outlined, email),
          if (ciudad.isEmpty && email.isEmpty)
            const Text('Sin información adicional', style: TextStyle(color: Color(0xFF9A8A75), fontSize: 13)),
        ])),
      ]),
    );
  }

  Widget _infoCard({required Widget child}) => Container(
    width: double.infinity, padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white, borderRadius: BorderRadius.circular(14),
      boxShadow: [BoxShadow(color: const Color(0xFFB5976A).withOpacity(0.07), blurRadius: 8, offset: const Offset(0, 3))],
    ),
    child: child,
  );

  Widget _infoRow(IconData icon, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(children: [
      Icon(icon, size: 16, color: const Color(0xFFB5976A)),
      const SizedBox(width: 8),
      Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: Color(0xFF4A3F30)))),
    ]),
  );
}

class _TabDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  const _TabDelegate(this.tabBar);
  @override double get minExtent => tabBar.preferredSize.height + 1;
  @override double get maxExtent => tabBar.preferredSize.height + 1;
  @override Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) =>
      Container(color: Colors.white, child: tabBar);
  @override bool shouldRebuild(_TabDelegate old) => false;
}
