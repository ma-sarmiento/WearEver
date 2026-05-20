import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/bottom_nav.dart';
import '../services/firestore_service.dart';

// ─────────────────────────────────────────────────────────────
// Pantalla principal: lista de ONGs de la colección 'ongs'
// ─────────────────────────────────────────────────────────────
class OngScreen extends StatelessWidget {
  const OngScreen({super.key});

  Stream<List<Map<String, dynamic>>> _ongsStream() {
    return FirebaseFirestore.instance
        .collection('ongs')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5EFE6),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Fundaciones',
          style: TextStyle(
              color: Color(0xFF4A3F30),
              fontSize: 20,
              fontWeight: FontWeight.w600),
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _ongsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFFB5976A)));
          }

          final ongs = snapshot.data ?? [];

          if (ongs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.volunteer_activism,
                      size: 64,
                      color: const Color(0xFFB5976A).withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  const Text(
                    'Aún no hay fundaciones registradas',
                    style: TextStyle(color: Color(0xFF9A8A75), fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () =>
                        Navigator.pushNamed(context, '/register-ong'),
                    child: const Text(
                      '¿Tienes una fundación? Regístrala aquí',
                      style: TextStyle(
                          color: Color(0xFFB5976A),
                          fontSize: 13,
                          decoration: TextDecoration.underline),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: ongs.length,
            itemBuilder: (context, index) =>
                _OngCard(ong: ongs[index]),
          );
        },
      ),
      bottomNavigationBar: const BottomNavWidget(currentIndex: 3),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Tarjeta de ONG en la lista
// ─────────────────────────────────────────────────────────────
class _OngCard extends StatelessWidget {
  final Map<String, dynamic> ong;
  const _OngCard({required this.ong});

  @override
  Widget build(BuildContext context) {
    // La colección 'ongs' usa 'nombre_fundacion' como campo de nombre
    final nombre = ong['nombre_fundacion'] as String? ?? 'ONG';
    final descripcion = ong['descripcion'] as String? ?? '';
    final ciudad = ong['ciudad'] as String? ?? '';
    final verificada = ong['verificada'] as bool? ?? false;
    final id = ong['id'] as String? ?? '';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => OngDetailScreen(ongId: id, ongData: ong)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFB5976A).withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFE8D5C4),
                shape: BoxShape.circle,
                border: Border.all(
                    color: const Color(0xFFB5976A).withValues(alpha: 0.3), width: 2),
              ),
              child: const Center(
                child: Icon(Icons.volunteer_activism,
                    color: Color(0xFFB5976A), size: 26),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(nombre,
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF4A3F30))),
                      ),
                      if (verificada)
                        const Icon(Icons.verified,
                            color: Color(0xFFB5976A), size: 16),
                    ],
                  ),
                  if (descripcion.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(descripcion,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF7A6A55),
                            height: 1.4)),
                  ],
                  if (ciudad.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(children: [
                      const Icon(Icons.location_on_outlined,
                          size: 13, color: Color(0xFFB5976A)),
                      const SizedBox(width: 3),
                      Text(ciudad,
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF9A8A75))),
                    ]),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Color(0xFFB0A090), size: 20),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Pantalla de detalle de una ONG
// ─────────────────────────────────────────────────────────────
class OngDetailScreen extends StatefulWidget {
  final String ongId;
  final Map<String, dynamic> ongData;
  const OngDetailScreen({super.key, required this.ongId, required this.ongData});

  @override
  State<OngDetailScreen> createState() => _OngDetailScreenState();
}

class _OngDetailScreenState extends State<OngDetailScreen> {
  final _firestoreService = FirestoreService();
  final _currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';

  // La ONG tiene un uid asociado si se registró via Auth
  // Usamos el campo 'uid' si existe, sino el id del documento
  late String _ongUid;

  int _seguidores = 0;
  int _seguidos = 0;
  bool _isFollowing = false;
  bool _togglingFollow = false;
  bool _loadingStats = true;

  String get _nombre =>
      widget.ongData['nombre_fundacion'] as String? ?? 'ONG';
  String get _descripcion =>
      widget.ongData['descripcion'] as String? ?? '';
  String get _ciudad => widget.ongData['ciudad'] as String? ?? '';
  String get _email => widget.ongData['email'] as String? ?? '';
  String get _representante =>
      widget.ongData['representante_legal'] as String? ?? '';
  String get _telefono => widget.ongData['telefono'] as String? ?? '';
  String get _nit => widget.ongData['nit'] as String? ?? '';
  bool get _verificada => widget.ongData['verificada'] as bool? ?? false;

  @override
  void initState() {
    super.initState();
    // Si la ONG tiene uid propio (registrada via Auth), úsalo para followers
    _ongUid = widget.ongData['uid'] as String? ?? widget.ongId;
    _loadStats();
  }

  Future<void> _loadStats() async {
    final seguidores = await _firestoreService.getFollowersCount(_ongUid);
    final seguidos = await _firestoreService.getFollowingCount(_ongUid);
    bool isFollowing = false;
    if (_ongUid != _currentUid) {
      isFollowing = await _firestoreService.isFollowing(_ongUid);
    }
    if (mounted) {
      setState(() {
        _seguidores = seguidores;
        _seguidos = seguidos;
        _isFollowing = isFollowing;
        _loadingStats = false;
      });
    }
  }

  Future<void> _toggleFollow() async {
    setState(() => _togglingFollow = true);
    if (_isFollowing) {
      await _firestoreService.unfollowUser(_ongUid);
    } else {
      await _firestoreService.followUser(_ongUid);
    }
    final newCount = await _firestoreService.getFollowersCount(_ongUid);
    if (mounted) {
      setState(() {
        _isFollowing = !_isFollowing;
        _seguidores = newCount;
        _togglingFollow = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      bottomNavigationBar: const BottomNavWidget(currentIndex: 3),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStats(),
                  const SizedBox(height: 16),
                  _buildInfoCard(),
                  const SizedBox(height: 16),
                  _buildPostsSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    final isMe = _ongUid == _currentUid;
    return SliverAppBar(
      expandedHeight: 160,
      pinned: true,
      backgroundColor: const Color(0xFFF5EFE6),
      elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            Container(
              height: 130,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  const Color(0xFF8B7355).withValues(alpha: 0.6),
                  const Color(0xFF6B5B45).withValues(alpha: 0.4),
                ]),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 16,
              right: 16,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Avatar / logo
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8D5C4),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 8),
                      ],
                    ),
                    child: const Icon(Icons.volunteer_activism,
                        color: Color(0xFFB5976A), size: 34),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(children: [
                          Expanded(
                            child: Text(_nombre,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xFF4A3F30))),
                          ),
                          if (_verificada)
                            const Padding(
                              padding: EdgeInsets.only(left: 4),
                              child: Icon(Icons.verified,
                                  color: Color(0xFFB5976A), size: 16),
                            ),
                        ]),
                        if (_ciudad.isNotEmpty)
                          Text(_ciudad,
                              style: const TextStyle(
                                  color: Color(0xFF9A8A75), fontSize: 12)),
                      ],
                    ),
                  ),
                  // Acciones: solo si no es la propia ONG
                  if (!isMe) ...[
                    GestureDetector(
                      onTap: _togglingFollow ? null : _toggleFollow,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: _isFollowing
                              ? Colors.transparent
                              : const Color(0xFFB5976A),
                          border: Border.all(
                            color: _isFollowing
                                ? const Color(0xFFB5976A)
                                : Colors.transparent,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: _togglingFollow
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                    color: Color(0xFFB5976A), strokeWidth: 2))
                            : Text(
                                _isFollowing ? 'Siguiendo' : 'Seguir',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _isFollowing
                                      ? const Color(0xFFB5976A)
                                      : Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(
                        context,
                        '/chat',
                        arguments: {'other_uid': _ongUid},
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 4),
                          ],
                        ),
                        child: const Icon(Icons.chat_bubble_outline,
                            size: 18, color: Color(0xFFB5976A)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/map'),
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 4),
                          ],
                        ),
                        child: const Icon(Icons.location_on_outlined,
                            size: 18, color: Color(0xFFB5976A)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStats() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFFB5976A).withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 3)),
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
                    onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => _FollowListScreen(
                                uid: _ongUid,
                                mode: 'followers',
                                title: 'Seguidores'),
                          ),
                        )),
                _buildDivider(),
                _buildStatItem('Siguiendo', '$_seguidos',
                    onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => _FollowListScreen(
                                uid: _ongUid,
                                mode: 'following',
                                title: 'Siguiendo'),
                          ),
                        )),
              ],
            ),
    );
  }

  Widget _buildStatItem(String label, String value, {VoidCallback? onTap}) {
    final content = Column(
      children: [
        Text(label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF9A8A75))),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A3F30))),
      ],
    );
    if (onTap == null) return content;
    return GestureDetector(onTap: onTap, child: content);
  }

  Widget _buildDivider() =>
      Container(width: 1, height: 40, color: const Color(0xFFE8D5C4));

  String _formatPostDate(dynamic ts) {
    if (ts == null) return '';
    try {
      final dt = (ts as Timestamp).toDate();
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return '';
    }
  }

  Widget _buildPostsSection() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _firestoreService.getOngPostsStream(ongId: widget.ongId),
      builder: (context, snapshot) {
        final posts = snapshot.data ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Publicaciones',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF4A3F30)),
            ),
            const SizedBox(height: 10),
            if (snapshot.connectionState == ConnectionState.waiting)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: CircularProgressIndicator(
                      color: Color(0xFFB5976A), strokeWidth: 2),
                ),
              )
            else if (posts.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Text(
                    'Aún no hay publicaciones',
                    style:
                        TextStyle(color: Color(0xFF9A8A75), fontSize: 13),
                  ),
                ),
              )
            else
              ...posts.map((post) => _buildPostCard(post)),
          ],
        );
      },
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
    final tipoPost = post['tipo_post'] as String? ?? 'donacion';
    final titulo = post['titulo'] as String? ?? '';
    final descripcion = post['descripcion'] as String? ?? '';
    final fotos = List<String>.from(post['fotos'] ?? []);
    final ciudad = post['ciudad'] as String? ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB5976A).withValues(alpha: 0.07),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (fotos.isNotEmpty)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
              child: Image.network(
                fotos.first,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPostTypeBadge(tipoPost),
                const SizedBox(height: 8),
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4A3F30),
                  ),
                ),
                if (descripcion.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    descripcion,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 13, color: Color(0xFF5A4E40), height: 1.4),
                  ),
                ],
                const SizedBox(height: 10),
                if (tipoPost == 'donacion')
                  _buildDonacionPostDetails(post)
                else if (tipoPost == 'evento')
                  _buildEventoPostDetails(post),
                if (ciudad.isNotEmpty && tipoPost == 'campana') ...[
                  Row(children: [
                    const Icon(Icons.location_on_outlined,
                        size: 13, color: Color(0xFFB5976A)),
                    const SizedBox(width: 3),
                    Text(ciudad,
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF9A8A75))),
                  ]),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostTypeBadge(String tipoPost) {
    final Map<String, Map<String, dynamic>> config = {
      'donacion': {
        'label': 'Donación',
        'icon': Icons.volunteer_activism,
        'color': const Color(0xFF6B9E78),
      },
      'evento': {
        'label': 'Evento',
        'icon': Icons.event,
        'color': const Color(0xFF5B8DBE),
      },
      'campana': {
        'label': 'Campaña',
        'icon': Icons.campaign,
        'color': const Color(0xFFB5976A),
      },
    };
    final c = config[tipoPost] ?? config['campana']!;
    final color = c['color'] as Color;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(c['icon'] as IconData, size: 12, color: color),
              const SizedBox(width: 4),
              Text(
                c['label'] as String,
                style: TextStyle(
                    fontSize: 11, color: color, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDonacionPostDetails(Map<String, dynamic> post) {
    final tipos = List<String>.from(post['tipos_ropa'] ?? []);
    final cantidad = post['cantidad'] as String? ?? '';
    final ciudad = post['ciudad'] as String? ?? '';
    final fechaLimite = _formatPostDate(post['fecha_limite']);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (tipos.isNotEmpty) ...[
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: tipos
                .map((t) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color:
                            const Color(0xFF6B9E78).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(t,
                          style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF4A7A58),
                              fontWeight: FontWeight.w500)),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
        ],
        Row(children: [
          if (ciudad.isNotEmpty) ...[
            const Icon(Icons.location_on_outlined,
                size: 13, color: Color(0xFFB5976A)),
            const SizedBox(width: 3),
            Text(ciudad,
                style:
                    const TextStyle(fontSize: 12, color: Color(0xFF9A8A75))),
          ],
          if (ciudad.isNotEmpty && cantidad.isNotEmpty)
            const Text('  •  ',
                style:
                    TextStyle(color: Color(0xFFD4C4A8), fontSize: 12)),
          if (cantidad.isNotEmpty)
            Text('$cantidad prendas',
                style: const TextStyle(
                    fontSize: 12, color: Color(0xFF9A8A75))),
        ]),
        if (fechaLimite.isNotEmpty) ...[
          const SizedBox(height: 4),
          Row(children: [
            const Icon(Icons.calendar_today_outlined,
                size: 13, color: Color(0xFFB5976A)),
            const SizedBox(width: 3),
            Text('Límite: $fechaLimite',
                style:
                    const TextStyle(fontSize: 12, color: Color(0xFF9A8A75))),
          ]),
        ],
      ],
    );
  }

  Widget _buildEventoPostDetails(Map<String, dynamic> post) {
    final ciudad = post['ciudad'] as String? ?? '';
    final direccion = post['direccion'] as String? ?? '';
    final fechaEvento = _formatPostDate(post['fecha_evento']);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (ciudad.isNotEmpty || direccion.isNotEmpty) ...[
          Row(children: [
            const Icon(Icons.location_on_outlined,
                size: 13, color: Color(0xFF5B8DBE)),
            const SizedBox(width: 3),
            Expanded(
              child: Text(
                [ciudad, direccion].where((s) => s.isNotEmpty).join(', '),
                style: const TextStyle(
                    fontSize: 12, color: Color(0xFF9A8A75)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ]),
          const SizedBox(height: 4),
        ],
        if (fechaEvento.isNotEmpty)
          Row(children: [
            const Icon(Icons.event, size: 13, color: Color(0xFF5B8DBE)),
            const SizedBox(width: 3),
            Text(fechaEvento,
                style: const TextStyle(
                    fontSize: 12, color: Color(0xFF9A8A75))),
          ]),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFFB5976A).withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Sobre la fundación',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4A3F30))),
          const SizedBox(height: 10),
          if (_descripcion.isNotEmpty) ...[
            Text(_descripcion,
                style: const TextStyle(
                    color: Color(0xFF5A4E40), fontSize: 13.5, height: 1.5)),
            const SizedBox(height: 12),
          ],
          _infoRow(Icons.person_outline, 'Representante legal', _representante),
          _infoRow(Icons.location_on_outlined, 'Ciudad', _ciudad),
          _infoRow(Icons.email_outlined, 'Email', _email),
          _infoRow(Icons.phone_outlined, 'Teléfono', _telefono),
          _infoRow(Icons.badge_outlined, 'NIT', _nit),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: const Color(0xFFB5976A)),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                      text: '$label: ',
                      style: const TextStyle(
                          color: Color(0xFF9A8A75),
                          fontSize: 13,
                          fontWeight: FontWeight.w500)),
                  TextSpan(
                      text: value,
                      style: const TextStyle(
                          color: Color(0xFF4A3F30), fontSize: 13)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Lista de seguidores/siguiendo de la ONG
// ─────────────────────────────────────────────────────────────
class _FollowListScreen extends StatefulWidget {
  final String uid;
  final String mode;
  final String title;
  const _FollowListScreen(
      {required this.uid, required this.mode, required this.title});

  @override
  State<_FollowListScreen> createState() => _FollowListScreenState();
}

class _FollowListScreenState extends State<_FollowListScreen> {
  final _firestoreService = FirestoreService();
  bool _loading = true;
  List<Map<String, dynamic>> _users = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final uids = await _firestoreService.getFollowList(
        uid: widget.uid, mode: widget.mode);
    final users = <Map<String, dynamic>>[];
    for (final uid in uids) {
      final data = await _firestoreService.getUserById(uid);
      if (data != null) {
        final nombre =
            '${data['nombre'] ?? ''} ${data['apellido'] ?? ''}'.trim();
        users.add({
          'uid': uid,
          'nombre': nombre.isNotEmpty ? nombre : (data['username'] ?? 'Usuario'),
          'username': data['username'] ?? '',
        });
      }
    }
    if (mounted) setState(() { _users = users; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5EFE6),
        elevation: 0,
        title: Text(widget.title,
            style: const TextStyle(
                color: Color(0xFF4A3F30),
                fontSize: 18,
                fontWeight: FontWeight.w600)),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFB5976A)))
          : _users.isEmpty
              ? Center(
                  child: Text(
                    widget.mode == 'followers'
                        ? 'Aún no hay seguidores'
                        : 'Aún no sigue a nadie',
                    style: const TextStyle(
                        color: Color(0xFF9A8A75), fontSize: 15),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  itemCount: _users.length,
                  itemBuilder: (context, index) {
                    final u = _users[index];
                    final nombre = u['nombre'] as String;
                    final username = u['username'] as String;
                    final initial =
                        nombre.isNotEmpty ? nombre[0].toUpperCase() : '?';
                    return Container(
                      margin: const EdgeInsets.only(bottom: 2),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 4),
                      decoration: const BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                                color: Color(0xFFEEE4D8), width: 0.5)),
                      ),
                      child: Row(children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor:
                              const Color(0xFFB5976A).withValues(alpha: 0.15),
                          child: Text(initial,
                              style: const TextStyle(
                                  color: Color(0xFFB5976A),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15)),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(nombre,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF4A3F30))),
                            if (username.isNotEmpty)
                              Text('@$username',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF9A8A75))),
                          ],
                        ),
                      ]),
                    );
                  },
                ),
    );
  }
}
