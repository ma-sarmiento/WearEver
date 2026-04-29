import 'package:flutter/material.dart';
import '../widgets/smart_back_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import 'create_product_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String? _selectedSize;
  bool _isSaved = false;
  bool _isLiked = false;
  int _currentImage = 0;
  bool _addingToCart = false;
  bool _isOwner = false;
  bool _loadingStates = true;

  // Reseñas
  int _myRating = 0;
  final TextEditingController _reviewCtrl = TextEditingController();
  bool _submittingReview = false;

  final _firestoreService = FirestoreService();
  Map<String, dynamic>? _product;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      _product = args;
      _loadStates();
    }
  }

  Future<void> _loadStates() async {
    final productId = _product?['id'] as String?;
    if (productId == null) return;
    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final vendorId = _product?['vendedor_id'] as String? ?? '';
    final saved = await _firestoreService.isProductSaved(productId);
    final liked = await _firestoreService.isProductLiked(productId);
    final myReview = await _firestoreService.getMyReview(productId);
    if (mounted) setState(() {
      _isOwner = currentUid == vendorId;
      _isSaved = saved;
      _isLiked = liked;
      _loadingStates = false;
      if (myReview != null) {
        _myRating = (myReview['rating'] as num?)?.toInt() ?? 0;
        _reviewCtrl.text = myReview['comment'] as String? ?? '';
      }
    });
  }

  @override
  void dispose() {
    _reviewCtrl.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFF5EFE6),
        title: const Text('Eliminar publicación',
            style: TextStyle(
                color: Color(0xFF4A3F30),
                fontSize: 16,
                fontWeight: FontWeight.w600)),
        content: const Text(
            '¿Estás seguro? Esta acción no se puede deshacer.',
            style: TextStyle(color: Color(0xFF9A8A75), fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar',
                style: TextStyle(color: Color(0xFF9A8A75))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar',
                style: TextStyle(
                    color: Colors.red, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final productId = _product?['id'] as String?;
      if (productId != null) {
        await _firestoreService.deleteProduct(productId);
      }
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _submitReview() async {
    final productId = _product?['id'] as String?;
    if (productId == null || _myRating == 0) return;
    setState(() => _submittingReview = true);
    await _firestoreService.submitReview(
      productId: productId,
      rating: _myRating,
      comment: _reviewCtrl.text.trim(),
    );
    if (mounted) {
      setState(() => _submittingReview = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reseña guardada ✓'),
          backgroundColor: Color(0xFFB5976A),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  String _formatPrice(double price) {
    return '\$${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  Future<void> _toggleSaved() async {
    if (_product == null) return;
    setState(() => _isSaved = !_isSaved);
    await _firestoreService.toggleSaved(_product!);
  }

  Future<void> _toggleLike() async {
    final productId = _product?['id'] as String?;
    if (productId == null) return;
    setState(() => _isLiked = !_isLiked);
    await _firestoreService.toggleLike(productId);
  }

  Future<void> _addToCart() async {
    final product = _product;
    if (product == null) return;
    final tallas = List<String>.from(product['tallas'] ?? []);
    if (tallas.isNotEmpty && _selectedSize == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona una talla antes de agregar al carrito'),
          backgroundColor: Color(0xFFD32F2F),
        ),
      );
      return;
    }
    setState(() => _addingToCart = true);
    try {
      await _firestoreService.addToCart(
        productId: product['id'] as String,
        nombre: product['nombre'] as String? ?? '',
        vendedorNombre: product['vendedor_nombre'] as String? ?? '',
        precio: (product['precio'] as num?)?.toDouble() ?? 0,
        talla: _selectedSize ?? (tallas.isNotEmpty ? tallas.first : 'Única'),
        fotos: List<String>.from(product['fotos'] ?? []),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Agregado al carrito ✓'),
            backgroundColor: Color(0xFF4CAF50),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: const Color(0xFFD32F2F),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _addingToCart = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = _product;
    if (product == null || _loadingStates) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5EFE6),
        body: Center(child: CircularProgressIndicator(color: Color(0xFFB5976A))),
      );
    }

    final fotos = List<String>.from(product['fotos'] ?? []);
    final tallas = List<String>.from(product['tallas'] ?? []);
    final precio = (product['precio'] as num?)?.toDouble() ?? 0;
    final nombre = product['nombre'] as String? ?? '';
    final descripcion = product['descripcion'] as String? ?? '';
    final categoria = product['categoria'] as String? ?? '';
    final vendedorNombre = product['vendedor_nombre'] as String? ?? '';
    final vendedorId = product['vendedor_id'] as String? ?? '';
    final productId = product['id'] as String? ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildSliverAppBar(fotos, vendedorNombre, vendedorId),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (categoria.isNotEmpty) ...[
                        _buildTag(categoria),
                        const SizedBox(height: 14),
                      ],
                      _buildTitleAndPrice(nombre, tallas, precio),
                      if (tallas.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        _buildSizeSelector(tallas),
                      ],
                      const SizedBox(height: 20),
                      _buildActionButtons(),
                      const SizedBox(height: 20),
                      _buildDescription(descripcion),
                      const SizedBox(height: 20),
                      _buildReviewsSection(productId),
                    ],
                  ),
                ),
              ),
            ],
          ),
          _buildBottomBar(vendedorId),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(
      List<String> fotos, String vendedorNombre, String vendedorId) {
    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,
      backgroundColor: const Color(0xFFF5EFE6),
      elevation: 0,
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
            // Imagen principal
            fotos.isNotEmpty
                ? PageView.builder(
              itemCount: fotos.length,
              onPageChanged: (i) =>
                  setState(() => _currentImage = i),
              itemBuilder: (context, i) => Image.network(
                fotos[i],
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFFE8D5C4),
                  child: Center(
                    child: Icon(Icons.checkroom,
                        size: 80,
                        color: const Color(0xFFB5976A).withOpacity(0.3)),
                  ),
                ),
              ),
            )
                : Container(
              color: const Color(0xFFE8D5C4),
              child: Center(
                child: Icon(Icons.checkroom,
                    size: 120,
                    color: const Color(0xFFB5976A).withOpacity(0.3)),
              ),
            ),
            // Vendedor overlay
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
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/seller-profile',
                      arguments: {'vendedor_id': vendedorId},
                    ),
                    child: Text(
                      vendedorNombre,
                      style: const TextStyle(
                        color: Color(0xFF4A3F30),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (!_isOwner)
                    _buildSellerButton('Chat', Colors.white,
                        textColor: const Color(0xFFB5976A), bordered: true,
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/chat',
                          arguments: {'other_uid': vendedorId},
                        )),
                ],
              ),
            ),
            // Dots de imágenes
            if (fotos.length > 1)
              Positioned(
                bottom: 12,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    fotos.length,
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
          ],
        ),
      ),
    );
  }

  Widget _buildSellerButton(String label, Color bgColor,
      {Color textColor = Colors.white,
        bool bordered = false,
        VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: bordered ? Border.all(color: const Color(0xFFB5976A)) : null,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.1), blurRadius: 4),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
              color: textColor, fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFB5976A).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFB5976A).withOpacity(0.3)),
      ),
      child: Text(
        tag,
        style: const TextStyle(
            fontSize: 11,
            color: Color(0xFFB5976A),
            fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildTitleAndPrice(
      String nombre, List<String> tallas, double precio) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nombre,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A3F30),
                ),
              ),
              const SizedBox(height: 2),
              if (tallas.isNotEmpty)
                Text(
                  tallas.join(' • '),
                  style: const TextStyle(
                      fontSize: 13, color: Color(0xFF9A8A75)),
                ),
            ],
          ),
        ),
        Text(
          _formatPrice(precio),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFFB5976A),
          ),
        ),
      ],
    );
  }

  Widget _buildSizeSelector(List<String> tallas) {
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
        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: tallas.map((size) {
            final isSelected = _selectedSize == size;
            return GestureDetector(
              onTap: () => setState(() => _selectedSize = size),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
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
    if (_isOwner) return const SizedBox.shrink();

    return Row(
      children: [
        _buildIconAction(
          icon: _isSaved ? Icons.bookmark : Icons.bookmark_border,
          isActive: _isSaved,
          onTap: _isOwner ? () {} : _toggleSaved,
        ),
        const SizedBox(width: 10),
        _buildIconAction(
          icon: _isLiked ? Icons.favorite : Icons.favorite_border,
          isActive: _isLiked,
          onTap: _isOwner ? () {} : _toggleLike,
        ),
        const SizedBox(width: 12),
        if (!_isOwner)
          Expanded(
            child: ElevatedButton(
              onPressed: _addingToCart ? null : _addToCart,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB5976A),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: _addingToCart
                  ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
                  : const Text('Agregar al carrito',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
            ),
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

  Widget _buildDescription(String descripcion) {
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
        children: [
          const Text('Descripción',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4A3F30))),
          const SizedBox(height: 8),
          Text(
            descripcion.isNotEmpty
                ? descripcion
                : 'Sin descripción disponible.',
            style: const TextStyle(
                fontSize: 13, color: Color(0xFF7A6A55), height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(String vendedorId) {
    if (_isOwner) {
      return Positioned(
        bottom: 0, left: 0, right: 0,
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
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            CreateProductScreen(product: _product),
                      ),
                    );
                    // Recargar datos actualizados desde Firestore
                    final productId = _product?['id'] as String?;
                    if (productId != null && mounted) {
                      final updated = await _firestoreService
                          .getProductById(productId);
                      if (updated != null && mounted) {
                        setState(() => _product = updated);
                      }
                    }
                  },
                  icon: const Icon(Icons.edit_outlined,
                      color: Color(0xFFB5976A), size: 18),
                  label: const Text('Editar',
                      style: TextStyle(
                          color: Color(0xFFB5976A),
                          fontWeight: FontWeight.w600,
                          fontSize: 15)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFB5976A)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: _confirmDelete,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(
                      vertical: 14, horizontal: 18),
                ),
                child: const Icon(Icons.delete_outline,
                    color: Colors.red, size: 22),
              ),
            ],
          ),
        ),
      );
    }
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
          onPressed: () => Navigator.pushNamed(
            context,
            '/chat',
            arguments: {'other_uid': vendedorId},
          ),
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

  Widget _buildReviewsSection(String productId) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final vendorId = _product?['vendedor_id'] as String? ?? '';
    final isOwner = currentUid == vendorId;

    return Container(
      padding: const EdgeInsets.all(16),
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
          // Encabezado con promedio
          StreamBuilder<Map<String, dynamic>>(
            stream: _firestoreService.getReviewsSummaryStream(productId),
            builder: (context, snapshot) {
              final avg = (snapshot.data?['avg'] as double?) ?? 0.0;
              final count = (snapshot.data?['count'] as int?) ?? 0;
              return Row(
                children: [
                  const Text('Reseñas',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4A3F30))),
                  const Spacer(),
                  if (count > 0) ...[
                    Icon(Icons.star_rounded,
                        color: const Color(0xFFB5976A), size: 18),
                    const SizedBox(width: 4),
                    Text(
                      avg.toStringAsFixed(1),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A3F30),
                          fontSize: 14),
                    ),
                    Text('  ($count)',
                        style: const TextStyle(
                            color: Color(0xFF9A8A75), fontSize: 12)),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: 14),

          // Formulario para escribir reseña (solo si no es el dueño)
          if (!isOwner) ...[
            const Text('Tu calificación',
                style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF7A6A55),
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Row(
              children: List.generate(5, (i) {
                final star = i + 1;
                return GestureDetector(
                  onTap: () => setState(() => _myRating = star),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Icon(
                      star <= _myRating
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: const Color(0xFFB5976A),
                      size: 32,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _reviewCtrl,
              style: const TextStyle(
                  color: Color(0xFF4A3F30), fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Escribe tu reseña (opcional)...',
                hintStyle: const TextStyle(
                    color: Color(0xFFB0A090), fontSize: 13),
                filled: true,
                fillColor: const Color(0xFFF5EFE6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                (_myRating == 0 || _submittingReview) ? null : _submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB5976A),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                  const Color(0xFFB5976A).withOpacity(0.3),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 11),
                ),
                child: _submittingReview
                    ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                    : const Text('Publicar reseña',
                    style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(color: Color(0xFFF0E6D4)),
            const SizedBox(height: 8),
          ],

          // Lista de reseñas
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: _firestoreService.getReviewsStream(productId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(
                          color: Color(0xFFB5976A), strokeWidth: 2),
                    ));
              }
              final reviews = snapshot.data ?? [];
              if (reviews.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('Sé el primero en reseñar este producto.',
                      style: TextStyle(
                          color: Color(0xFF9A8A75), fontSize: 13)),
                );
              }
              return Column(
                children: reviews.map((r) => _buildReviewTile(r)).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReviewTile(Map<String, dynamic> review) {
    final rating = (review['rating'] as num?)?.toInt() ?? 0;
    final comment = review['comment'] as String? ?? '';
    final authorName = review['author_name'] as String? ?? 'Usuario';
    final ts = review['created_at'];
    String dateStr = '';
    if (ts != null) {
      try {
        final dt = (ts as dynamic).toDate() as DateTime;
        dateStr = '${dt.day}/${dt.month}/${dt.year}';
      } catch (_) {}
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFFB5976A).withOpacity(0.15),
            child: Text(
              authorName.isNotEmpty ? authorName[0].toUpperCase() : '?',
              style: const TextStyle(
                  color: Color(0xFFB5976A),
                  fontWeight: FontWeight.bold,
                  fontSize: 13),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(authorName,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4A3F30))),
                    const Spacer(),
                    if (dateStr.isNotEmpty)
                      Text(dateStr,
                          style: const TextStyle(
                              fontSize: 11, color: Color(0xFFB0A090))),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: List.generate(
                    5,
                        (i) => Icon(
                      i < rating
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: const Color(0xFFB5976A),
                      size: 14,
                    ),
                  ),
                ),
                if (comment.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(comment,
                      style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF7A6A55),
                          height: 1.4)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}