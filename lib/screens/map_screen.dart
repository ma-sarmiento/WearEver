import 'package:flutter/material.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  int _selectedIndex = 3;

  final List<Map<String, dynamic>> _nearbyONGs = [
    {
      'name': 'ONG',
      'time': 'hace 2m',
      'color': const Color(0xFFD4B896),
    },
    {
      'name': 'Fundación Vistete',
      'time': 'hace 15m',
      'color': const Color(0xFFB8D4E8),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      body: Stack(
        children: [
          // Map placeholder
          _buildMapPlaceholder(),
          // Top search bar
          _buildTopBar(),
          // Bottom sheet with ONG list
          _buildBottomSheet(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildMapPlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFFE8E0D0),
      child: CustomPaint(
        painter: _MapGridPainter(),
        child: Stack(
          children: [
            // Fake map streets
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.map_outlined,
                      size: 60, color: Color(0xFFB5976A)),
                  const SizedBox(height: 8),
                  Text(
                    'Mapa de ubicaciones',
                    style: TextStyle(
                      color: const Color(0xFF9A8A75).withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            // Map pins
            Positioned(
              top: MediaQuery.of(context).size.height * 0.28,
              left: MediaQuery.of(context).size.width * 0.45,
              child: _buildMapPin(const Color(0xFF4A90D9), Icons.store),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.35,
              left: MediaQuery.of(context).size.width * 0.3,
              child: _buildMapPin(const Color(0xFFB5976A), Icons.volunteer_activism),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.22,
              left: MediaQuery.of(context).size.width * 0.6,
              child: _buildMapPin(const Color(0xFF4CAF50), Icons.store),
            ),
            // Location labels
            Positioned(
              top: MediaQuery.of(context).size.height * 0.12,
              left: 30,
              child: _buildLocationLabel('TURINGIA'),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.12,
              right: 30,
              child: _buildLocationLabel('PINAR'),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.22,
              left: 20,
              child: _buildLocationLabel('EL POA'),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.3,
              left: 30,
              child: _buildLocationLabel('ANTONIO\nGRANADOS'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapPin(Color color, IconData icon) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        CustomPaint(
          painter: _PinTrianglePainter(color),
          size: const Size(12, 8),
        ),
      ],
    );
  }

  Widget _buildLocationLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF7A6A55).withOpacity(0.6),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.arrow_back,
                      size: 18, color: Color(0xFF4A3F30)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    children: const [
                      SizedBox(width: 12),
                      Icon(Icons.search, color: Color(0xFFB5976A), size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Buscar pedido, comprador...',
                        style: TextStyle(
                          color: Color(0xFFB0A090),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 0.22,
      minChildSize: 0.15,
      maxChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 12,
                offset: Offset(0, -3),
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0D0BC),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  itemCount: _nearbyONGs.length,
                  itemBuilder: (context, index) {
                    return _buildONGCard(_nearbyONGs[index]);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildONGCard(Map<String, dynamic> ong) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/ong'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFF5EFE6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0D0BC)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: ong['color'],
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.volunteer_activism,
                  color: Color(0xFFB5976A), size: 22),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ong['name'],
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Color(0xFF4A3F30))),
                Text(ong['time'],
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF9A8A75))),
              ],
            ),
            const Spacer(),
            Container(
              width: 50,
              height: 40,
              decoration: BoxDecoration(
                color: ong['color'],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.image_outlined,
                  color: Colors.white54, size: 20),
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
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2)),
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
                  color: isSelected
                      ? const Color(0xFFB5976A)
                      : const Color(0xFF9A8A75),
                  size: 24),
            ),
          );
        }),
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4C4A8).withOpacity(0.5)
      ..strokeWidth = 1;

    // Horizontal lines
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    // Vertical lines
    for (double x = 0; x < size.width; x += 60) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Thicker "roads"
    paint.color = const Color(0xFFBFAF95).withOpacity(0.7);
    paint.strokeWidth = 3;
    canvas.drawLine(
        Offset(0, size.height * 0.35), Offset(size.width, size.height * 0.35), paint);
    canvas.drawLine(
        Offset(size.width * 0.4, 0), Offset(size.width * 0.4, size.height), paint);
    canvas.drawLine(
        Offset(0, size.height * 0.55), Offset(size.width, size.height * 0.55), paint);
    canvas.drawLine(
        Offset(size.width * 0.65, 0), Offset(size.width * 0.65, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PinTrianglePainter extends CustomPainter {
  final Color color;
  _PinTrianglePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}