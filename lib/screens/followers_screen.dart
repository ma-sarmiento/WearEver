import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';

/// Pantalla que muestra la lista de seguidores o seguidos de un usuario.
/// Recibe por argumentos: { 'mode': 'followers' | 'following', 'uid': String }
class FollowersScreen extends StatefulWidget {
  const FollowersScreen({super.key});

  @override
  State<FollowersScreen> createState() => _FollowersScreenState();
}

class _FollowersScreenState extends State<FollowersScreen> {
  final _firestoreService = FirestoreService();
  final _currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';

  late String _mode; // 'followers' | 'following'
  late String _uid;

  bool _initialized = false;
  bool _loading = true;
  List<Map<String, dynamic>> _users = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _mode = args?['mode'] as String? ?? 'followers';
    _uid = args?['uid'] as String? ?? _currentUid;

    _loadList();
  }

  Future<void> _loadList() async {
    setState(() => _loading = true);
    final uids = await _firestoreService.getFollowList(uid: _uid, mode: _mode);
    final users = <Map<String, dynamic>>[];
    for (final targetUid in uids) {
      final data = await _firestoreService.getUserById(targetUid);
      if (data != null) {
        final nombre = '${data['nombre'] ?? ''} ${data['apellido'] ?? ''}'.trim();
        users.add({
          'uid': targetUid,
          'nombre': nombre.isNotEmpty ? nombre : (data['username'] ?? 'Usuario'),
          'username': data['username'] ?? '',
          'foto_perfil': data['foto_perfil'] ?? '',
        });
      }
    }
    if (mounted) setState(() { _users = users; _loading = false; });
  }

  Future<void> _toggleFollow(String targetUid, bool currentlyFollowing) async {
    if (currentlyFollowing) {
      await _firestoreService.unfollowUser(targetUid);
    } else {
      await _firestoreService.followUser(targetUid);
    }
    await _loadList();
  }

  @override
  Widget build(BuildContext context) {
    final title = _mode == 'followers' ? 'Seguidores' : 'Siguiendo';

    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5EFE6),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4A3F30)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          title,
          style: const TextStyle(
              color: Color(0xFF4A3F30), fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFB5976A)))
          : _users.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline,
                          size: 64,
                          color: const Color(0xFFB5976A).withOpacity(0.3)),
                      const SizedBox(height: 16),
                      Text(
                        _mode == 'followers'
                            ? 'Aún no tienes seguidores'
                            : 'Aún no sigues a nadie',
                        style: const TextStyle(color: Color(0xFF9A8A75), fontSize: 15),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: _users.length,
                  itemBuilder: (context, index) {
                    final user = _users[index];
                    return _UserTile(
                      user: user,
                      currentUid: _currentUid,
                      firestoreService: _firestoreService,
                      onToggleFollow: _toggleFollow,
                      onTap: () {
                        if (user['uid'] == _currentUid) {
                          Navigator.pushNamed(context, '/profile');
                        } else {
                          Navigator.pushNamed(
                            context,
                            '/seller-profile',
                            arguments: {'seller_uid': user['uid']},
                          );
                        }
                      },
                    );
                  },
                ),
    );
  }
}

class _UserTile extends StatefulWidget {
  final Map<String, dynamic> user;
  final String currentUid;
  final FirestoreService firestoreService;
  final Future<void> Function(String uid, bool currentlyFollowing) onToggleFollow;
  final VoidCallback onTap;

  const _UserTile({
    required this.user,
    required this.currentUid,
    required this.firestoreService,
    required this.onToggleFollow,
    required this.onTap,
  });

  @override
  State<_UserTile> createState() => _UserTileState();
}

class _UserTileState extends State<_UserTile> {
  bool _isFollowing = false;
  bool _loading = true;
  bool _toggling = false;

  @override
  void initState() {
    super.initState();
    _checkFollowing();
  }

  Future<void> _checkFollowing() async {
    if (widget.user['uid'] == widget.currentUid) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    final result = await widget.firestoreService.isFollowing(widget.user['uid'] as String);
    if (mounted) setState(() { _isFollowing = result; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final uid = widget.user['uid'] as String;
    final nombre = widget.user['nombre'] as String;
    final username = widget.user['username'] as String;
    final foto = widget.user['foto_perfil'] as String;
    final initial = nombre.isNotEmpty ? nombre[0].toUpperCase() : '?';
    final isMe = uid == widget.currentUid;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 2),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFEEE4D8), width: 0.5)),
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFFB5976A).withOpacity(0.15),
              backgroundImage: foto.isNotEmpty ? NetworkImage(foto) : null,
              child: foto.isEmpty
                  ? Text(initial,
                      style: const TextStyle(
                          color: Color(0xFFB5976A),
                          fontWeight: FontWeight.bold,
                          fontSize: 16))
                  : null,
            ),
            const SizedBox(width: 12),
            // Nombre y username
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
                    Text('@$username',
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF9A8A75))),
                ],
              ),
            ),
            // Botón seguir (no se muestra para uno mismo)
            if (!isMe)
              _loading
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(
                          color: Color(0xFFB5976A), strokeWidth: 2))
                  : GestureDetector(
                      onTap: _toggling
                          ? null
                          : () async {
                              setState(() => _toggling = true);
                              await widget.onToggleFollow(uid, _isFollowing);
                              if (mounted) {
                                setState(() {
                                  _isFollowing = !_isFollowing;
                                  _toggling = false;
                                });
                              }
                            },
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
                        child: Text(
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
          ],
        ),
      ),
    );
  }
}
