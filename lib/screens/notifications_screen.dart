import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/bottom_nav.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  Stream<List<Map<String, dynamic>>> _stream(String uid) {
    return FirebaseFirestore.instance
        .collection('notifications')
        .where('destinatario_uid', isEqualTo: uid)
        .snapshots()
        .map((snap) {
      final docs =
          snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
      docs.sort((a, b) {
        final aTs = a['created_at'];
        final bTs = b['created_at'];
        if (aTs == null) return 1;
        if (bTs == null) return -1;
        return (bTs as Timestamp).compareTo(aTs as Timestamp);
      });
      return docs;
    });
  }

  IconData _iconForType(String tipo) {
    switch (tipo) {
      case 'nuevo_mensaje':
        return Icons.chat_bubble_outline;
      case 'nuevo_seguidor':
        return Icons.person_add_outlined;
      case 'pedido_actualizado':
        return Icons.local_shipping_outlined;
      case 'nueva_donacion':
        return Icons.volunteer_activism;
      default:
        return Icons.notifications_outlined;
    }
  }

  String _textForNotif(Map<String, dynamic> notif) {
    final tipo = notif['tipo'] as String? ?? '';
    final nombre = notif['remitente_nombre'] as String? ?? 'Alguien';
    final preview = notif['preview'] as String?;
    switch (tipo) {
      case 'nuevo_mensaje':
        return preview != null && preview.isNotEmpty
            ? '$nombre: $preview'
            : '$nombre te envió un mensaje';
      case 'nuevo_seguidor':
        return '$nombre comenzó a seguirte';
      case 'pedido_actualizado':
        return 'Tu pedido fue actualizado';
      case 'nueva_donacion':
        return '$nombre quiere donar a tu fundación';
      default:
        return 'Nueva notificación de $nombre';
    }
  }

  String _routeForType(String tipo) {
    switch (tipo) {
      case 'nuevo_mensaje':
        return '/chats-list';
      case 'nuevo_seguidor':
        return '/profile';
      case 'pedido_actualizado':
        return '/orders';
      case 'nueva_donacion':
        return '/ong';
      default:
        return '/home';
    }
  }

  String _relativeTime(dynamic ts) {
    if (ts == null) return '';
    try {
      final dt = (ts as Timestamp).toDate();
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return 'ahora';
      if (diff.inMinutes < 60) return 'hace ${diff.inMinutes}m';
      if (diff.inHours < 24) return 'hace ${diff.inHours}h';
      if (diff.inDays == 1) return 'ayer';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return '';
    }
  }

  Future<void> _onTap(
      BuildContext context, Map<String, dynamic> notif) async {
    final id = notif['id'] as String? ?? '';
    final tipo = notif['tipo'] as String? ?? '';
    if (id.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(id)
          .update({'leido': true});
    }
    if (context.mounted) {
      Navigator.pushNamed(context, _routeForType(tipo));
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5EFE6),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4A3F30)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notificaciones',
          style: TextStyle(
            color: Color(0xFF4A3F30),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _stream(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFB5976A)),
            );
          }

          final notifs = snapshot.data ?? [];

          if (notifs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_outlined,
                    size: 64,
                    color: const Color(0xFFB5976A).withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Sin notificaciones por ahora',
                    style: TextStyle(
                        color: Color(0xFF9A8A75), fontSize: 15),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            itemCount: notifs.length,
            itemBuilder: (context, i) {
              final notif = notifs[i];
              final leido = notif['leido'] as bool? ?? false;
              final tipo = notif['tipo'] as String? ?? '';
              final tiempo = _relativeTime(notif['created_at']);

              return GestureDetector(
                onTap: () => _onTap(context, notif),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: leido
                        ? Colors.white
                        : const Color(0xFFF5E6C8),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFB5976A)
                            .withValues(alpha: 0.07),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFFB5976A)
                              .withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _iconForType(tipo),
                          color: const Color(0xFFB5976A),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _textForNotif(notif),
                              style: TextStyle(
                                fontSize: 13,
                                color: const Color(0xFF4A3F30),
                                fontWeight: leido
                                    ? FontWeight.normal
                                    : FontWeight.w600,
                                height: 1.4,
                              ),
                            ),
                            if (tiempo.isNotEmpty) ...[
                              const SizedBox(height: 3),
                              Text(
                                tiempo,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF9A8A75),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (!leido)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(top: 4),
                          decoration: const BoxDecoration(
                            color: Color(0xFFB5976A),
                            shape: BoxShape.circle,
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
      bottomNavigationBar: const BottomNavWidget(currentIndex: -1),
    );
  }
}
