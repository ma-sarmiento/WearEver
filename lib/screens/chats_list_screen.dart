import 'package:flutter/material.dart';

class ChatsListScreen extends StatefulWidget {
  const ChatsListScreen({super.key});

  @override
  State<ChatsListScreen> createState() => _ChatsListScreenState();
}

class _ChatsListScreenState extends State<ChatsListScreen> {
  int _selectedIndex = 2;
  String _selectedFilter = 'Todos';

  final List<String> _filters = ['Todos', 'No leídos', 'Tiendas', 'Clientes'];

  final List<Map<String, dynamic>> _chats = [
    {
      'name': 'Hilo (IA)',
      'initial': 'H',
      'lastMsg': '¿Necesitas algún consejo?',
      'time': '',
      'badge': 'Fijado',
      'unread': 0,
      'isAi': true,
      'route': '/chat',
    },
    {
      'name': 'Jhon Nova',
      'initial': 'J',
      'lastMsg': 'Claro, te paso medidas...',
      'time': 'hace 3h',
      'badge': '',
      'unread': 7,
      'isAi': false,
      'route': '/chat',
    },
    {
      'name': 'Laura H.',
      'initial': 'L',
      'lastMsg': 'Perfecto, gracias :)',
      'time': 'Ayr',
      'badge': '',
      'unread': 0,
      'isAi': false,
      'route': '/chat',
    },
    {
      'name': 'Juan Urbano',
      'initial': 'Ju',
      'lastMsg': 'Hicimos el envío hoy',
      'time': '31 Ago',
      'badge': '',
      'unread': 2,
      'isAi': false,
      'route': '/chat',
    },
    {
      'name': 'Carlos D.',
      'initial': 'C',
      'lastMsg': '¿A qué talla te va en azul?',
      'time': '22 Ago',
      'badge': '',
      'unread': 0,
      'isAi': false,
      'route': '/chat',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5EFE6),
        elevation: 0,
        title: const Text('Chats',
            style: TextStyle(color: Color(0xFF4A3F30), fontSize: 20, fontWeight: FontWeight.w600)),
        centerTitle: false,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          Expanded(child: _buildChatList()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: const Color(0xFFB5976A),
        foregroundColor: Colors.white,
        elevation: 2,
        icon: const Icon(Icons.edit_outlined, size: 18),
        label: const Text('Nuevo chat', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
        child: const Row(
          children: [
            SizedBox(width: 12),
            Icon(Icons.search, color: Color(0xFFB5976A), size: 20),
            SizedBox(width: 8),
            Text('Buscar chat o usuario...',
                style: TextStyle(color: Color(0xFFB0A090), fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = filter),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFB5976A) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? const Color(0xFFB5976A) : const Color(0xFFE0D0BC),
                ),
              ),
              child: Text(filter,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? Colors.white : const Color(0xFF7A6A55))),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChatList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _chats.length,
      itemBuilder: (context, index) => _buildChatTile(_chats[index]),
    );
  }

  Widget _buildChatTile(Map<String, dynamic> chat) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, chat['route']),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFFB5976A).withOpacity(0.07),
                blurRadius: 6,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: chat['isAi'] ? const Color(0xFF3D3025) : const Color(0xFFD4B896),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  chat['initial'],
                  style: TextStyle(
                      color: chat['isAi'] ? Colors.white : const Color(0xFFB5976A),
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(chat['name'],
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF4A3F30))),
                      const SizedBox(width: 6),
                      if (chat['badge'].isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFB5976A).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(chat['badge'],
                              style: const TextStyle(
                                  fontSize: 10, color: Color(0xFFB5976A), fontWeight: FontWeight.w500)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(chat['lastMsg'],
                      style: const TextStyle(fontSize: 12, color: Color(0xFF9A8A75)),
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Time & unread
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (chat['time'].isNotEmpty)
                  Text(chat['time'],
                      style: const TextStyle(fontSize: 11, color: Color(0xFF9A8A75))),
                const SizedBox(height: 4),
                if (chat['unread'] > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: const BoxDecoration(
                      color: Color(0xFFB5976A),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Text(
                      '${chat['unread']}',
                      style: const TextStyle(
                          color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    final items = [
      Icons.home_outlined,
      Icons.search_outlined,
      Icons.chat_bubble_outline,
      Icons.grid_view_outlined,
      Icons.person_outline,
    ];
    return Container(
      height: 65,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final isSelected = _selectedIndex == i;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedIndex = i);
              if (i == 0) Navigator.pushReplacementNamed(context, '/home');
              if (i == 1) Navigator.pushReplacementNamed(context, '/explore');
              if (i == 3) Navigator.pushReplacementNamed(context, '/saved');
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: isSelected
                  ? BoxDecoration(
                      color: const Color(0xFFB5976A).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    )
                  : null,
              child: Icon(items[i],
                  color: isSelected ? const Color(0xFFB5976A) : const Color(0xFF9A8A75), size: 24),
            ),
          );
        }),
      ),
    );
  }
}
