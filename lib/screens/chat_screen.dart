import 'package:flutter/material.dart';
import '../widgets/smart_back_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/bottom_nav.dart';
import '../services/firestore_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final _firestoreService = FirestoreService();
  final _currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';

  String? _otherUid;
  bool _isAiChat = false;

  String _otherName = 'Cargando...';
  String _otherInitial = '?';
  bool _loadingName = true;

  String? _editingMessageId;

  final List<Map<String, dynamic>> _aiMessages = [
    {
      'isUser': false,
      'text': '¡Hola! Soy Hilo, tu asistente de moda 👗 ¿En qué te puedo ayudar hoy?',
      'time': '',
    },
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      _otherUid = args['other_uid'] as String?;
    }
    _isAiChat = _otherUid == null || _otherUid!.isEmpty;

    if (!_isAiChat && _otherUid != null) {
      _firestoreService.markChatAsRead(_otherUid!);
      _loadOtherUserName();
    } else {
      setState(() => _loadingName = false);
    }
  }

  Future<void> _loadOtherUserName() async {
    if (_otherUid == null) return;
    final name = await _firestoreService.getUserDisplayName(_otherUid!);
    if (mounted) {
      setState(() {
        _otherName = name;
        _otherInitial = name.isNotEmpty ? name[0].toUpperCase() : '?';
        _loadingName = false;
      });
    }
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    if (_editingMessageId != null && _otherUid != null) {
      final id = _editingMessageId!;
      setState(() => _editingMessageId = null);
      _msgController.clear();
      await _firestoreService.editMessage(
        otherUid: _otherUid!,
        messageId: id,
        newText: text,
      );
      return;
    }

    _msgController.clear();

    if (_isAiChat) {
      setState(() {
        _aiMessages.add({'isUser': true, 'text': text, 'time': _nowTime()});
        _aiMessages.add({'isUser': false, 'text': 'Procesando tu consulta... ✨', 'time': _nowTime()});
      });
      _scrollToBottom();
    } else if (_otherUid != null) {
      await _firestoreService.sendMessage(otherUid: _otherUid!, text: text);
      _scrollToBottom();
    }
  }

  void _startEditing(String messageId, String currentText) {
    setState(() => _editingMessageId = messageId);
    _msgController.text = currentText;
    _msgController.selection = TextSelection.fromPosition(
      TextPosition(offset: currentText.length),
    );
  }

  void _cancelEditing() {
    setState(() => _editingMessageId = null);
    _msgController.clear();
  }

  Future<void> _confirmDelete(String messageId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFF5EFE6),
        title: const Text('Eliminar mensaje',
            style: TextStyle(color: Color(0xFF4A3F30), fontSize: 16, fontWeight: FontWeight.w600)),
        content: const Text('¿Estás seguro de que quieres eliminar este mensaje?',
            style: TextStyle(color: Color(0xFF9A8A75), fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar', style: TextStyle(color: Color(0xFF9A8A75))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true && _otherUid != null) {
      await _firestoreService.deleteMessage(
        otherUid: _otherUid!,
        messageId: messageId,
      );
    }
  }

  // FIX: ya no se pasa BuildContext como parámetro — se usa el context del widget
  // directamente para que el Navigator.pop() dentro del sheet funcione bien.
  void _showMessageOptions(String messageId, String text) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: const Color(0xFFE0D0BC), borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: Color(0xFFB5976A)),
              title: const Text('Editar mensaje',
                  style: TextStyle(color: Color(0xFF4A3F30), fontSize: 14)),
              onTap: () {
                Navigator.pop(sheetCtx); // cierra el sheet
                _startEditing(messageId, text);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Eliminar mensaje',
                  style: TextStyle(color: Colors.red, fontSize: 14)),
              onTap: () {
                Navigator.pop(sheetCtx); // cierra el sheet
                _confirmDelete(messageId);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  String _nowTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return '';
    try {
      final dt = (timestamp as dynamic).toDate() as DateTime;
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          if (_editingMessageId != null) _buildEditingBanner(),
          _buildInputBar(),
        ],
      ),
      bottomNavigationBar: const BottomNavWidget(currentIndex: 2),
    );
  }

  Widget _buildEditingBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFFB5976A).withOpacity(0.12),
      child: Row(
        children: [
          const Icon(Icons.edit, size: 16, color: Color(0xFFB5976A)),
          const SizedBox(width: 8),
          const Expanded(
            child: Text('Editando mensaje...',
                style: TextStyle(color: Color(0xFFB5976A), fontSize: 12, fontWeight: FontWeight.w500)),
          ),
          GestureDetector(
            onTap: _cancelEditing,
            child: const Icon(Icons.close, size: 18, color: Color(0xFFB5976A)),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF5EFE6),
      elevation: 0,
      title: Row(
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: _isAiChat ? const Color(0xFF3D3025) : const Color(0xFFB5976A).withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: _isAiChat
                  ? const Text('AI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))
                  : Text(_otherInitial, style: const TextStyle(color: Color(0xFFB5976A), fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isAiChat ? 'Hilo (IA)' : (_loadingName ? 'Cargando...' : _otherName),
                style: const TextStyle(color: Color(0xFF4A3F30), fontSize: 15, fontWeight: FontWeight.w600),
              ),
              if (_isAiChat)
                const Text('Asistente de moda', style: TextStyle(color: Color(0xFF9A8A75), fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    if (_isAiChat) {
      return ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        itemCount: _aiMessages.length,
        itemBuilder: (context, index) {
          final msg = _aiMessages[index];
          return _buildBubble(
            text: msg['text'] as String,
            isUser: msg['isUser'] as bool,
            time: msg['time'] as String,
          );
        },
      );
    }

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _firestoreService.getMessagesStream(_otherUid ?? ''),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFB5976A)));
        }

        final messages = snapshot.data ?? [];

        if (messages.isEmpty) {
          return const Center(
            child: Text('Inicia la conversación 👋',
                style: TextStyle(color: Color(0xFF9A8A75), fontSize: 14)),
          );
        }

        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final msg = messages[index];
            final isUser = msg['sender_id'] == _currentUid;
            final isEdited = msg['edited'] == true;
            final messageId = msg['id'] as String? ?? '';
            final text = msg['text'] as String? ?? '';
            return _buildBubble(
              text: text,
              isUser: isUser,
              time: _formatTimestamp(msg['sent_at']),
              isEdited: isEdited,
              onLongPress: isUser && messageId.isNotEmpty
                  ? () => _showMessageOptions(messageId, text)
                  : null,
            );
          },
        );
      },
    );
  }

  Widget _buildBubble({
    required String text,
    required bool isUser,
    required String time,
    bool isEdited = false,
    VoidCallback? onLongPress,
  }) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: onLongPress,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isUser ? const Color(0xFFB5976A) : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isUser ? 16 : 4),
              bottomRight: Radius.circular(isUser ? 4 : 16),
            ),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                text,
                style: TextStyle(
                  color: isUser ? Colors.white : const Color(0xFF4A3F30),
                  fontSize: 14, height: 1.4,
                ),
              ),
              if (time.isNotEmpty || isEdited) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isEdited) ...[
                      Text('editado',
                          style: TextStyle(
                            color: isUser ? Colors.white.withOpacity(0.6) : const Color(0xFFB0A090),
                            fontSize: 10, fontStyle: FontStyle.italic,
                          )),
                      const SizedBox(width: 4),
                    ],
                    if (time.isNotEmpty)
                      Text(time,
                          style: TextStyle(
                            color: isUser ? Colors.white.withOpacity(0.7) : const Color(0xFFB0A090),
                            fontSize: 10,
                          )),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFF5EFE6),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE0D0BC)),
              ),
              child: TextField(
                controller: _msgController,
                style: const TextStyle(color: Color(0xFF4A3F30), fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Escribe un mensaje...',
                  hintStyle: TextStyle(color: Color(0xFFB0A090), fontSize: 14),
                  border: InputBorder.none,
                  isDense: true,
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 44, height: 44,
              decoration: const BoxDecoration(color: Color(0xFFB5976A), shape: BoxShape.circle),
              child: Icon(
                _editingMessageId != null ? Icons.check_rounded : Icons.send_rounded,
                color: Colors.white, size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
