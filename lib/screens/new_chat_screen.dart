import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NewChatScreen extends StatefulWidget {
  const NewChatScreen({super.key});

  @override
  State<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> {
  final _searchCtrl = TextEditingController();
  final _currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';

  String _query = '';
  bool _loading = false;
  List<Map<String, dynamic>> _results = [];

  @override
  void initState() {
    super.initState();
    _loadAll(); // Cargar todos al inicio
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    final results = await _fetchAll('');
    if (mounted) setState(() { _results = results; _loading = false; });
  }

  Future<List<Map<String, dynamic>>> _fetchAll(String query) async {
    final db = FirebaseFirestore.instance;
    final q = query.toLowerCase().trim();
    final List<Map<String, dynamic>> all = [];

    // ── Usuarios ──────────────────────────────────────
    final usersSnap = await db.collection('users').get();
    for (final doc in usersSnap.docs) {
      if (doc.id == _currentUid) continue;
      final data = doc.data();
      final nombre =
          '${data['nombre'] ?? ''} ${data['apellido'] ?? ''}'.trim();
      final username = data['username'] as String? ?? '';
      final tipo = data['tipo'] as String? ?? 'usuario';
      if (tipo == 'ong') continue; // las ONGs van por su colección

      if (q.isEmpty ||
          nombre.toLowerCase().contains(q) ||
          username.toLowerCase().contains(q)) {
        all.add({
          'uid': doc.id,
          'nombre': nombre.isNotEmpty ? nombre : username,
          'username': username,
          'tipo': 'usuario',
          'foto': data['foto_perfil'] as String? ?? '',
        });
      }
    }

    // ── ONGs ──────────────────────────────────────────
    final ongsSnap = await db.collection('ongs').get();
    for (final doc in ongsSnap.docs) {
      final data = doc.data();
      final nombre = data['nombre_fundacion'] as String? ?? 'ONG';
      final ciudad = data['ciudad'] as String? ?? '';

      if (q.isEmpty || nombre.toLowerCase().contains(q) ||
          ciudad.toLowerCase().contains(q)) {
        all.add({
          'uid': doc.id,
          'nombre': nombre,
          'username': ciudad,
          'tipo': 'ong',
          'foto': data['logo_url'] as String? ?? '',
        });
      }
    }

    // Ordenar: primero usuarios, luego ONGs, alfabético dentro de cada grupo
    all.sort((a, b) {
      if (a['tipo'] != b['tipo']) {
        return a['tipo'] == 'usuario' ? -1 : 1;
      }
      return (a['nombre'] as String)
          .toLowerCase()
          .compareTo((b['nombre'] as String).toLowerCase());
    });

    return all;
  }

  void _onSearch(String value) async {
    setState(() { _query = value; _loading = true; });
    final results = await _fetchAll(value);
    if (mounted) setState(() { _results = results; _loading = false; });
  }

  void _openChat(String uid) {
    Navigator.pop(context); // cerrar esta pantalla
    Navigator.pushNamed(
      context,
      '/chat',
      arguments: {'other_uid': uid},
    );
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
          icon: const Icon(Icons.close, color: Color(0xFF4A3F30)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Nueva conversación',
            style: TextStyle(
                color: Color(0xFF4A3F30),
                fontSize: 18,
                fontWeight: FontWeight.w600)),
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE0D0BC)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search,
                      color: Color(0xFFB0A090), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      autofocus: false,
                      style: const TextStyle(
                          color: Color(0xFF4A3F30), fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'Buscar por nombre...',
                        hintStyle: TextStyle(
                            color: Color(0xFFB0A090), fontSize: 14),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      onChanged: _onSearch,
                    ),
                  ),
                  if (_query.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchCtrl.clear();
                        _onSearch('');
                      },
                      child: const Icon(Icons.close,
                          color: Color(0xFFB0A090), size: 18),
                    ),
                ],
              ),
            ),
          ),

          // Lista
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFFB5976A)))
                : _results.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off,
                                size: 56,
                                color: const Color(0xFFB5976A)
                                    .withOpacity(0.3)),
                            const SizedBox(height: 12),
                            Text(
                              _query.isEmpty
                                  ? 'No hay usuarios registrados'
                                  : 'Sin resultados para "$_query"',
                              style: const TextStyle(
                                  color: Color(0xFF9A8A75),
                                  fontSize: 14),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        itemCount: _results.length,
                        itemBuilder: (context, index) {
                          // Encabezado de sección
                          final item = _results[index];
                          final isFirst = index == 0;
                          final prevTipo = index > 0
                              ? _results[index - 1]['tipo']
                              : null;
                          final showHeader = isFirst ||
                              item['tipo'] != prevTipo;

                          return Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              if (showHeader)
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: isFirst ? 4 : 16,
                                      bottom: 8),
                                  child: Text(
                                    item['tipo'] == 'usuario'
                                        ? 'Usuarios'
                                        : 'Fundaciones',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF9A8A75),
                                        letterSpacing: 0.5),
                                  ),
                                ),
                              _UserRow(
                                item: item,
                                onTap: () => _openChat(item['uid']),
                              ),
                            ],
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _UserRow extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onTap;
  const _UserRow({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final nombre = item['nombre'] as String;
    final username = item['username'] as String;
    final foto = item['foto'] as String;
    final isOng = item['tipo'] == 'ong';
    final initial =
        nombre.isNotEmpty ? nombre[0].toUpperCase() : '?';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: const BoxDecoration(
          border: Border(
              bottom:
                  BorderSide(color: Color(0xFFEEE4D8), width: 0.5)),
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 22,
              backgroundColor: isOng
                  ? const Color(0xFFE8D5C4)
                  : const Color(0xFFB5976A).withOpacity(0.15),
              backgroundImage:
                  foto.isNotEmpty ? NetworkImage(foto) : null,
              child: foto.isEmpty
                  ? isOng
                      ? const Icon(Icons.volunteer_activism,
                          color: Color(0xFFB5976A), size: 20)
                      : Text(initial,
                          style: const TextStyle(
                              color: Color(0xFFB5976A),
                              fontWeight: FontWeight.bold,
                              fontSize: 15))
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nombre,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4A3F30))),
                  if (username.isNotEmpty)
                    Text(
                      isOng ? username : '@$username',
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF9A8A75)),
                    ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: Color(0xFFB0A090), size: 20),
          ],
        ),
      ),
    );
  }
}
