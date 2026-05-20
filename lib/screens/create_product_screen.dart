import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/storage_service.dart';
import '../services/ai_service.dart';

class CreateProductScreen extends StatefulWidget {
  /// Si se pasa un producto existente, la pantalla funciona en modo edición.
  final Map<String, dynamic>? product;
  const CreateProductScreen({super.key, this.product});

  @override
  State<CreateProductScreen> createState() => _CreateProductScreenState();
}

class _CreateProductScreenState extends State<CreateProductScreen> {
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _precioController = TextEditingController();

  final List<File> _newPhotos = [];       // fotos nuevas elegidas del dispositivo
  List<String> _existingPhotoUrls = [];  // fotos ya subidas (modo edición)
  final Set<String> _selectedTallas = {};
  String? _selectedCategoria;
  bool _isLoading = false;

  bool get _isEditing => widget.product != null;

  static const _categorias = [
    'Streetwear', 'Vintage', 'Deportivo', 'Casual',
    'Elegante', 'Formal', 'Minimalista', 'Sostenible',
    'Accesorios', 'Zapatos',
  ];

  static const _tallas = ['XS', 'S', 'M', 'L', 'XL', 'Unisex'];

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final p = widget.product!;
      _nombreController.text = p['nombre'] as String? ?? '';
      _descripcionController.text = p['descripcion'] as String? ?? '';
      _precioController.text =
          ((p['precio'] as num?)?.toDouble() ?? 0).toStringAsFixed(0);
      _selectedCategoria = p['categoria'] as String?;
      _existingPhotoUrls =
      List<String>.from(p['fotos'] ?? []);
      _selectedTallas.addAll(
          List<String>.from(p['tallas'] ?? []));
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _precioController.dispose();
    super.dispose();
  }

  int get _totalPhotos => _existingPhotoUrls.length + _newPhotos.length;

  Future<void> _pickPhoto() async {
    if (_totalPhotos >= 3) return;
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1080,
    );
    if (picked != null && mounted) {
      final file = File(picked.path);
      setState(() => _newPhotos.add(file));
      _scanAndShowResult(file);
    }
  }

  Future<void> _scanAndShowResult(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final base64Image = base64Encode(bytes);
      final result = await AiService().scanPrenda(base64Image);
      if (mounted) _showScanResultSheet(result);
    } catch (_) {
      // scan falla silenciosamente, el usuario puede publicar igual
    }
  }

  void _showScanResultSheet(Map<String, dynamic> result) {
    final grado = result['grado'] as String? ?? 'B';
    final descripcion = result['descripcion'] as String? ?? '';
    final recomendacion = result['recomendacion'] as String? ?? 'Donar';
    final puntaje = (result['puntaje'] as num?)?.toInt() ?? 50;

    final Color gradeColor;
    final String gradeEmoji;
    final String gradeMessage;

    switch (grado) {
      case 'A':
        gradeColor = const Color(0xFF2E7D32);
        gradeEmoji = '🟢';
        gradeMessage = '¡Perfecta para vender!';
        break;
      case 'C':
        gradeColor = const Color(0xFFD32F2F);
        gradeEmoji = '🔴';
        gradeMessage = 'Llévala a un punto de reciclaje';
        break;
      default:
        gradeColor = const Color(0xFFF57F17);
        gradeEmoji = '🟡';
        gradeMessage = 'Te recomendamos donarla a una ONG';
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0D0BC),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(gradeEmoji, style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Grado $grado — $recomendacion',
                        style: TextStyle(
                          color: gradeColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Puntaje: $puntaje / 100',
                        style: const TextStyle(
                            color: Color(0xFF9A8A75), fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                descripcion,
                style: const TextStyle(
                    color: Color(0xFF4A3F30), fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: gradeColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: gradeColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  gradeMessage,
                  style: TextStyle(
                    color: gradeColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              if (grado == 'B') ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.pushNamed(context, '/ong');
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFF57F17)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Ver ONGs',
                        style: TextStyle(color: Color(0xFFF57F17))),
                  ),
                ),
              ],
              if (grado == 'C') ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.pushNamed(context, '/map');
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFD32F2F)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Ver mapa',
                        style: TextStyle(color: Color(0xFFD32F2F))),
                  ),
                ),
              ],
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Continuar publicando',
                      style: TextStyle(color: Color(0xFF9A8A75))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    final nombre = _nombreController.text.trim();
    final descripcion = _descripcionController.text.trim();
    final precioStr = _precioController.text.trim();

    if (nombre.isEmpty || descripcion.isEmpty ||
        precioStr.isEmpty || _selectedCategoria == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa todos los campos obligatorios.'),
          backgroundColor: Color(0xFFD32F2F),
        ),
      );
      return;
    }

    final precio = double.tryParse(precioStr.replaceAll(',', '.'));
    if (precio == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El precio debe ser un número válido.'),
          backgroundColor: Color(0xFFD32F2F),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      final db = FirebaseFirestore.instance;
      final storageService = StorageService();

      if (_isEditing) {
        // ── MODO EDICIÓN ──────────────────────────────
        final productId = widget.product!['id'] as String;

        // Subir fotos nuevas si las hay
        final List<String> newUrls = [];
        for (final photo in _newPhotos) {
          final url = await storageService.uploadProductPhoto(photo, productId);
          newUrls.add(url);
        }

        await db.collection('products').doc(productId).update({
          'nombre': nombre,
          'descripcion': descripcion,
          'precio': precio,
          'categoria': _selectedCategoria,
          'tallas': _tallas.where((t) => _selectedTallas.contains(t)).toList(),
          'fotos': [..._existingPhotoUrls, ...newUrls],
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Publicación actualizada ✓'),
              backgroundColor: Color(0xFFB5976A),
            ),
          );
          Navigator.pop(context);
        }
      } else {
        // ── MODO CREAR ────────────────────────────────
        final userDoc = await db.collection('users').doc(uid).get();
        final userData = userDoc.data();
        final vendedorNombre =
        '${userData?['nombre'] ?? ''} ${userData?['apellido'] ?? ''}'
            .trim();
        final vendedorFoto = userData?['foto_perfil'] as String? ?? '';

        final docRef = db.collection('products').doc();
        final productId = docRef.id;

        final List<String> fotosUrls = [];
        for (final photo in _newPhotos) {
          final url = await storageService.uploadProductPhoto(photo, productId);
          fotosUrls.add(url);
        }

        await docRef.set({
          'nombre': nombre,
          'descripcion': descripcion,
          'precio': precio,
          'categoria': _selectedCategoria,
          'tallas': _tallas.where((t) => _selectedTallas.contains(t)).toList(),
          'fotos': fotosUrls,
          'vendedor_id': uid,
          'vendedor_nombre':
          vendedorNombre.isEmpty ? 'Vendedor' : vendedorNombre,
          'vendedor_foto': vendedorFoto,
          'created_at': FieldValue.serverTimestamp(),
          'activo': true,
        });

        if (mounted) Navigator.pushReplacementNamed(context, '/home');
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
        title: Text(
          _isEditing ? 'Editar publicación' : 'Nueva publicación',
          style: const TextStyle(
              color: Color(0xFF4A3F30),
              fontSize: 18,
              fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _save,
            child: Text(
              _isEditing ? 'Guardar' : 'Publicar',
              style: const TextStyle(
                  color: Color(0xFFB5976A),
                  fontWeight: FontWeight.w600,
                  fontSize: 15),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
          child: CircularProgressIndicator(color: Color(0xFFB5976A)))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPhotoSection(),
            const SizedBox(height: 20),
            _buildField('Nombre', _nombreController,
                hint: 'Ej: Chaqueta de cuero negra'),
            const SizedBox(height: 14),
            _buildField('Descripción', _descripcionController,
                hint: 'Cuéntanos sobre la prenda...', maxLines: 4),
            const SizedBox(height: 14),
            _buildField('Precio (COP)', _precioController,
                hint: 'Ej: 85000',
                keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            _buildCategorySelector(),
            const SizedBox(height: 20),
            _buildSizeSelector(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Fotos (máx. 3)',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4A3F30))),
        const SizedBox(height: 10),
        SizedBox(
          height: 110,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              // Fotos existentes (modo edición)
              ..._existingPhotoUrls.asMap().entries.map((e) => _existingPhotoThumb(e.key, e.value)),
              // Fotos nuevas
              ..._newPhotos.asMap().entries.map((e) => _newPhotoThumb(e.key, e.value)),
              // Botón agregar
              if (_totalPhotos < 3) _addPhotoButton(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _existingPhotoThumb(int index, String url) {
    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          margin: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
                image: NetworkImage(url), fit: BoxFit.cover),
          ),
        ),
        Positioned(
          top: 4, right: 14,
          child: GestureDetector(
            onTap: () =>
                setState(() => _existingPhotoUrls.removeAt(index)),
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                  color: Colors.black54, shape: BoxShape.circle),
              child: const Icon(Icons.close,
                  color: Colors.white, size: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _newPhotoThumb(int index, File file) {
    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          margin: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
                image: FileImage(file), fit: BoxFit.cover),
          ),
        ),
        Positioned(
          top: 4, right: 14,
          child: GestureDetector(
            onTap: () => setState(() => _newPhotos.removeAt(index)),
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                  color: Colors.black54, shape: BoxShape.circle),
              child: const Icon(Icons.close,
                  color: Colors.white, size: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _addPhotoButton() {
    return GestureDetector(
      onTap: _pickPhoto,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: const Color(0xFFE0D0BC), width: 1.5),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo_outlined,
                color: Color(0xFFB5976A), size: 28),
            SizedBox(height: 6),
            Text('Agregar',
                style: TextStyle(
                    color: Color(0xFF9A8A75), fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller,
      {String hint = '', int maxLines = 1,
        TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4A3F30))),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(
              color: Color(0xFF4A3F30), fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
                color: Color(0xFFB0A090), fontSize: 14),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Categoría',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4A3F30))),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _categorias.map((cat) {
            final sel = _selectedCategoria == cat;
            return GestureDetector(
              onTap: () =>
                  setState(() => _selectedCategoria = cat),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: sel
                      ? const Color(0xFF3D3025)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: sel
                          ? const Color(0xFF3D3025)
                          : const Color(0xFFE0D0BC)),
                ),
                child: Text(cat,
                    style: TextStyle(
                        color: sel
                            ? Colors.white
                            : const Color(0xFF4A3F30),
                        fontSize: 13,
                        fontWeight: FontWeight.w500)),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSizeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tallas disponibles',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4A3F30))),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _tallas.map((talla) {
            final sel = _selectedTallas.contains(talla);
            return GestureDetector(
              onTap: () => setState(() {
                if (sel) {
                  _selectedTallas.remove(talla);
                } else {
                  _selectedTallas.add(talla);
                }
              }),
              child: Container(
                width: 52,
                height: 40,
                decoration: BoxDecoration(
                  color: sel
                      ? const Color(0xFFB5976A)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: sel
                          ? const Color(0xFFB5976A)
                          : const Color(0xFFE0D0BC)),
                ),
                child: Center(
                  child: Text(talla,
                      style: TextStyle(
                          color: sel
                              ? Colors.white
                              : const Color(0xFF4A3F30),
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}