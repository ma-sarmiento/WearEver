import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';

class SellerProfileScreen extends StatefulWidget {
  const SellerProfileScreen({super.key});

  @override
  State<SellerProfileScreen> createState() => _SellerProfileScreenState();
}

class _SellerProfileScreenState extends State<SellerProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _products = [
    {
      'name': 'Blazer Premium en Lino',
      'price': '\$189.900',
      'category': 'Formal',
      'icon': Icons.checkroom,
      'color': const Color(0xFFE8D5C4),
    },
    {
      'name': 'Pantalón Wide Leg',
      'price': '\$129.900',
      'category': 'Casual',
      'icon': Icons.accessibility_new,
      'color': const Color(0xFFD4C4B0),
    },
    {
      'name': 'Blusa Elegante',
      'price': '\$89.900',
      'category': 'Elegante',
      'icon': Icons.dry_cleaning,
      'color': const Color(0xFFE8D5C4),
    },
    {
      'name': 'Aretes Elegantes',
      'price': '\$40.284',
      'category': 'Accesorios',
      'icon': Icons.diamond_outlined,
      'color': const Color(0xFFF0E6D4),
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: const Color(0xFFF5EFE6),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF4A3F30)),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFD4B896), Color(0xFFF5EFE6)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 50, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                            ),
                          ],
                          image: const DecorationImage(
                            image: NetworkImage(
                                'https://via.placeholder.com/72'),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: ClipOval(
                          child: Container(
                            color: const Color(0xFFD4B896),
                            child: const Icon(Icons.store,
                                color: Color(0xFFB5976A), size: 36),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Atelier Nova',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4A3F30),
                              ),
                            ),
                            Text(
                              '@atelierrnova',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF9A8A75),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          _buildActionIcon(Icons.location_on_outlined),
                          const SizedBox(width: 8),
                          _buildActionIcon(Icons.chat_bubble_outline),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildStats(),
                  const SizedBox(height: 8),
                  const Text(
                    'Moda sostenible, hecha a mano en Bogotá. Envíos a todo el país.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF7A6A55)),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'www.atelierrnova.com',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFFB5976A),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const Text(
                    '@instagram/atelierrnova',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFFB5976A),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 4),
        ],
      ),
      child: Icon(icon, size: 18, color: const Color(0xFFB5976A)),
    );
  }

  Widget _buildStats() {
    return Row(
      children: [
        _buildStatItem('Productos', '128'),
        const SizedBox(width: 20),
        _buildStatItem('Seguidores', '12.4k'),
        const SizedBox(width: 20),
        _buildStatItem('Calificación', '4.8 ★'),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
            const TextStyle(fontSize: 11, color: Color(0xFF9A8A75))),
        Text(value,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A3F30))),
      ],
    );
  }

  SliverPersistentHeader _buildTabBar() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _SliverTabBarDelegate(
        TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFB5976A),
          labelColor: const Color(0xFFB5976A),
          unselectedLabelColor: const Color(0xFF9A8A75),
          tabs: const [
            Tab(icon: Icon(Icons.checkroom_outlined)),
            Tab(icon: Icon(Icons.percent_outlined)),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
          // Image
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: product['color'],
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(product['icon'],
                      size: 70,
                      color: const Color(0xFFB5976A).withOpacity(0.35)),
                ),
                // Carousel dots
                Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3,
                          (i) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        width: i == 0 ? 16 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: i == 0
                              ? const Color(0xFFB5976A)
                              : Colors.white.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ),
                // Globe icon
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.language,
                        size: 16, color: Color(0xFFB5976A)),
                  ),
                ),
              ],
            ),
          ),
          // Info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Color(0xFF4A3F30),
                      ),
                    ),
                    Text(
                      product['price'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFFB5976A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Sizes
                Row(
                  children: ['S', 'M', 'L', 'Unisex'].map((size) {
                    return Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: const Color(0xFFE0D0BC)),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(size,
                          style: const TextStyle(
                              fontSize: 11, color: Color(0xFF7A6A55))),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildProductAction(Icons.group_outlined),
                    const SizedBox(width: 10),
                    _buildProductAction(Icons.favorite_border),
                    const SizedBox(width: 10),
                    _buildProductAction(Icons.bookmark_border),
                    const Spacer(),
                    GestureDetector(
                      onTap: () =>
                          Navigator.pushNamed(context, '/product-detail'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: const Color(0xFFB5976A),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Detalles',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // AI recommendation bubble
          Container(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF0E6D4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3D3025),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: const Center(
                    child: Text('AI',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Tito tiene una recomendación para ti',
                    style:
                    TextStyle(fontSize: 12, color: Color(0xFF4A3F30)),
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8D5C4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.checkroom,
                      size: 20, color: Color(0xFFB5976A)),
                ),
                const SizedBox(width: 6),
                const Text('\$33,543',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Color(0xFF4A3F30))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductAction(IconData icon) {
    return Icon(icon, size: 20, color: const Color(0xFF9A8A75));
  }

  Widget _buildInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard('Sobre nosotros',
              'Atelier Nova es una marca colombiana de moda sostenible, hecha a mano en Bogotá. Cada prenda es única y elaborada con materiales de alta calidad.'),
          const SizedBox(height: 12),
          _buildInfoCard('Políticas de envío',
              'Envíos a todo el país. Estándar 3-5 días hábiles (\$9.900). Exprés 24-48h (\$19.900).'),
          const SizedBox(height: 12),
          _buildInfoCard('Devoluciones',
              'Aceptamos devoluciones hasta 15 días después de recibido el pedido en perfecto estado.'),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String content) {
    return Container(
      padding: const EdgeInsets.all(14),
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
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Color(0xFF4A3F30))),
          const SizedBox(height: 6),
          Text(content,
              style: const TextStyle(
                  fontSize: 13, color: Color(0xFF7A6A55), height: 1.5)),
        ],
      ),
    );
  }

}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  _SliverTabBarDelegate(this.tabBar);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) =>
      Container(color: const Color(0xFFF5EFE6), child: tabBar);

  @override
  double get maxExtent => tabBar.preferredSize.height;
  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  bool shouldRebuild(_SliverTabBarDelegate old) => false;
}