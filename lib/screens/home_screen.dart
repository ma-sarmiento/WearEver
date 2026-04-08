import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _posts = [
    {
      'seller': 'Atelier Nova',
      'handle': '@atelierrnova',
      'price': '\$33,543',
      'name': 'Blusa Elegante',
      'description': 'Perfecta para una ocasión especial',
      'color': const Color(0xFFE8D5C4),
      'icon': Icons.checkroom,
    },
    {
      'seller': 'Atelier Nova',
      'handle': '@atelierrnova',
      'price': '\$40,284',
      'name': 'Aretes Elegantes',
      'description': 'Perfectos para el evento que estabas esperando!!',
      'color': const Color(0xFFE8D5C4),
      'icon': Icons.diamond_outlined,
    },
    {
      'seller': 'Moda Chic',
      'handle': '@modachic',
      'price': '\$28,000',
      'name': 'Vestido Floral',
      'description': 'Diseño exclusivo para esta temporada',
      'color': const Color(0xFFD4C4B0),
      'icon': Icons.local_florist,
    },
  ];

  bool _showAiBubble = true;
  bool _showAiBubble2 = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF5EFE6),
      elevation: 0,
      centerTitle: false,
      title: const Text(
        'ModaNexus',
        style: TextStyle(
          color: Color(0xFF4A3F30),
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      actions: [
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_cart_outlined,
                  color: Color(0xFF4A3F30)),
              onPressed: () {},
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: Color(0xFFB5976A),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    '5',
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBody() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      itemCount: _posts.length,
      itemBuilder: (context, index) {
        final post = _posts[index];
        return Column(
          children: [
            _buildPostCard(post, index),
            if (index == 0 && _showAiBubble) _buildAiBubble(),
            const SizedBox(height: 12),
          ],
        );
      },
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post, int index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB5976A).withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFFE8D5C4),
                  child: Text(
                    post['seller'].toString().substring(0, 1),
                    style: const TextStyle(
                      color: Color(0xFFB5976A),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post['seller'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4A3F30),
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      post['handle'],
                      style: const TextStyle(
                        color: Color(0xFF9A8A75),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  post['price'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A3F30),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          // Image placeholder
          Container(
            width: double.infinity,
            height: 200,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: post['color'],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    post['icon'],
                    size: 80,
                    color: const Color(0xFFB5976A).withOpacity(0.4),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.bookmark_border,
                      size: 18,
                      color: Color(0xFFB5976A),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Footer
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.bookmark_border,
                    size: 20, color: Color(0xFF9A8A75)),
                const SizedBox(width: 12),
                const Icon(Icons.favorite_border,
                    size: 20, color: Color(0xFF9A8A75)),
                const SizedBox(width: 12),
                const Icon(Icons.group_outlined,
                    size: 20, color: Color(0xFF9A8A75)),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      post['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF4A3F30),
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      post['description'],
                      style: const TextStyle(
                        color: Color(0xFF9A8A75),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB5976A),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.shopping_cart_outlined,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiBubble() {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
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
              child: Text(
                'AI',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Hey, encontré algo\nque te puede gustar',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
              ),
            ),
          ),
          Column(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8D5C4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.diamond_outlined,
                  color: Color(0xFFB5976A),
                  size: 28,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Nombre prenda',
                style: TextStyle(color: Colors.white54, fontSize: 10),
              ),
              const Text(
                '\$33,543',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    final items = [
      Icons.home_outlined,
      Icons.search_outlined,
      Icons.chat_bubble_outline,
      Icons.grid_view_outlined,
      Icons.person_outline,
    ];

    return Container(
      height: 65,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final isSelected = _selectedIndex == i;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedIndex = i);
              if (i == 3) {
                Navigator.pushNamed(context, '/ong');
              }
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: isSelected
                  ? BoxDecoration(
                color: const Color(0xFFB5976A).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              )
                  : null,
              child: Icon(
                items[i],
                color: isSelected
                    ? const Color(0xFFB5976A)
                    : const Color(0xFF9A8A75),
                size: 24,
              ),
            ),
          );
        }),
      ),
    );
  }
}