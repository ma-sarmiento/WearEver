import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  String _selectedCategory = 'Toda';

  final List<String> _categories = [
    'Toda',
    'Streetwear',
    'Oficina',
    'Eventos',
  ];

  final List<Map<String, dynamic>> _savedItems = [
    {
      'brand': 'Prenda',
      'name': 'Blazer Sastre',
      'category': 'Oficina',
      'price': '\$299.900',
      'color': const Color(0xFFE8D5C4),
      'icon': Icons.checkroom,
    },
    {
      'brand': 'Prenda',
      'name': 'Sneakers Eco',
      'category': 'Streetwear',
      'price': '\$239.900',
      'color': const Color(0xFFD4C4B0),
      'icon': Icons.directions_walk_outlined,
    },
    {
      'brand': 'Prenda',
      'name': 'Jeans Classic',
      'category': 'Casual',
      'price': '\$129.900',
      'color': const Color(0xFFC4D4E8),
      'icon': Icons.accessibility_new,
    },
    {
      'brand': 'Prenda',
      'name': 'Sandalias Midi',
      'category': 'Eventos',
      'price': '\$189.900',
      'color': const Color(0xFFF0E6D4),
      'icon': Icons.bedtime_outlined,
    },
    {
      'brand': 'Prenda',
      'name': 'Vestido Gala',
      'category': 'Eventos',
      'price': '\$329.900',
      'color': const Color(0xFFE8D5C4),
      'icon': Icons.dry_cleaning,
    },
    {
      'brand': 'Prenda',
      'name': 'Chaqueta',
      'category': 'Streetwear',
      'price': '\$159.900',
      'color': const Color(0xFFD4C4B0),
      'icon': Icons.layers_outlined,
    },
  ];

  List<Map<String, dynamic>> get _filteredItems {
    if (_selectedCategory == 'Toda') return _savedItems;
    return _savedItems
        .where((item) => item['category'] == _selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildCategoryChips(),
            Expanded(child: _buildGrid()),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavWidget(currentIndex: -1),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          const Text(
            'Favoritos',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A3F30),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFB5976A).withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: const Color(0xFFB5976A).withOpacity(0.3)),
            ),
            child: const Text(
              '+ Nueva categoría',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFFB5976A),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = _selectedCategory == cat;
          // Count items per category
          final count = cat == 'Toda'
              ? _savedItems.length
              : _savedItems
              .where((i) => i['category'] == cat)
              .length;

          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color:
                isSelected ? const Color(0xFFB5976A) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFB5976A)
                      : const Color(0xFFE0D0BC),
                ),
              ),
              child: Text(
                '$cat $count',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected
                      ? FontWeight.w600
                      : FontWeight.normal,
                  color: isSelected
                      ? Colors.white
                      : const Color(0xFF7A6A55),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGrid() {
    final items = _filteredItems;
    return GridView.builder(
      padding: const EdgeInsets.all(14),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) => _buildSavedCard(items[index]),
    );
  }

  Widget _buildSavedCard(Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/product-detail'),
      child: Container(
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
            // Image
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: item['color'],
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(14)),
                    ),
                    child: Center(
                      child: Icon(
                        item['icon'],
                        size: 50,
                        color:
                        const Color(0xFFB5976A).withOpacity(0.4),
                      ),
                    ),
                  ),
                  // Category badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item['category'],
                        style: const TextStyle(
                            fontSize: 9,
                            color: Color(0xFF7A6A55),
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  // Remove bookmark
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.bookmark,
                          size: 14, color: Color(0xFFB5976A)),
                    ),
                  ),
                ],
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['brand'],
                    style: const TextStyle(
                        fontSize: 10, color: Color(0xFF9A8A75)),
                  ),
                  Text(
                    item['name'],
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4A3F30)),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item['price'],
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFB5976A)),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFB5976A),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.shopping_cart_outlined,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                    ],
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