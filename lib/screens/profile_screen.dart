import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/bottom_nav.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import 'image_crop_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _firestoreService = FirestoreService();
  final _currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';

  String _nombre = '';
  String _username = '';
  String _fotoPerfilUrl = '';
  List<String> _savedStyles = [];
  int _compras = 0, _ventas = 0, _seguidores = 0, _seguidos = 0;
  bool _loadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadStats();
  }

  Future<void> _loadUserData() async {
    final data = await AuthService().getUserData();
    if (mounted && data != null) {
      setState(() {
        _nombre = '${data['nombre'] ?? ''} ${data['apellido'] ?? ''}'.trim();
        _username = '@${data['username'] ?? ''}';
        _fotoPerfilUrl = data['foto_perfil'] as String? ?? '';
        _savedStyles = List<String>.from(data['gustos_estilos'] ?? []);
      });
    }
  }

  Future<void> _loadStats() async {
    final stats = await _firestoreService.getUserStats();
    if (mounted) {
      setState(() {
        _compras = stats['compras'] ?? 0;
        _ventas = stats['ventas'] ?? 0;
        _seguidores = stats['seguidores'] ?? 0;
        _seguidos = stats['seguidos'] ?? 0;
        _loadingStats = false;
      });
    }
  }

  Future<void> _pickAndUploadPhoto() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
          source: ImageSource.gallery, imageQuality: 90);
      if (picked == null || !mounted) return;

      // Abrir pantalla de recorte estilo WhatsApp
      final croppedFile = await Navigator.push<File>(
        context,
        MaterialPageRoute(
          builder: (_) => ImageCropScreen(imageFile: File(picked.path)),
          fullscreenDialog: true,
        ),
      );
      if (croppedFile == null || !mounted) return;

      // Subir la imagen recortada
      final url = await StorageService().uploadProfilePhoto(croppedFile);
      if (url != null && mounted) {
        await _firestoreService.updateUserField('foto_perfil', url);
        // Propagar la nueva foto a todas las publicaciones del usuario
        await _firestoreService.updateVendorPhotoInProducts(url);
        setState(() => _fotoPerfilUrl = url);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error al actualizar foto: $e'),
            backgroundColor: const Color(0xFFD32F2F)));
      }
    }
  }

  Future<void> _handleLogout() async {
    await AuthService().logoutUser();
    if (mounted) Navigator.pushReplacementNamed(context, '/');
  }

  void _openFollowList(String mode) {
    Navigator.pushNamed(context, '/followers',
        arguments: {'mode': mode, 'uid': _currentUid});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5EFE6),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Perfil',
            style: TextStyle(
                color: Color(0xFF4A3F30),
                fontSize: 20,
                fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined,
                color: Color(0xFF9A8A75)),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 16),
            _buildStats(),
            const SizedBox(height: 16),
            _buildStylesCard(),
            const SizedBox(height: 16),
            _buildMenuList(),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavWidget(currentIndex: 4),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        SizedBox(
          height: 170,
          child: Stack(clipBehavior: Clip.none, children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 110,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF8B7355), Color(0xFF6B5B45)],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: _pickAndUploadPhoto,
                  child: Stack(children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFE8D5C4),
                        border: Border.all(
                            color: const Color(0xFFC4A882), width: 3),
                        boxShadow: [
                          BoxShadow(
                              color:
                              const Color(0xFFB5976A).withOpacity(0.25),
                              blurRadius: 14,
                              offset: const Offset(0, 5))
                        ],
                      ),
                      child: ClipOval(
                        child: _fotoPerfilUrl.isNotEmpty
                            ? Image.network(
                          _fotoPerfilUrl,
                          fit: BoxFit.cover,
                          // Fuerza recarga si la URL cambia (el timestamp en el nombre
                          // del archivo garantiza que siempre sea una URL nueva)
                          errorBuilder: (_, __, ___) => const Icon(
                              Icons.person,
                              color: Color(0xFFB5976A),
                              size: 40),
                        )
                            : const Icon(Icons.person,
                            color: Color(0xFFB5976A), size: 40),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                            color: Color(0xFFB5976A),
                            shape: BoxShape.circle),
                        child: const Icon(Icons.edit,
                            color: Colors.white, size: 14),
                      ),
                    ),
                  ]),
                ),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 12),
        Text(
          _nombre.isEmpty ? 'Cargando...' : _nombre,
          style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A3F30)),
        ),
        const SizedBox(height: 2),
        Text(_username,
            style:
            const TextStyle(fontSize: 13, color: Color(0xFF9A8A75))),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFFB5976A).withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 3))
          ],
        ),
        child: _loadingStats
            ? const Center(
            child: SizedBox(
                height: 40,
                child: CircularProgressIndicator(
                    color: Color(0xFFB5976A), strokeWidth: 2)))
            : Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatItem('Seguidores', '$_seguidores',
                onTap: () => _openFollowList('followers')),
            _buildDivider(),
            _buildStatItem('Seguidos', '$_seguidos',
                onTap: () => _openFollowList('following')),
            _buildDivider(),
            _buildStatItem('Compras', '$_compras'),
            _buildDivider(),
            _buildStatItem('Publicaciones', '$_ventas'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value,
      {VoidCallback? onTap}) {
    final content = Column(children: [
      Text(value,
          style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A3F30))),
      const SizedBox(height: 2),
      Text(label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF9A8A75))),
    ]);
    if (onTap == null) return content;
    return GestureDetector(onTap: onTap, child: content);
  }

  Widget _buildDivider() =>
      Container(width: 1, height: 36, color: const Color(0xFFE0D0BC));

  Widget _buildStylesCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFFB5976A).withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 3))
          ],
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Mis estilos',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4A3F30))),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(
                          context, '/style-selector')
                          .then((_) => _loadUserData()),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                            color:
                            const Color(0xFFB5976A).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8)),
                        child: const Row(children: [
                          Icon(Icons.edit_outlined,
                              size: 13, color: Color(0xFFB5976A)),
                          SizedBox(width: 4),
                          Text('Editar',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFFB5976A),
                                  fontWeight: FontWeight.w500)),
                        ]),
                      ),
                    ),
                  ]),
              const SizedBox(height: 12),
              _savedStyles.isEmpty
                  ? GestureDetector(
                onTap: () =>
                    Navigator.pushNamed(context, '/style-selector'),
                child: Container(
                  width: double.infinity,
                  padding:
                  const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: const Color(0xFFB5976A)
                              .withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(10)),
                  child: const Center(
                    child: Text('+ Seleccionar estilos',
                        style: TextStyle(
                            color: Color(0xFFB5976A),
                            fontSize: 13,
                            fontWeight: FontWeight.w500)),
                  ),
                ),
              )
                  : Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _savedStyles
                    .map((style) => Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB5976A)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: const Color(0xFFB5976A)
                            .withOpacity(0.3)),
                  ),
                  child: Text(style,
                      style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFB5976A),
                          fontWeight: FontWeight.w500)),
                ))
                    .toList(),
              ),
            ]),
      ),
    );
  }

  Widget _buildMenuList() {
    final items = [
      {
        'icon': Icons.receipt_long_outlined,
        'label': 'Mis pedidos',
        'route': '/orders',
        'danger': false
      },
      {
        'icon': Icons.storefront_outlined,
        'label': 'Mis ventas',
        'route': '/my-sales',
        'danger': false
      },
      {
        'icon': Icons.bookmark_outline,
        'label': 'Favoritos',
        'route': '/saved',
        'danger': false
      },
      {
        'icon': Icons.grid_view_outlined,
        'label': 'Mis publicaciones',
        'route': '/my-products',
        'danger': false
      },
      {
        'icon': Icons.credit_card_outlined,
        'label': 'Métodos de pago',
        'route': '/payment-methods',
        'danger': false
      },
      {
        'icon': Icons.location_on_outlined,
        'label': 'Mis direcciones',
        'route': '/addresses',
        'danger': false
      },
      {
        'icon': Icons.logout,
        'label': 'Cerrar sesión',
        'route': '',
        'danger': true
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFFB5976A).withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 3))
          ],
        ),
        child: Column(
          children: items.asMap().entries.map((e) {
            final i = e.key;
            final item = e.value;
            final isDanger = item['danger'] as bool;
            final route = item['route'] as String;
            return Column(children: [
              GestureDetector(
                onTap: () {
                  if (isDanger) {
                    _handleLogout();
                  } else if (route.isNotEmpty) {
                    Navigator.pushNamed(context, route);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  child: Row(children: [
                    Icon(item['icon'] as IconData,
                        size: 22,
                        color: isDanger
                            ? const Color(0xFFD32F2F)
                            : const Color(0xFF7A6A55)),
                    const SizedBox(width: 14),
                    Expanded(
                        child: Text(item['label'] as String,
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isDanger
                                    ? const Color(0xFFD32F2F)
                                    : const Color(0xFF4A3F30)))),
                    Icon(Icons.chevron_right,
                        size: 18,
                        color: isDanger
                            ? const Color(0xFFD32F2F).withOpacity(0.5)
                            : const Color(0xFFB0A090)),
                  ]),
                ),
              ),
              if (i < items.length - 1)
                const Divider(
                    height: 1,
                    color: Color(0xFFF0E6D4),
                    indent: 52),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}