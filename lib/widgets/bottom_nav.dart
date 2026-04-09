import 'package:flutter/material.dart';

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
                  Icon(
                    _icons[i],
                    color: isSelected
                        ? const Color(0xFFB5976A)
                        : const Color(0xFF9A8A75),
                    size: 24,
                  ),
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
