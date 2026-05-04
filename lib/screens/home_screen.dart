import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/bottom_nav.dart';
import '../services/firestore_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showAiBubble = true;
  final Set<String> _pressedCards = {};
  final _firestoreService = FirestoreService();

  String _formatPrice(double price) {
    return price
        .toStringAsFixed(0)
        .replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/chat'),
        backgroundColor: const Color(0xFF3D3025),
        foregroundColor: Colors.white,
        elevation: 4,
        child: const Icon(Icons.smart_toy_outlined),
      ),
      bottomNavigationBar: const BottomNavWidget(currentIndex: 0),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: const Color(0xFFF5EFE6),
      elevation: 0,
      centerTitle: false,
      title: StreamBuilder<Map<String, dynamic>?>(
        stream: _firestoreService.getUserStream(),
        builder: (context, snapshot) {
          final userData = snapshot.data;
          final nombre = userData?['nombre'] as String? ?? '';
          final apellido = userData?['apellido'] as String? ?? '';
          final fotoUrl = userData?['foto_perfil'] as String? ?? '';
          final initials = '${nombre.isNotEmpty ? nombre[0] : ''}${apellido.isNotEmpty ? apellido[0] : ''}'
              .toUpperCase();

          return Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/profile'),
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color(0xFFB5976A).withOpacity(0.15),
                  backgroundImage:
                  fotoUrl.isNotEmpty ? NetworkImage(fotoUrl) : null,
                  child: fotoUrl.isEmpty
                      ? Text(
                    initials.isNotEmpty ? initials : 'W',
                    style: const TextStyle(
                      color: Color(0xFFB5976A),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                      : null,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'WearEver',
                style: TextStyle(
                  color: Color(0xFF4A3F30),
                  fontSize: 22,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 2,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          );
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.add_circle_outline, color: Color(0xFFB5976A)),
          onPressed: () => Navigator.pushNamed(context, '/create-product'),
          tooltip: 'Publicar',
        ),
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: _firestoreService.getCartStream(),
          builder: (context, snapshot) {
            final count = snapshot.data?.length ?? 0;
            return Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_bag_outlined,
                      color: Color(0xFF4A3F30)),
                  onPressed: () => Navigator.pushNamed(context, '/cart'),
                ),
                if (count > 0)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: Color(0xFFB5976A),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$count',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        _buildWelcomeBanner(),
        Expanded(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: _firestoreService.getProductsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFB5976A),
                  ),
                );
              }
              final products = snapshot.data ?? [];
              if (products.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.checkroom_outlined,
                          size: 64,
                          color: const Color(0xFFB5976A).withOpacity(0.3)),
                      const SizedBox(height: 16),
                      const Text(
                        'Sé el primero en publicar 👗',
                        style: TextStyle(
                            color: Color(0xFF9A8A75), fontSize: 15),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(
                            context, '/create-product'),
                        child: const Text('Publicar ahora',
                            style: TextStyle(color: Color(0xFFB5976A))),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return Column(
                    children: [
                      _buildProductCard(product),
                      if (index == 0 && _showAiBubble) _buildAiBubble(),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeBanner() {
    return StreamBuilder<Map<String, dynamic>?>(
      stream: _firestoreService.getUserStream(),
      builder: (context, snapshot) {
        final nombre = snapshot.data?['nombre'] as String? ?? '';
        return Container(
          margin: const EdgeInsets.fromLTRB(14, 8, 14, 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF3D3025), Color(0xFF5C4A35)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombre.isNotEmpty
                          ? '¡Hola, $nombre! 👋'
                          : '¡Bienvenido a WearEver! 👋',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Descubre moda sostenible cerca de ti',
                      style: TextStyle(
                          color: Color(0xFFD4C4A8), fontSize: 13),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.pushNamed(context, '/explore'),
                style: TextButton.styleFrom(
                  backgroundColor:
                  const Color(0xFFB5976A).withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                ),
                child: const Text('Explorar',
                    style: TextStyle(
                        color: Colors.white, fontSize: 13)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    final productId = product['id'] as String? ?? '';
    final isPressed = _pressedCards.contains(productId);
    final fotos = List<String>.from(product['fotos'] ?? []);
    final precio = (product['precio'] as num?)?.toDouble() ?? 0;
    final nombre = product['nombre'] as String? ?? '';
    final vendedorNombre = product['vendedor_nombre'] as String? ?? '';
    final vendedorId = product['vendedor_id'] as String? ?? '';
    final vendedorFoto = product['vendedor_foto'] as String? ?? '';
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final isOwn = vendedorId == currentUid;

    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        '/product-detail',
        arguments: product,
      ),
      onTapDown: (_) =>
          setState(() => _pressedCards.add(productId)),
      onTapUp: (_) =>
          setState(() => _pressedCards.remove(productId)),
      onTapCancel: () =>
          setState(() => _pressedCards.remove(productId)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        margin: const EdgeInsets.only(bottom: 14),
        transform: Matrix4.identity()
          ..scale(isPressed ? 0.98 : 1.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFB5976A).withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen
            ClipRRect(
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(18)),
              child: SizedBox(
                height: 200,
                width: double.infinity,
                child: fotos.isNotEmpty
                    ? Image.network(
                  fotos.first,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _placeholder(),
                )
                    : _placeholder(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nombre,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4A3F30),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/seller-profile',
                            arguments: {'vendedor_id': vendedorId},
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 10,
                                backgroundColor: const Color(0xFFE8D5C4),
                                backgroundImage: vendedorFoto.isNotEmpty
                                    ? NetworkImage(vendedorFoto)
                                    : null,
                                child: vendedorFoto.isEmpty
                                    ? Text(
                                  vendedorNombre.isNotEmpty
                                      ? vendedorNombre[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                      fontSize: 9,
                                      color: Color(0xFFB5976A),
                                      fontWeight: FontWeight.bold),
                                )
                                    : null,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                vendedorNombre,
                                style: const TextStyle(
                                    fontSize: 13, color: Color(0xFF9A8A75)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _formatPrice(precio),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFB5976A),
                    ),
                  ),
                ],
              ),
            ),
            // Botones
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Row(
                children: [
                  if (!isOwn)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/product-detail',
                              arguments: product);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB5976A),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding:
                          const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: const Text('Ver producto',
                            style: TextStyle(fontSize: 13)),
                      ),
                    ),
                  if (!isOwn) const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => _firestoreService.toggleSaved(product),
                    child: Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5EFE6),
                        borderRadius: BorderRadius.circular(10),
                        border:
                        Border.all(color: const Color(0xFFE0D0BC)),
                      ),
                      child: const Icon(Icons.bookmark_border,
                          color: Color(0xFFB5976A), size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAiBubble() {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/chat'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF3D3025),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFB5976A),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text('AI',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Hilo puede ayudarte a combinar estas prendas 🧵 ¡Pregúntale!',
                style: TextStyle(
                    color: Colors.white, fontSize: 13, height: 1.4),
              ),
            ),
            GestureDetector(
              onTap: () => setState(() => _showAiBubble = false),
              child: const Icon(Icons.close,
                  color: Color(0xFF9A8A75), size: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xFFE8D5C4),
      child: Center(
        child: Icon(Icons.checkroom,
            size: 60, color: const Color(0xFFB5976A).withOpacity(0.3)),
      ),
    );
  }
}