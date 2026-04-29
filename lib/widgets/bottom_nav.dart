import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BottomNavWidget extends StatelessWidget {
  final int currentIndex;

  const BottomNavWidget({super.key, required this.currentIndex});

  static const List<IconData> _icons = [
    Icons.home_outlined,
    Icons.search_outlined,
    Icons.chat_bubble_outline,
    Icons.volunteer_activism,
    Icons.person_outline,
  ];

  static const List<String> _routes = [
    '/home',
    '/explore',
    '/chats-list',
    '/ong',
    '/profile',
  ];

  // Stream que suma todos los unread_<uid> de los chats del usuario actual
  Stream<int> _unreadStream() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const Stream.empty();
    return FirebaseFirestore.instance
        .collection('chats')
        .where('participants', arrayContains: uid)
        .snapshots()
        .map((snap) {
      int total = 0;
      for (final doc in snap.docs) {
        final data = doc.data();
        total += (data['unread_$uid'] as int? ?? 0);
      }
      return total;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_icons.length, (i) {
          final isSelected = currentIndex == i;
          final isChat = i == 2;

          Widget icon = Icon(
            _icons[i],
            color: isSelected
                ? const Color(0xFFB5976A)
                : const Color(0xFF9A8A75),
            size: 24,
          );

          // Badge de mensajes no leídos solo en el ícono de chat
          if (isChat) {
            icon = StreamBuilder<int>(
              stream: _unreadStream(),
              builder: (context, snapshot) {
                final unread = snapshot.data ?? 0;
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      _icons[i],
                      color: isSelected
                          ? const Color(0xFFB5976A)
                          : const Color(0xFF9A8A75),
                      size: 24,
                    ),
                    if (unread > 0)
                      Positioned(
                        top: -4,
                        right: -6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFFB5976A),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            unread > 99 ? '99+' : '$unread',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            );
          }

          return GestureDetector(
            onTap: () {
              if (i != currentIndex) {
                Navigator.pushReplacementNamed(context, _routes[i]);
              }
            },
            child: SizedBox(
              width: 52,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  icon,
                  const SizedBox(height: 4),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: isSelected ? 5 : 0,
                    height: isSelected ? 5 : 0,
                    decoration: const BoxDecoration(
                      color: Color(0xFFB5976A),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
