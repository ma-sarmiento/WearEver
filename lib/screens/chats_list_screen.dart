import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/bottom_nav.dart';
import '../services/firestore_service.dart';

class ChatsListScreen extends StatefulWidget {
  const ChatsListScreen({super.key});

  @override
  State<ChatsListScreen> createState() => _ChatsListScreenState();
}

class _ChatsListScreenState extends State<ChatsListScreen> {
  final _firestoreService = FirestoreService();
  final _currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';

  bool _selecting = false;
  final Set<String> _selectedIds = {};

  void _toggleSelecting() {
    setState(() {
      _selecting = !_selecting;
      _selectedIds.clear();
    });
  }

  void _toggleSelect(String chatId) {
    setState(() {
      if (_selectedIds.contains(chatId)) {
        _selectedIds.remove(chatId);
      } else {
        _selectedIds.add(chatId);
      }
    });
  }

  Future<void> _deleteSelected() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFF5EFE6),
        title: Text(
          'Eliminar ${_selectedIds.length} conversación${_selectedIds.length > 1 ? 'es' : ''}',
          style: const TextStyle(
              color: Color(0xFF4A3F30),
              fontSize: 16,
              fontWeight: FontWeight.w600),
        ),
        content: const Text(
          'Se eliminará el historial de estos chats. Esta acción no se puede deshacer.',
          style: TextStyle(color: Color(0xFF9A8A75), fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar',
                style: TextStyle(color: Color(0xFF9A8A75))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    for (final chatId in _selectedIds) {
      await _firestoreService.deleteChat(chatId);
    }

    setState(() {
      _selecting = false;
      _selectedIds.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          if (!_selecting) _buildHiloAiButton(context),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _firestoreService.getChatsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFB5976A)),
                  );
                }

                final chats = snapshot.data ?? [];

                if (chats.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline,
                            size: 64,
                            color: const Color(0xFFB5976A).withOpacity(0.3)),
                        const SizedBox(height: 16),
                        const Text(
                          'Aún no tienes conversaciones',
                          style: TextStyle(
                              color: Color(0xFF9A8A75), fontSize: 15),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Chatea con un vendedor desde cualquier publicación',
                          style: TextStyle(
                              color: Color(0xFFB0A090), fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  itemCount: chats.length,
                  itemBuilder: (context, index) {
                    final chat = chats[index];
                    final chatId = chat['id'] as String? ?? '';
                    final participants =
                    List<String>.from(chat['participants'] ?? []);
                    final otherUid = participants.firstWhere(
                            (uid) => uid != _currentUid,
                        orElse: () => '');
                    final unread =
                        (chat['unread_$_currentUid'] as int?) ?? 0;
                    final lastMsg =
                        chat['last_message'] as String? ?? '';
                    final isSelected = _selectedIds.contains(chatId);

                    return _ChatTile(
                      key: ValueKey(chatId),
                      firestoreService: _firestoreService,
                      otherUid: otherUid,
                      chatId: chatId,
                      lastMsg: lastMsg,
                      unread: unread,
                      selecting: _selecting,
                      isSelected: isSelected,
                      onSelect: () {},
                      onTap: () {
                        if (_selecting) {
                          _toggleSelect(chatId);
                        } else {
                          Navigator.pushNamed(
                            context,
                            '/chat',
                            arguments: {'other_uid': otherUid},
                          );
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      // Barra inferior de acciones al seleccionar
      bottomSheet: _selecting && _selectedIds.isNotEmpty
          ? Container(
        color: Colors.white,
        padding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Text(
              '${_selectedIds.length} seleccionado${_selectedIds.length > 1 ? 's' : ''}',
              style: const TextStyle(
                  color: Color(0xFF4A3F30),
                  fontWeight: FontWeight.w500,
                  fontSize: 14),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _deleteSelected,
              icon: const Icon(Icons.delete_outline,
                  color: Colors.red, size: 20),
              label: const Text('Eliminar',
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      )
          : null,
      bottomNavigationBar:
      _selecting ? null : const BottomNavWidget(currentIndex: 2),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: const Color(0xFFF5EFE6),
      elevation: 0,
      title: Text(
        _selecting ? 'Seleccionar' : 'Mensajes',
        style: const TextStyle(
            color: Color(0xFF4A3F30),
            fontSize: 20,
            fontWeight: FontWeight.w600),
      ),
      centerTitle: false,
      actions: [
        if (_selecting)
          TextButton(
            onPressed: _toggleSelecting,
            child: const Text('Cancelar',
                style: TextStyle(
                    color: Color(0xFFB5976A), fontWeight: FontWeight.w600)),
          )
        else
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Color(0xFF4A3F30)),
            tooltip: 'Seleccionar chats',
            onPressed: _toggleSelecting,
          ),
      ],
    );
  }

  Widget _buildHiloAiButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/chat'),
      child: Container(
        margin: const EdgeInsets.fromLTRB(14, 8, 14, 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF3D3025),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFB5976A),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text('AI',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('Hilo (IA)',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 15)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: const BoxDecoration(
                          color: Color(0xFFB5976A),
                          borderRadius:
                          BorderRadius.all(Radius.circular(6)),
                        ),
                        child: const Text('Fijado',
                            style: TextStyle(
                                color: Colors.white, fontSize: 10)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  const Text('¿Necesitas algún consejo de moda?',
                      style: TextStyle(
                          color: Color(0xFFB0A090), fontSize: 13)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                color: Color(0xFFB0A090), size: 14),
          ],
        ),
      ),
    );
  }
}

class _ChatTile extends StatefulWidget {
  final FirestoreService firestoreService;
  final String otherUid;
  final String chatId;
  final String lastMsg;
  final int unread;
  final bool selecting;
  final bool isSelected;
  final VoidCallback onSelect;
  final VoidCallback onTap;

  const _ChatTile({
    super.key,
    required this.firestoreService,
    required this.otherUid,
    required this.chatId,
    required this.lastMsg,
    required this.unread,
    required this.selecting,
    required this.isSelected,
    required this.onSelect,
    required this.onTap,
  });

  @override
  State<_ChatTile> createState() => _ChatTileState();
}

class _ChatTileState extends State<_ChatTile> {
  String _displayName = '';
  String _initial = '?';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadName();
  }

  Future<void> _loadName() async {
    if (widget.otherUid.isEmpty) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    final name =
    await widget.firestoreService.getUserDisplayName(widget.otherUid);
    if (mounted) {
      setState(() {
        _displayName = name;
        _initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 2),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: widget.isSelected
              ? const Color(0xFFB5976A).withOpacity(0.08)
              : Colors.transparent,
          border: const Border(
            bottom: BorderSide(color: Color(0xFFEEE4D8), width: 0.5),
          ),
        ),
        child: Row(
          children: [
            // Checkbox de selección
            if (widget.selecting) ...[
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 24,
                height: 24,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.isSelected
                      ? const Color(0xFFB5976A)
                      : Colors.transparent,
                  border: Border.all(
                    color: widget.isSelected
                        ? const Color(0xFFB5976A)
                        : const Color(0xFFB0A090),
                    width: 2,
                  ),
                ),
                child: widget.isSelected
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
            ],
            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFFB5976A).withOpacity(0.15),
              child: _loading
                  ? const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                    color: Color(0xFFB5976A), strokeWidth: 2),
              )
                  : Text(
                _initial,
                style: const TextStyle(
                  color: Color(0xFFB5976A),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _loading ? 'Cargando...' : _displayName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: widget.unread > 0
                          ? FontWeight.w700
                          : FontWeight.w600,
                      color: _loading
                          ? const Color(0xFF9A8A75)
                          : const Color(0xFF4A3F30),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.lastMsg,
                    style: TextStyle(
                      fontSize: 13,
                      color: widget.unread > 0
                          ? const Color(0xFF4A3F30)
                          : const Color(0xFF9A8A75),
                      fontWeight: widget.unread > 0
                          ? FontWeight.w500
                          : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (!widget.selecting && widget.unread > 0)
              Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: Color(0xFFB5976A),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${widget.unread}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
