import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import 'create_product_screen.dart';

class MyProductsScreen extends StatelessWidget {
  const MyProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5EFE6),
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4A3F30)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Mis publicaciones',
            style: TextStyle(color: Color(0xFF4A3F30), fontSize: 18, fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFFB5976A)),
            tooltip: 'Nueva publicación',
            onPressed: () => Navigator.pushNamed(context, '/create-product'),
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: firestoreService.getProductsByVendedor(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFB5976A)));
          }
          final products = snapshot.data ?? [];
          if (products.isEmpty) {
            return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.storefront_outlined, size: 64,
                  color: const Color(0xFFB5976A).withOpacity(0.3)),
              const SizedBox(height: 16),
              const Text('Aún no has publicado nada',
                  style: TextStyle(color: Color(0xFF9A8A75), fontSize: 15)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/create-product'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB5976A),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Publicar algo'),
              ),
            ]));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(14),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.72,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) => _buildProductCard(context, products[index], firestoreService),
          );
        },
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Map<String, dynamic> product, FirestoreService svc) {
    final fotos = List<String>.from(product['fotos'] ?? []);
    final precio = (product['precio'] as num?)?.toDouble() ?? 0;

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/product-detail', arguments: product),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(
              color: const Color(0xFFB5976A).withOpacity(0.07),
              blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Stack(children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                child: fotos.isNotEmpty
                    ? Image.network(fotos.first, fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (_, __, ___) => Container(
                            color: const Color(0xFFE8D5C4),
                            child: const Icon(Icons.checkroom, color: Color(0xFFB5976A), size: 36)))
                    : Container(color: const Color(0xFFE8D5C4),
                        child: const Icon(Icons.checkroom, color: Color(0xFFB5976A), size: 36)),
              ),
              // Edit button overlay
              Positioned(
                top: 6, right: 6,
                child: GestureDetector(
                  onTap: () async {
                    await Navigator.push(context,
                        MaterialPageRoute(builder: (_) => CreateProductScreen(product: product)));
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
                    ),
                    child: const Icon(Icons.edit_outlined, size: 14, color: Color(0xFFB5976A)),
                  ),
                ),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(product['nombre'] as String? ?? '',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF4A3F30)),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text(
                '\$${precio.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFB5976A)),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}
