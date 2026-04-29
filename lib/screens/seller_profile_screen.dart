import 'package:flutter/material.dart';
import '../widgets/smart_back_button.dart';
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
  bool _loadingUser = true;
  bool _isFollowing = false;
  bool _followLoading = false;
  int _followersCount = 0;

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
      _vendedorId = args['vendedor_id'] as String?;
    }
    if (_vendedorId != null && _vendedorData == null) {
      _loadVendedor();
    }
  }

  Future<void> _loadVendedor() async {
    if (_vendedorId == null) return;
    final results = await Future.wait([
      _firestoreService.getUserById(_vendedorId!),
      _firestoreService.isFollowing(_vendedorId!),
      _firestoreService.getFollowersCount(_vendedorId!),
    ]);
    if (mounted) {
      setState(() {
        _vendedorData = results[0] as Map<String, dynamic>?;
        _isFollowing = results[1] as bool;
        _followersCount = results[2] as int;
        _loadingUser = false;
      });
    }
  }

  Future<void> _toggleFollow() async {
    if (_vendedorId == null || _followLoading) return;
    setState(() => _followLoading = true);
    try {
      if (_isFollowing) {
        await _firestoreService.unfollowUser(_vendedorId!);
        if (mounted) {
          setState(() {
            _isFollowing = false;
            _followersCount = (_followersCount - 1).clamp(0, 9999);
          });
        }
      } else {
        await _firestoreService.followUser(_vendedorId!);
        if (mounted) {
          setState(() {
            _isFollowing = true;
            _followersCount++;
          });
        }
      }
    } finally {
      if (mounted) setState(() => _followLoading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatPrice(double price) {
    return '\$${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildSliverAppBar(),
          _buildTabBar(),
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

  Widget _buildSliverAppBar() {
    final nombre = _vendedorData != null
        ? '${_vendedorData!['nombre'] ?? ''} ${_vendedorData!['apellido'] ?? ''}'.trim()
        : 'Vendedor';
    final username = _vendedorData != null
        ? '@${_vendedorData!['username'] ?? ''}'
        : '';
    final fotoUrl = _vendedorData?['foto_perfil'] as String? ?? '';

    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: const Color(0xFFF5EFE6),
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: const Color(0xFFF5EFE6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CircleAvatar(
                radius: 44,
                backgroundColor:
                const Color(0xFFB5976A).withOpacity(0.15),
                backgroundImage: fotoUrl.isNotEmpty
                    ? NetworkImage(fotoUrl)
                    : null,
                child: fotoUrl.isEmpty
                    ? Text(
                  nombre.isNotEmpty
                      ? nombre.substring(0, 1).toUpperCase()
                      : 'V',
                  style: const TextStyle(
                    color: Color(0xFFB5976A),
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                )
                    : null,
              ),
              const SizedBox(height: 8),
              Text(
                nombre,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A3F30),
                ),
              ),
              if (username.isNotEmpty)
                Text(
                  username,
                  style: const TextStyle(
                      color: Color(0xFF9A8A75), fontSize: 13),
                ),
              const SizedBox(height: 4),
              // Conteo de seguidores
              if (!_loadingUser)
                Text(
                  '$_followersCount ${_followersCount == 1 ? 'seguidor' : 'seguidores'}',
                  style: const TextStyle(
                      color: Color(0xFFB5976A),
                      fontSize: 13,
                      fontWeight: FontWeight.w500),
                ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Botón Seguir con estado real
                  GestureDetector(
                    onTap: _toggleFollow,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 9),
                      decoration: BoxDecoration(
                        color: _isFollowing
                            ? Colors.white
                            : const Color(0xFFB5976A),
                        borderRadius: BorderRadius.circular(20),
                        border: _isFollowing
                            ? Border.all(color: const Color(0xFFB5976A))
                            : null,
                      ),
                      child: _followLoading
                          ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            color: Color(0xFFB5976A), strokeWidth: 2),
                      )
                          : Text(
                        _isFollowing ? 'Siguiendo' : 'Seguir',
                        style: TextStyle(
                          color: _isFollowing
                              ? const Color(0xFFB5976A)
                              : Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildActionBtn(
                    'Mensaje',
                    Colors.white,
                    textColor: const Color(0xFFB5976A),
                    bordered: true,
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/chat',
                      arguments: {'other_uid': _vendedorId},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionBtn(
      String label,
      Color bgColor, {
        Color textColor = Colors.white,
        bool bordered = false,
        VoidCallback? onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 9),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: bordered
              ? Border.all(color: const Color(0xFFB5976A))
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
              color: textColor, fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _TabBarDelegate(
        TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFB5976A),
          unselectedLabelColor: const Color(0xFF9A8A75),
          indicatorColor: const Color(0xFFB5976A),
          tabs: const [
            Tab(text: 'Prendas'),
            Tab(text: 'Info'),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsTab() {
    if (_vendedorId == null) {
      return const Center(
        child: Text('Vendedor no disponible',
            style: TextStyle(color: Color(0xFF9A8A75))),
      );
    }
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _firestoreService.getProductsByVendedor(_vendedorId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFB5976A)),
          );
        }
        final products = snapshot.data ?? [];
        if (products.isEmpty) {
          return const Center(
            child: Text('Este vendedor aún no tiene publicaciones',
                style: TextStyle(color: Color(0xFF9A8A75))),
          );
        }
        return GridView.builder(
          padding: const EdgeInsets.all(14),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.72,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final p = products[index];
            final fotos = List<String>.from(p['fotos'] ?? []);
            final precio = (p['precio'] as num?)?.toDouble() ?? 0;
            return GestureDetector(
              onTap: () =>
                  Navigator.pushNamed(context, '/product-detail', arguments: p),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFB5976A).withOpacity(0.07),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(14)),
                        child: fotos.isNotEmpty
                            ? Image.network(fotos.first,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (_, __, ___) => _placeholder())
                            : _placeholder(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p['nombre'] as String? ?? '',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4A3F30),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatPrice(precio),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFB5976A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInfoTab() {
    if (_loadingUser) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFB5976A)),
      );
    }
    final data = _vendedorData;
    if (data == null) {
      return const Center(
        child: Text('Información no disponible',
            style: TextStyle(color: Color(0xFF9A8A75))),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildInfoCard('Nombre',
            '${data['nombre'] ?? ''} ${data['apellido'] ?? ''}'.trim()),
        _buildInfoCard('Usuario', '@${data['username'] ?? ''}'),
        _buildInfoCard('Correo', data['email'] as String? ?? ''),
        if ((data['gustos_estilos'] as List?)?.isNotEmpty == true)
          _buildInfoCard(
            'Estilos',
            (data['gustos_estilos'] as List).join(', '),
          ),
      ],
    );
  }

  Widget _buildInfoCard(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF9A8A75),
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF4A3F30),
                  fontWeight: FontWeight.w500),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xFFE8D5C4),
      child: Center(
        child: Icon(Icons.checkroom,
            size: 40, color: const Color(0xFFB5976A).withOpacity(0.4)),
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  _TabBarDelegate(this.tabBar);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) =>
      Container(color: const Color(0xFFF5EFE6), child: tabBar);

  @override
  double get maxExtent => tabBar.preferredSize.height;
  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}
