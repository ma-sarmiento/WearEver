import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../widgets/bottom_nav.dart';
import '../services/firestore_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Separate controllers for each map to avoid conflict
  GoogleMapController? _viewMapController;
  GoogleMapController? _pickMapController;

  bool _isPicking = false;
  bool _initialized = false;

  LatLng _center = const LatLng(4.7110, -74.0721);
  LatLng? _pickedLocation;
  bool _loadingLocation = true;
  bool _geocoding = false;
  Map<String, String> _pickedAddress = {};
  Set<Marker> _viewMarkers = {};
  Set<Marker> _pickMarkers = {};

  List<Map<String, dynamic>> _ongs = [];

  // Optional: center on a specific ONG passed as argument
  String? _focusOngName;

  static const _disposalPoints = [
    {'name': 'Contenedor Verde', 'address': 'C.C. Andino, Cl. 82 #11-37', 'lat': 4.6677, 'lng': -74.0535},
    {'name': 'Punto Verde', 'address': 'Parque 93, Cl. 93A #11A-28', 'lat': 4.6766, 'lng': -74.0483},
    {'name': 'Recolección Chapinero', 'address': 'Éxito Chapinero, Cr. 13 #54-97', 'lat': 4.6483, 'lng': -74.0617},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _getCurrentLocation();
    _loadOngs();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      _isPicking = args['mode'] == 'pick';
      _focusOngName = args['ong_name'] as String?;
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        if (mounted) setState(() => _loadingLocation = false);
        return;
      }
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        if (mounted) setState(() => _loadingLocation = false);
        return;
      }
      final pos = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _center = LatLng(pos.latitude, pos.longitude);
          _loadingLocation = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingLocation = false);
    }
  }

  Future<void> _loadOngs() async {
    final ongs = await FirestoreService().getONGsStream().first;
    if (mounted) {
      setState(() {
        _ongs = ongs;
        _buildViewMarkers();
      });
    }
  }

  void _buildViewMarkers() {
    final markers = <Marker>{};
    for (final p in _disposalPoints) {
      markers.add(Marker(
        markerId: MarkerId(p['name'] as String),
        position: LatLng(p['lat'] as double, p['lng'] as double),
        infoWindow: InfoWindow(
            title: p['name'] as String, snippet: p['address'] as String),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ));
    }
    setState(() => _viewMarkers = markers);
  }

  Future<void> _updatePickMarker(LatLng pos) async {
    setState(() {
      _pickedLocation = pos;
      _geocoding = true;
      _pickedAddress = {};
      _pickMarkers = {
        Marker(
          markerId: const MarkerId('picked'),
          position: pos,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        ),
      };
    });

    // Reverse geocoding - get real address from coordinates
    try {
      final placemarks = await placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
      );

      if (placemarks.isNotEmpty && mounted) {
        final p = placemarks.first;
        // En Colombia, p.street ya incluye el número completo (ej: "Calle 80 #20-15").
        // p.subThoroughfare repite ese número, por lo que unirlos duplica el "#".
        // Usamos solo p.street; si está vacío, caemos en las coordenadas.
        final street = (p.street ?? '').trim();

        final address = street.isNotEmpty
            ? street
            : '${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}';

        final city = p.locality ?? p.administrativeArea ?? '';
        final postal = p.postalCode ?? '';

        setState(() {
          _pickedAddress = {
            'address': address,
            'city': city,
            'postal': postal,
          };
          _geocoding = false;
          _pickMarkers = {
            Marker(
              markerId: const MarkerId('picked'),
              position: pos,
              infoWindow: InfoWindow(title: address, snippet: city),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
            ),
          };
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _pickedAddress = {
            'address': '${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}',
            'city': '',
            'postal': '',
          };
          _geocoding = false;
        });
      }
    }
  }

  void _confirmPick() {
    if (_pickedLocation == null || _geocoding) return;
    Navigator.pop(context, {
      'address': _pickedAddress['address'] ?? '',
      'city': _pickedAddress['city'] ?? '',
      'postal': _pickedAddress['postal'] ?? '',
      'lat': _pickedLocation!.latitude,
      'lng': _pickedLocation!.longitude,
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _viewMapController?.dispose();
    _pickMapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isPicking ? _buildPickerMode() : _buildViewMode();
  }

  // ─── PICKER MODE ──────────────────────────────────────────
  Widget _buildPickerMode() {
    return Scaffold(
      body: Stack(children: [
        _loadingLocation
            ? const Center(
            child: CircularProgressIndicator(color: Color(0xFFB5976A)))
            : GoogleMap(
          initialCameraPosition:
          CameraPosition(target: _center, zoom: 15),
          onMapCreated: (c) => _pickMapController = c,
          onTap: _updatePickMarker,
          markers: _pickMarkers,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          zoomControlsEnabled: true,
          scrollGesturesEnabled: true,
          zoomGesturesEnabled: true,
          rotateGesturesEnabled: true,
          tiltGesturesEnabled: true,
        ),
        // Top instruction bar
        Positioned(
          top: 0, left: 0, right: 0,
          child: SafeArea(
            child: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.12), blurRadius: 8)
                ],
              ),
              child: Row(children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back, color: Color(0xFF4A3F30)),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text('Toca el mapa para seleccionar tu dirección',
                      style: TextStyle(
                          color: Color(0xFF4A3F30),
                          fontSize: 13,
                          fontWeight: FontWeight.w500)),
                ),
              ]),
            ),
          ),
        ),
        // Address preview + confirm button
        if (_pickedLocation != null)
          Positioned(
            bottom: 24, left: 16, right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_geocoding)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6)],
                    ),
                    child: const Row(children: [
                      SizedBox(width: 16, height: 16,
                          child: CircularProgressIndicator(color: Color(0xFFB5976A), strokeWidth: 2)),
                      SizedBox(width: 10),
                      Text('Obteniendo dirección...', style: TextStyle(color: Color(0xFF9A8A75), fontSize: 13)),
                    ]),
                  )
                else if (_pickedAddress['address'] != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6)],
                    ),
                    child: Row(children: [
                      const Icon(Icons.location_on, color: Color(0xFFB5976A), size: 18),
                      const SizedBox(width: 8),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(_pickedAddress['address'] ?? '',
                            style: const TextStyle(color: Color(0xFF4A3F30), fontSize: 13, fontWeight: FontWeight.w500)),
                        if ((_pickedAddress['city'] ?? '').isNotEmpty)
                          Text(_pickedAddress['city']!,
                              style: const TextStyle(color: Color(0xFF9A8A75), fontSize: 12)),
                      ])),
                    ]),
                  ),
                ElevatedButton.icon(
                  onPressed: (_geocoding) ? null : _confirmPick,
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: const Text('Confirmar dirección',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB5976A),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFB5976A).withOpacity(0.4),
                    elevation: 0,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ],
            ),
          ),
      ]),
    );
  }

  // ─── VIEW MODE ────────────────────────────────────────────
  Widget _buildViewMode() {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5EFE6),
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4A3F30)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Mapa',
            style: TextStyle(
                color: Color(0xFF4A3F30),
                fontSize: 18,
                fontWeight: FontWeight.w600)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFB5976A),
          unselectedLabelColor: const Color(0xFF9A8A75),
          indicatorColor: const Color(0xFFB5976A),
          tabs: const [Tab(text: 'Mapa'), Tab(text: 'Lista')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(), // prevent TabBarView from stealing map gestures
        children: [
          // ── Map tab
          _loadingLocation
              ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFB5976A)))
              : GoogleMap(
            initialCameraPosition:
            CameraPosition(target: _center, zoom: 13),
            onMapCreated: (c) {
              _viewMapController = c;
              // If we were asked to focus on a specific ONG, we'd
              // animate to it here when markers are ready
            },
            markers: _viewMarkers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: true,
            scrollGesturesEnabled: true,
            zoomGesturesEnabled: true,
            rotateGesturesEnabled: true,
            tiltGesturesEnabled: true,
          ),
          // ── List tab
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _sectionTitle('Puntos de recolección de ropa'),
              const SizedBox(height: 10),
              ..._disposalPoints.map((p) => _listTile(
                name: p['name'] as String,
                subtitle: p['address'] as String,
                icon: Icons.recycling,
                color: const Color(0xFF10B981),
                onTap: () {
                  _tabController.animateTo(0);
                  _viewMapController?.animateCamera(
                    CameraUpdate.newLatLngZoom(
                      LatLng(p['lat'] as double, p['lng'] as double),
                      16,
                    ),
                  );
                },
              )),
              const SizedBox(height: 20),
              _sectionTitle('Fundaciones registradas'),
              const SizedBox(height: 10),
              if (_ongs.isEmpty)
                const Text('Sin fundaciones registradas aún.',
                    style: TextStyle(color: Color(0xFF9A8A75), fontSize: 13))
              else
                ..._ongs.map((ong) => _listTile(
                  name: ong['nombre_fundacion'] as String? ?? 'ONG',
                  subtitle: ong['ciudad'] as String? ?? '',
                  icon: Icons.volunteer_activism,
                  color: const Color(0xFFB5976A),
                )),
            ],
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavWidget(currentIndex: 3),
    );
  }

  Widget _sectionTitle(String t) => Text(t,
      style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF4A3F30)));

  Widget _listTile({
    required String name,
    required String subtitle,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFFB5976A).withOpacity(0.07),
                blurRadius: 8,
                offset: const Offset(0, 3))
          ],
        ),
        child: Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4A3F30))),
                  if (subtitle.isNotEmpty)
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF9A8A75))),
                ]),
          ),
          if (onTap != null)
            const Icon(Icons.location_on_outlined,
                size: 16, color: Color(0xFFB5976A)),
        ]),
      ),
    );
  }
}