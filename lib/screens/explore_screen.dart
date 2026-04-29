import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';
import '../services/firestore_service.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String _selectedFilter = 'Todos';
  final _firestoreService = FirestoreService();

  // Búsqueda
  bool _searching = false;
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  final List<String> _filters = [
    'Todos', 'Streetwear', 'Vintage', 'Deportivo', 'Casual',
    'Formal', 'Elegante', 'Minimalista', 'Sostenible', 'Accesorios', 'Zapatos',
  ];

  String _formatPrice(double price) {
    return '\$${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  Stream<List<Map<String, dynamic>>> get _productsStream {
    if (_selectedFilter == 'Todos') return _firestoreService.getProductsStream();
    return _firestoreService.getProductsByCategory(_selectedFilter);
  }

  List<Map<String, dynamic>> _applySearch(List<Map<String, dynamic>> products) {
    if (_searchQuery.isEmpty) return products;
    final q = _searchQuery.toLowerCase();
    return products.where((p) {
      final nombre = (p['nombre'] as String? ?? '').toLowerCase();
      final vendedor = (p['vendedor_nombre'] as String? ?? '').toLowerCase();
      final categoria = (p['categoria'] as String? ?? '').toLowerCase();
      final descripcion = (p['descripcion'] as String? ?? '').toLowerCase();
      return nombre.contains(q) ||
          vendedor.contains(q) ||
          categoria.contains(q) ||
          descripcion.contains(q);
    }).toList();
  }

  void _openSearch() {
    setState(() { _searching = true; _searchQuery = ''; });
  }

  void _closeSearch() {
    setState(() {
      _searching = false;
      _searchQuery = '';
      _searchCtrl.clear();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          if (!_searching) _buildFilterBar(),
          Expanded(child: _buildProductGrid()),
        ],
      ),
      bottomNavigationBar: const BottomNavWidget(currentIndex: 1),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    if (_searching) {
      return AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFF5EFE6),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4A3F30)),
          onPressed: _closeSearch,
        ),
        title: TextField(
          controller: _searchCtrl,
          autofocus: true,
          style: const TextStyle(color: Color(0xFF4A3F30), fontSize: 16),
          decoration: const InputDecoration(
            hintText: 'Buscar prendas, vendedores...',
            hintStyle: TextStyle(color: Color(0xFFB0A090), fontSize: 15),
            border: InputBorder.none,
            isDense: true,
          ),
          onChanged: (v) => setState(() => _searchQuery = v.trim()),
        ),
        actions: [
          if (_searchQuery.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close, color: Color(0xFF9A8A75)),
              onPressed: () {
                _searchCtrl.clear();
                setState(() => _searchQuery = '');
              },
            ),
        ],
      );
    }

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: const Color(0xFFF5EFE6),
      elevation: 0,
      title: const Text('Explorar',
          style: TextStyle(
              color: Color(0xFF4A3F30),
              fontSize: 20,
              fontWeight: FontWeight.w600)),
      centerTitle: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Color(0xFF4A3F30)),
          onPressed: _openSearch,
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    return SizedBox(
      height: 42,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = filter),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8, bottom: 4, top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF3D3025) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF3D3025)
                      : const Color(0xFFE0D0BC),
                ),
              ),
              child: Center(
                child: Text(filter,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF4A3F30),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    )),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductGrid() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _productsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: Color(0xFFB5976A)));
        }

        final all = snapshot.data ?? [];
        final products = _applySearch(all);

        if (products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off,
                    size: 64,
                    color: const Color(0xFFB5976A).withOpacity(0.3)),
                const SizedBox(height: 16),
                Text(
                  _searchQuery.isNotEmpty
                      ? 'Sin resultados para "$_searchQuery"'
                      : _selectedFilter == 'Todos'
                      ? 'Aún no hay publicaciones'
                      : 'No hay prendas en "$_selectedFilter"',
                  style: const TextStyle(
                      color: Color(0xFF9A8A75), fontSize: 15),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(14),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.68,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) => _buildProductCard(products[index]),
        );
      },
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    final fotos = List<String>.from(product['fotos'] ?? []);
    final precio = (product['precio'] as num?)?.toDouble() ?? 0;

    return GestureDetector(
      onTap: () =>
          Navigator.pushNamed(context, '/product-detail', arguments: product),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
                borderRadius:
                const BorderRadius.vertical(top: Radius.circular(16)),
                child: fotos.isNotEmpty
                    ? Image.network(
                  fotos.first,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (_, __, ___) => _placeholderImage(),
                )
                    : _placeholderImage(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['nombre'] as String? ?? '',
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4A3F30)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product['vendedor_nombre'] as String? ?? '',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF9A8A75)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatPrice(precio),
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFB5976A)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      color: const Color(0xFFE8D5C4),
      child: Center(
        child: Icon(Icons.checkroom,
            size: 48, color: const Color(0xFFB5976A).withOpacity(0.4)),
      ),
    );
  }
}
