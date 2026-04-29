import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';
import '../services/firestore_service.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  String _formatPrice(double price) {
    return '\$${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5EFE6),
        elevation: 0,
        title: const Text(
          'Guardados',
          style: TextStyle(
              color: Color(0xFF4A3F30),
              fontSize: 20,
              fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: firestoreService.getSavedStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFB5976A)),
            );
          }

          final items = snapshot.data ?? [];

          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_border,
                      size: 72,
                      color: const Color(0xFFB5976A).withOpacity(0.3)),
                  const SizedBox(height: 16),
                  const Text(
                    'Aún no tienes guardados',
                    style: TextStyle(
                        color: Color(0xFF9A8A75),
                        fontSize: 16,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Guarda prendas para verlas más tarde',
                    style: TextStyle(
                        color: Color(0xFFB0A090), fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/explore'),
                    child: const Text('Explorar prendas',
                        style: TextStyle(color: Color(0xFFB5976A))),
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
              childAspectRatio: 0.72,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final fotos = List<String>.from(item['fotos'] ?? []);
              final precio =
                  (item['precio'] as num?)?.toDouble() ?? 0;

              return GestureDetector(
                onTap: () => Navigator.pushNamed(
                  context,
                  '/product-detail',
                  arguments: item,
                ),
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
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(16)),
                              child: fotos.isNotEmpty
                                  ? Image.network(
                                      fotos.first,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      errorBuilder: (_, __, ___) =>
                                          _placeholder(),
                                    )
                                  : _placeholder(),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['nombre'] as String? ?? '',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF4A3F30),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _formatPrice(precio),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFB5976A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // Botón de quitar guardado
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () async {
                            final productId = item['id'] as String?;
                            if (productId != null) {
                              await firestoreService
                                  .removeSaved(productId);
                            }
                          },
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4),
                              ],
                            ),
                            child: const Icon(Icons.bookmark,
                                color: Color(0xFFB5976A), size: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: const BottomNavWidget(currentIndex: 3),
    );
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xFFE8D5C4),
      child: Center(
        child: Icon(
          Icons.checkroom,
          size: 48,
          color: const Color(0xFFB5976A).withOpacity(0.4),
        ),
      ),
    );
  }
}