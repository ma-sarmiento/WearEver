import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String _selectedFilter = 'Streetwear';

  final List<String> _filters = [
    'Streetwear',
    'Vintage',
    'Deportivo',
    'Casual',
    'Formal',
    'Elegante',
  ];

  final List<Map<String, dynamic>> _posts = [
    {
      'seller': 'Atelier Nova',
      'time': 'hace 2m',
      'name': 'Blazer Premium en Lino',
      'description': 'Perfecta para una ocasión formal',
      'price': '\$189.900',
      'height': 280.0,
      'color': const Color(0xFFE8D5C4),
      'icon': Icons.checkroom,
    },
    {
      'seller': 'Atelier Nova',
      'time': 'hace 2m',
      'name': 'Outfit Urbano',
      'description': 'Estilo único para la ciudad',
      'price': '\$145.000',
      'height': 220.0,
      'color': const Color(0xFFD4C4B0),
      'icon': Icons.person_outline,
    },
    {
      'seller': 'Moda Chic',
      'time': 'hace 1h',
      'name': 'Vestido Casual',
      'description': 'Para el día a día',
      'price': '\$98.000',
      'height': 240.0,
      'color': const Color(0xFFF0E6D4),
      'icon': Icons.dry_cleaning,
    },
    {
      'seller': 'Urban Style',
      'time': 'hace 3h',
      'name': 'Jeans Slim',
      'description': 'Comodidad y estilo',
      'price': '\$129.900',
      'height': 260.0,
      'color': const Color(0xFFD4C4B0),
      'icon': Icons.accessibility_new,
    },
    {
      'seller': 'Atelier Nova',
      'time': 'hace 5h',
      'name': 'Blusa Floral',
      'description': 'Colores vibrantes',
      'price': '\$75.000',
      'height': 200.0,
      'color': const Color(0xFFE8D5C4),
      'icon': Icons.local_florist,
    },
    {
      'seller': 'Nova Trends',
      'time': 'hace 6h',
      'name': 'Chaqueta Denim',
      'description': 'Clásica y versátil',
      'price': '\$159.900',
      'height': 250.0,
      'color': const Color(0xFFC4D4E8),
      'icon': Icons.layers_outlined,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            _buildFilterChips(),
            Expanded(child: _buildPinterestGrid()),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavWidget(currentIndex: 1),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: const [
                  SizedBox(width: 12),
                  Icon(Icons.search, color: Color(0xFFB5976A), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Buscar marcas, estilos...',
                    style: TextStyle(
                      color: Color(0xFFB0A090),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.tune_outlined,
              color: Color(0xFFB5976A),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = filter),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFFC4A882), Color(0xFFB5976A)],
                      )
                    : null,
                color: isSelected ? null : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFB5976A)
                      : const Color(0xFFE0D0BC),
                ),
              ),
              child: Text(
                filter,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? Colors.white : const Color(0xFF7A6A55),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPinterestGrid() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left column
          Expanded(
            child: Column(
              children: _posts
                  .asMap()
                  .entries
                  .where((e) => e.key % 2 == 0)
                  .map((e) => _buildPostCard(e.value))
                  .toList(),
            ),
          ),
          const SizedBox(width: 10),
          // Right column
          Expanded(
            child: Column(
              children: [
                const SizedBox(height: 30),
                ..._posts
                    .asMap()
                    .entries
                    .where((e) => e.key % 2 != 0)
                    .map((e) => _buildPostCard(e.value))
                    .toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/product-detail'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Seller header
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: const Color(0xFFE8D5C4),
                    child: Text(
                      post['seller'].toString().substring(0, 1),
                      style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFFB5976A),
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post['seller'],
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4A3F30)),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          post['time'],
                          style: const TextStyle(
                              fontSize: 10, color: Color(0xFF9A8A75)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Image
            Container(
              width: double.infinity,
              height: post['height'],
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: post['color'],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Icon(
                  post['icon'],
                  size: 50,
                  color: const Color(0xFFB5976A).withOpacity(0.4),
                ),
              ),
            ),
            // Footer
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post['name'],
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF4A3F30)),
                  ),
                  Text(
                    post['description'],
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFF9A8A75)),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.group_outlined,
                              size: 14, color: Color(0xFF9A8A75)),
                          SizedBox(width: 6),
                          Icon(Icons.favorite_border,
                              size: 14, color: Color(0xFF9A8A75)),
                          SizedBox(width: 6),
                          Icon(Icons.bookmark_border,
                              size: 14, color: Color(0xFF9A8A75)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFB5976A),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.add,
                            size: 14, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    post['price'],
                    style: const TextStyle(
                        fontSize: 13,
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

}