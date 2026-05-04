import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';
import '../services/firestore_service.dart';

class SellerProfileScreen extends StatefulWidget {
  const SellerProfileScreen({super.key});
  @override
  State<SellerProfileScreen> createState() => _SellerProfileScreenState();
}

class _SellerProfileScreenState extends State<SellerProfileScreen> {
  final _firestoreService = FirestoreService();

  String? _vendedorId;
  Map<String, dynamic>? _vendedorData;
  bool _loading = true;
  bool _isFollowing = false;
  bool _followLoading = false;
  int _followersCount = 0;
  int _seguidos = 0;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      final id = args['vendedor_id'] as String?;
      if (id != null && id.isNotEmpty) {
        _vendedorId = id;
        _loadAll();
        return;
      }
    }
    setState(() => _loading = false);
  }

  Future<void> _loadAll() async {
    if (_vendedorId == null) return;
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
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5EFE6),
        body: Center(child: CircularProgressIndicator(color: Color(0xFFB5976A))),
      );
    }

    if (_vendedorData == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5EFE6),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF5EFE6),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF4A3F30)),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: Text('No se pudo cargar el perfil.',
              style: TextStyle(color: Color(0xFF9A8A75), fontSize: 15)),
        ),
      );
    }

    final nombre = '${_vendedorData!['nombre'] ?? ''} ${_vendedorData!['apellido'] ?? ''}'.trim();
    final username = _vendedorData!['username'] as String? ?? '';
    final fotoUrl = _vendedorData!['foto_perfil'] as String? ?? '';
    final initial = nombre.isNotEmpty ? nombre[0].toUpperCase() : '?';

    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5EFE6),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4A3F30)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(nombre.isEmpty ? 'Perfil' : nombre,
            style: const TextStyle(color: Color(0xFF4A3F30), fontSize: 17, fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Column(children: [
              // Avatar
              CircleAvatar(
                radius: 42,
                backgroundColor: const Color(0xFFB5976A).withOpacity(0.15),
                backgroundImage: fotoUrl.isNotEmpty ? NetworkImage(fotoUrl) : null,
                child: fotoUrl.isEmpty
                    ? Text(initial, style: const TextStyle(
                        color: Color(0xFFB5976A), fontSize: 28, fontWeight: FontWeight.bold))
                    : null,
              ),
              const SizedBox(height: 10),
              Text(nombre, style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4A3F30))),
              if (username.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text('@$username', style: const TextStyle(fontSize: 13, color: Color(0xFF9A8A75))),
              ],
              const SizedBox(height: 16),
              // Stats
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                _statItem('$_followersCount', 'Seguidores',
                    onTap: () => Navigator.pushNamed(context, '/followers',
                        arguments: {'mode': 'followers', 'uid': _vendedorId})),
                const SizedBox(width: 32),
                _statItem('$_seguidos', 'Siguiendo',
                    onTap: () => Navigator.pushNamed(context, '/followers',
                        arguments: {'mode': 'following', 'uid': _vendedorId})),
              ]),
              const SizedBox(height: 16),
              // Action buttons
              Row(children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _followLoading ? null : _toggleFollow,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _isFollowing ? Colors.transparent : const Color(0xFFB5976A),
                        border: Border.all(color: const Color(0xFFB5976A)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(child: _followLoading
                          ? const SizedBox(width: 16, height: 16,
                              child: CircularProgressIndicator(color: Color(0xFFB5976A), strokeWidth: 2))
                          : Text(_isFollowing ? 'Siguiendo' : 'Seguir',
                              style: TextStyle(
                                color: _isFollowing ? const Color(0xFFB5976A) : Colors.white,
                                fontWeight: FontWeight.w600, fontSize: 14))),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/chat',
                        arguments: {'other_uid': _vendedorId}),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFE0D0BC)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(child: Text('Mensaje',
                          style: TextStyle(color: Color(0xFF4A3F30),
                              fontWeight: FontWeight.w600, fontSize: 14))),
                    ),
                  ),
                ),
              ]),
            ]),
          ),
          const SizedBox(height: 8),
          // Products
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: const Align(alignment: Alignment.centerLeft,
              child: Text('Publicaciones', style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF4A3F30)))),
          ),
          _buildProducts(),
          const SizedBox(height: 20),
        ]),
      ),
      bottomNavigationBar: const BottomNavWidget(currentIndex: -1),
    );
  }

  Widget _statItem(String value, String label, {VoidCallback? onTap}) {
    final content = Column(children: [
      Text(value, style: const TextStyle(
          fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF4A3F30))),
      Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF9A8A75))),
    ]);
    if (onTap == null) return content;
    return GestureDetector(onTap: onTap, child: content);
  }

  Widget _buildProducts() {
    if (_vendedorId == null) return const SizedBox.shrink();
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _firestoreService.getProductsByVendedor(_vendedorId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(40),
            child: Center(child: CircularProgressIndicator(color: Color(0xFFB5976A))),
          );
        }
        final products = snapshot.data ?? [];
        if (products.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(40),
            child: Center(child: Text('Sin publicaciones aún',
                style: TextStyle(color: Color(0xFF9A8A75), fontSize: 14))),
          );
        }
        return GridView.builder(
          padding: const EdgeInsets.all(12),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, mainAxisSpacing: 10,
              crossAxisSpacing: 10, childAspectRatio: 0.72),
          itemCount: products.length,
          itemBuilder: (_, i) => _buildCard(products[i]),
        );
      },
    );
  }

  Widget _buildCard(Map<String, dynamic> product) {
    final fotos = List<String>.from(product['fotos'] ?? []);
    final precio = (product['precio'] as num?)?.toDouble() ?? 0;
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/product-detail', arguments: product),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: const Color(0xFFB5976A).withOpacity(0.07),
              blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            child: fotos.isNotEmpty
                ? Image.network(fotos.first, fit: BoxFit.cover, width: double.infinity,
                    errorBuilder: (_, __, ___) => _placeholder())
                : _placeholder(),
          )),
          Padding(padding: const EdgeInsets.all(10), child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(product['nombre'] as String? ?? '',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                      color: Color(0xFF4A3F30)),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text(_formatPrice(precio), style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFB5976A))),
            ],
          )),
        ]),
      ),
    );
  }

  Widget _placeholder() => Container(color: const Color(0xFFE8D5C4),
      child: const Center(child: Icon(Icons.checkroom, color: Color(0xFFB5976A), size: 36)));
}
