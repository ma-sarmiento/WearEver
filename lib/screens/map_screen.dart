import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _nearbyONGs = [
    {
      'name': 'ONG Trabajemos',
      'address': 'Cra 13 # 45-22, Bogotá',
      'time': 'hace 2m',
      'color': const Color(0xFFD4B896),
    },
    {
      'name': 'Fundación Vístete',
      'address': 'Cl. 72 # 9-41, Bogotá',
      'time': 'hace 15m',
      'color': const Color(0xFFB5976A),
    },
  ];

  final List<Map<String, dynamic>> _disposalPoints = [
    {
      'name': 'Contenedor Verde',
      'location': 'C.C. Andino',
      'address': 'Cl. 82 #11-37, Bogotá',
      'schedule': 'Lun–Dom  10am–8pm',
    },
    {
      'name': 'Punto Verde',
      'location': 'Parque 93',
      'address': 'Cl. 93A #11A-28, Bogotá',
      'schedule': 'Lun–Sáb  8am–6pm',
    },
    {
      'name': 'Recolección',
      'location': 'Éxito Chapinero',
      'address': 'Cr. 13 #54-97, Bogotá',
      'schedule': 'Lun–Dom  9am–9pm',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      body: Stack(
        children: [
          _buildMapPlaceholder(),
          _buildTopBar(),
          _buildBottomSheet(),
        ],
      ),
      bottomNavigationBar: const BottomNavWidget(currentIndex: 3),
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
            // ONG pins (brown)
            Positioned(
              top: MediaQuery.of(context).size.height * 0.28,
              left: MediaQuery.of(context).size.width * 0.45,
              child: _buildMapPin(const Color(0xFFB5976A), Icons.volunteer_activism),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.35,
              left: MediaQuery.of(context).size.width * 0.3,
              child: _buildMapPin(const Color(0xFFB5976A), Icons.volunteer_activism),
            ),
            // Disposal pins (green)
            Positioned(
              top: MediaQuery.of(context).size.height * 0.22,
              left: MediaQuery.of(context).size.width * 0.6,
              child: _buildMapPin(const Color(0xFF4CAF50), Icons.recycling),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.4,
              left: MediaQuery.of(context).size.width * 0.55,
              child: _buildMapPin(const Color(0xFF4CAF50), Icons.recycling),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.18,
              left: MediaQuery.of(context).size.width * 0.25,
              child: _buildMapPin(const Color(0xFF4CAF50), Icons.recycling),
            ),
            // Map labels
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
            // Legend
            Positioned(
              bottom: MediaQuery.of(context).size.height * 0.33,
              right: 14,
              child: _buildLegend(),
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

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLegendItem(const Color(0xFFB5976A), Icons.volunteer_activism, 'ONG'),
          const SizedBox(height: 6),
          _buildLegendItem(const Color(0xFF4CAF50), Icons.recycling, 'Disposición'),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white, size: 11),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF4A3F30))),
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
                  child: const Row(
                    children: [
                      SizedBox(width: 12),
                      Icon(Icons.search, color: Color(0xFFB5976A), size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Buscar ONGs y puntos de disposición...',
                        style:
                            TextStyle(color: Color(0xFFB0A090), fontSize: 13),
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
      initialChildSize: 0.3,
      minChildSize: 0.15,
      maxChildSize: 0.65,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black12, blurRadius: 12, offset: Offset(0, -3)),
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
              const SizedBox(height: 8),
              // TabBar
              TabBar(
                controller: _tabController,
                indicatorColor: const Color(0xFFB5976A),
                labelColor: const Color(0xFFB5976A),
                unselectedLabelColor: const Color(0xFF9A8A75),
                indicatorSize: TabBarIndicatorSize.label,
                labelStyle: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600),
                tabs: const [
                  Tab(text: 'ONGs'),
                  Tab(text: 'Puntos de disposición'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildONGList(scrollController),
                    _buildDisposalList(scrollController),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildONGList(ScrollController scrollController) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      itemCount: _nearbyONGs.length,
      itemBuilder: (context, index) => _buildONGCard(_nearbyONGs[index]),
    );
  }

  Widget _buildONGCard(Map<String, dynamic> ong) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/ong'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
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
                  color: Colors.white, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ong['name'],
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0xFF4A3F30))),
                  Text(ong['address'],
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF9A8A75))),
                ],
              ),
            ),
            Text(ong['time'],
                style:
                    const TextStyle(fontSize: 11, color: Color(0xFF9A8A75))),
          ],
        ),
      ),
    );
  }

  Widget _buildDisposalList(ScrollController scrollController) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      itemCount: _disposalPoints.length,
      itemBuilder: (context, index) =>
          _buildDisposalCard(_disposalPoints[index]),
    );
  }

  Widget _buildDisposalCard(Map<String, dynamic> point) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
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
            decoration: const BoxDecoration(
              color: Color(0xFF4CAF50),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.recycling, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: point['name'],
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Color(0xFF4A3F30)),
                      ),
                      TextSpan(
                        text: ' · ${point['location']}',
                        style: const TextStyle(
                            fontSize: 13, color: Color(0xFF9A8A75)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(point['address'],
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFF9A8A75))),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.access_time_outlined,
                        size: 11, color: Color(0xFF4CAF50)),
                    const SizedBox(width: 3),
                    Text(point['schedule'],
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFF4CAF50))),
                  ],
                ),
              ],
            ),
          ),
        ],
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
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    for (double x = 0; x < size.width; x += 60) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    paint.color = const Color(0xFFBFAF95).withOpacity(0.7);
    paint.strokeWidth = 3;
    canvas.drawLine(Offset(0, size.height * 0.35),
        Offset(size.width, size.height * 0.35), paint);
    canvas.drawLine(Offset(size.width * 0.4, 0),
        Offset(size.width * 0.4, size.height), paint);
    canvas.drawLine(Offset(0, size.height * 0.55),
        Offset(size.width, size.height * 0.55), paint);
    canvas.drawLine(Offset(size.width * 0.65, 0),
        Offset(size.width * 0.65, size.height), paint);
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
