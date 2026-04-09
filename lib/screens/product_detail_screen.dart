import 'package:flutter/material.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String _selectedSize = 'M';
  bool _isSaved = false;
  bool _isLiked = false;
  int _currentImage = 0;

  final List<String> _sizes = ['S', 'M', 'L', 'Unisex'];
  final List<String> _tags = ['Streetwear', 'Vintage', 'Edición limitada'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildSliverAppBar(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTags(),
                      const SizedBox(height: 14),
                      _buildTitleAndPrice(),
                      const SizedBox(height: 14),
                      _buildSizeSelector(),
                      const SizedBox(height: 20),
                      _buildActionButtons(),
                      const SizedBox(height: 20),
                      _buildDescription(),
                      const SizedBox(height: 16),
                      _buildAiRecommendation(),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Bottom action bar
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,
      backgroundColor: const Color(0xFFF5EFE6),
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.1), blurRadius: 6),
            ],
          ),
          child: const Icon(Icons.arrow_back,
              color: Color(0xFF4A3F30), size: 20),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.1), blurRadius: 6),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.more_horiz,
                color: Color(0xFF4A3F30), size: 20),
            onPressed: () {},
          ),
        ),
      ],
      title: const Text(
        'Publicación',
        style: TextStyle(
          color: Color(0xFF4A3F30),
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            // Main image
            Container(
              color: const Color(0xFFE8D5C4),
              child: Center(
                child: Icon(
                  Icons.checkroom,
                  size: 120,
                  color: const Color(0xFFB5976A).withOpacity(0.3),
                ),
              ),
            ),
            // Seller info overlay
            Positioned(
              top: 90,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: const Color(0xFFD4B896),
                    child: const Icon(Icons.store,
                        color: Color(0xFFB5976A), size: 18),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/seller-profile'),
                    child: const Text(
                      'Atelier Nova',
                      style: TextStyle(
                        color: Color(0xFF4A3F30),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const Spacer(),
                  _buildSellerButton('Seguir', const Color(0xFFB5976A)),
                  const SizedBox(width: 8),
                  _buildSellerButton('Chat', Colors.white,
                      textColor: const Color(0xFFB5976A),
                      bordered: true),
                ],
              ),
            ),
            // Image dots indicator
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                      (i) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: _currentImage == i ? 16 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: _currentImage == i
                          ? const Color(0xFFB5976A)
                          : Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
            // Camera/video badge
            Positioned(
              bottom: 30,
              right: 16,
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Cam/foto o Video',
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSellerButton(String label, Color bgColor,
      {Color textColor = Colors.white, bool bordered = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: bordered
            ? Border.all(color: const Color(0xFFB5976A))
            : null,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1), blurRadius: 4),
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
            color: textColor,
            fontSize: 12,
            fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildTags() {
    return Wrap(
      spacing: 8,
      children: _tags.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFB5976A).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border:
            Border.all(color: const Color(0xFFB5976A).withOpacity(0.3)),
          ),
          child: Text(
            tag,
            style: const TextStyle(
                fontSize: 11,
                color: Color(0xFFB5976A),
                fontWeight: FontWeight.w500),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTitleAndPrice() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Blazer Premium en Lino',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A3F30),
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Tallas S • M • L • Unisex',
                style: TextStyle(fontSize: 13, color: Color(0xFF9A8A75)),
              ),
            ],
          ),
        ),
        const Text(
          '\$189.900',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFFB5976A),
          ),
        ),
      ],
    );
  }

  Widget _buildSizeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Talla',
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4A3F30)),
        ),
        const SizedBox(height: 8),
        Row(
          children: _sizes.map((size) {
            final isSelected = _selectedSize == size;
            return GestureDetector(
              onTap: () => setState(() => _selectedSize = size),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFB5976A)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFFB5976A)
                        : const Color(0xFFE0D0BC),
                  ),
                ),
                child: Text(
                  size,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : const Color(0xFF7A6A55),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        _buildIconAction(
          icon: _isSaved ? Icons.bookmark : Icons.bookmark_border,
          isActive: _isSaved,
          onTap: () => setState(() => _isSaved = !_isSaved),
        ),
        const SizedBox(width: 10),
        _buildIconAction(
          icon: _isLiked ? Icons.favorite : Icons.favorite_border,
          isActive: _isLiked,
          onTap: () => setState(() => _isLiked = !_isLiked),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/cart'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB5976A),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('Agregar al carrito',
                style:
                TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE0D0BC)),
          ),
          child: const Icon(Icons.language,
              color: Color(0xFFB5976A), size: 20),
        ),
      ],
    );
  }

  Widget _buildIconAction({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFFB5976A).withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive
                ? const Color(0xFFB5976A)
                : const Color(0xFFE0D0BC),
          ),
        ),
        child: Icon(icon,
            color: isActive
                ? const Color(0xFFB5976A)
                : const Color(0xFF9A8A75),
            size: 20),
      ),
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
              color: const Color(0xFFB5976A).withOpacity(0.07),
              blurRadius: 8,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Descripción',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4A3F30))),
          SizedBox(height: 8),
          Text(
            'Lino 100%, forro interno suave, corte slim fit. Ideal para climas cálidos y ocasiones formales. Cada prenda está elaborada a mano por artesanas colombianas.',
            style: TextStyle(
                fontSize: 13,
                color: Color(0xFF7A6A55),
                height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildAiRecommendation() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0E6D4),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF3D3025),
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
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Hilo piensa que esa prenda ira perfecta con este pantalón',
              style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF4A3F30),
                  height: 1.4),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFD4C4B0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.accessibility_new,
                    color: Color(0xFFB5976A), size: 28),
              ),
              const SizedBox(height: 4),
              const Text(
                'Nombre prenda',
                style:
                TextStyle(fontSize: 9, color: Color(0xFF9A8A75)),
              ),
              const Text(
                '\$98.000',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A3F30)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, -3)),
          ],
        ),
        child: ElevatedButton(
          onPressed: () => Navigator.pushNamed(context, '/chat'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFB5976A),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: const Text(
            'Chatear por esta publicación',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}