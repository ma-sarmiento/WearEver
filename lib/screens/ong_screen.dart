import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';

class OngScreen extends StatefulWidget {
  const OngScreen({super.key});

  @override
  State<OngScreen> createState() => _OngScreenState();
}

class _OngScreenState extends State<OngScreen> {
  bool _showAiMessage = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildStats(),
                  const SizedBox(height: 16),
                  _buildDescription(),
                  const SizedBox(height: 16),
                  _buildPost(),
                  const SizedBox(height: 12),
                  if (_showAiMessage) _buildAiCongratulatoryBubble(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavWidget(currentIndex: 3),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      backgroundColor: const Color(0xFFF5EFE6),
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            // Cover background
            Container(
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF8B7355).withOpacity(0.6),
                    const Color(0xFF6B5B45).withOpacity(0.4),
                  ],
                ),
                image: DecorationImage(
                  image: const NetworkImage(
                    'https://via.placeholder.com/400x120',
                  ),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    const Color(0xFF8B7355).withOpacity(0.5),
                    BlendMode.multiply,
                  ),
                  onError: (_, __) {},
                ),
              ),
            ),
            // Profile info overlay
            Positioned(
              bottom: 0,
              left: 16,
              right: 16,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8D5C4),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Container(
                        color: const Color(0xFFD4B896),
                        child: const Icon(
                          Icons.volunteer_activism,
                          color: Color(0xFFB5976A),
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'ONG',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color(0xFF4A3F30),
                          ),
                        ),
                        Text(
                          '@ONG',
                          style: TextStyle(
                            color: Color(0xFF9A8A75),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      _buildActionIcon(Icons.group_outlined),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/map'),
                        child: _buildActionIcon(Icons.location_on_outlined),
                      ),
                      const SizedBox(width: 10),
                      _buildActionIcon(Icons.chat_bubble_outline),
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

  Widget _buildActionIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 4,
          ),
        ],
      ),
      child: Icon(icon, size: 18, color: const Color(0xFFB5976A)),
    );
  }

  Widget _buildStats() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB5976A).withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Puntos', '128'),
          _buildVerticalDivider(),
          _buildStatItem('Seguidores', '12.4k'),
          _buildVerticalDivider(),
          _buildStatItem('Calificación', '4.8 ★'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF9A8A75),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4A3F30),
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 40,
      color: const Color(0xFFE8D5C4),
    );
  }

  Widget _buildDescription() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
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
          const Text(
            'La ropa se entrega a personas en situación de pobreza, migrantes, refugiados o damnificados por desastres, promoviendo la dignificación de los beneficiarios.',
            style: TextStyle(
              color: Color(0xFF5A4E40),
              fontSize: 13.5,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'www.atelierrnova.com',
            style: TextStyle(
              color: Color(0xFFB5976A),
              fontSize: 13,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPost() {
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
          // Post header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8D5C4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.volunteer_activism,
                    color: Color(0xFFB5976A),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'ONG',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4A3F30),
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'hace 2m',
                      style: TextStyle(
                        color: Color(0xFF9A8A75),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Post image
          Container(
            width: double.infinity,
            height: 180,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFB8D4E8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    color: const Color(0xFF7BAAC4),
                    child: const Center(
                      child: Icon(
                        Icons.flood_outlined,
                        size: 60,
                        color: Colors.white54,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.checkroom, size: 14, color: Color(0xFFB5976A)),
                        SizedBox(width: 2),
                        Text(
                          '+2',
                          style: TextStyle(
                            color: Color(0xFFB5976A),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Post caption
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.favorite_border, size: 18, color: Color(0xFF9A8A75)),
                    SizedBox(width: 10),
                    Icon(Icons.chat_bubble_outline, size: 18, color: Color(0xFF9A8A75)),
                    SizedBox(width: 10),
                    Icon(Icons.group_outlined, size: 18, color: Color(0xFF9A8A75)),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Las inundaciones en Montería dejaron a muchas familias sin básico, estamos recolectando ropa en buen estado para quienes lo perdieron todo. Tu ayuda puede brindar abrigo y esperanza 💙',
                  style: TextStyle(
                    color: Color(0xFF5A4E40),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiCongratulatoryBubble() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFD4C4A8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF3D3025),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'AI',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Hito: Te felicito por elegir apoyar a Fundación Trabajemos por Colombia, es una decisión increíble que habla muy bien de ti.',
              style: TextStyle(
                color: Color(0xFF4A3F30),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

}