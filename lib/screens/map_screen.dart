import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../widgets/bottom_nav.dart';
import '../services/firestore_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  GoogleMapController? _mapController;

  // Mode: 'view' = normal map, 'pick' = picking an address
  late bool _isPicking;

  LatLng _center = const LatLng(4.7110, -74.0721); // Bogotá default
  LatLng? _pickedLocation;
  bool _loadingLocation = true;
  Set<Marker> _markers = {};

  // ONGs from Firestore
  List<Map<String, dynamic>> _ongs = [];

  static const _disposalPoints = [
    {'name': 'Contenedor Verde', 'location': 'C.C. Andino', 'address': 'Cl. 82 #11-37, Bogotá', 'lat': 4.6677, 'lng': -74.0535},
    {'name': 'Punto Verde', 'location': 'Parque 93', 'address': 'Cl. 93A #11A-28, Bogotá', 'lat': 4.6766, 'lng': -74.0483},
    {'name': 'Recolección', 'location': 'Éxito Chapinero', 'address': 'Cr. 13 #54-97, Bogotá', 'lat': 4.6483, 'lng': -74.0617},
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
    final args = ModalRoute.of(context)?.settings.arguments;
    _isPicking = args is Map && args['mode'] == 'pick';
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) { setState(() => _loadingLocation = false); return; }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) { setState(() => _loadingLocation = false); return; }
      }
      if (permission == LocationPermission.deniedForever) { setState(() => _loadingLocation = false); return; }

      final pos = await Geolocator.getCurrentPosition();
      if (mounted) setState(() {
        _center = LatLng(pos.latitude, pos.longitude);
        _loadingLocation = false;
      });
      _mapController?.animateCamera(CameraUpdate.newLatLng(_center));
    } catch (_) {
      if (mounted) setState(() => _loadingLocation = false);
    }
  }

  Future<void> _loadOngs() async {
    final ongs = await FirestoreService().getONGsStream().first;
    if (mounted) {
      setState(() {
        _ongs = ongs;
        _buildMarkers();
      });
    }
  }

  void _buildMarkers() {
    final markers = <Marker>{};
    for (final point in _disposalPoints) {
      markers.add(Marker(
        markerId: MarkerId(point['name'] as String),
        position: LatLng(point['lat'] as double, point['lng'] as double),
        infoWindow: InfoWindow(title: point['name'] as String, snippet: point['address'] as String),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ));
    }
    if (_pickedLocation != null) {
      markers.add(Marker(
        markerId: const MarkerId('picked'),
        position: _pickedLocation!,
        infoWindow: const InfoWindow(title: 'Dirección seleccionada'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      ));
    }
    setState(() => _markers = markers);
  }

  void _onMapTap(LatLng pos) {
    if (!_isPicking) return;
    setState(() {
      _pickedLocation = pos;
      _buildMarkers();
    });
  }

  void _confirmPick() {
    if (_pickedLocation == null) return;
    Navigator.pop(context, {
      'lat': _pickedLocation!.latitude,
      'lng': _pickedLocation!.longitude,
      'address': '${_pickedLocation!.latitude.toStringAsFixed(5)}, ${_pickedLocation!.longitude.toStringAsFixed(5)}',
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      body: _isPicking ? _buildPickerMode() : _buildViewMode(),
    );
  }

  Widget _buildPickerMode() {
    return Stack(children: [
      _loadingLocation
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFB5976A)))
          : GoogleMap(
              initialCameraPosition: CameraPosition(target: _center, zoom: 14),
              onMapCreated: (c) => _mapController = c,
              onTap: _onMapTap,
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
      // Top bar
      Positioned(
        top: 0, left: 0, right: 0,
        child: SafeArea(
          child: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 8)],
            ),
            child: Row(children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back, color: Color(0xFF4A3F30)),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('Toca el mapa para seleccionar tu dirección',
                    style: TextStyle(color: Color(0xFF4A3F30), fontSize: 13, fontWeight: FontWeight.w500)),
              ),
            ]),
          ),
        ),
      ),
      // Confirm button
      if (_pickedLocation != null)
        Positioned(
          bottom: 24, left: 16, right: 16,
          child: ElevatedButton.icon(
            onPressed: _confirmPick,
            icon: const Icon(Icons.check, size: 18),
            label: const Text('Confirmar ubicación',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB5976A),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
    ]);
  }

  Widget _buildViewMode() {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5EFE6),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Mapa', style: TextStyle(color: Color(0xFF4A3F30), fontSize: 18, fontWeight: FontWeight.w600)),
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
        children: [
          // Map tab
          _loadingLocation
              ? const Center(child: CircularProgressIndicator(color: Color(0xFFB5976A)))
              : GoogleMap(
                  initialCameraPosition: CameraPosition(target: _center, zoom: 13),
                  onMapCreated: (c) => _mapController = c,
                  markers: _markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                ),
          // List tab
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text('Puntos de recolección',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF4A3F30))),
              const SizedBox(height: 10),
              ..._disposalPoints.map((p) => _buildListTile(
                name: p['name'] as String,
                subtitle: p['address'] as String,
                icon: Icons.recycling,
                color: const Color(0xFF10B981),
              )),
              const SizedBox(height: 16),
              const Text('Fundaciones cercanas',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF4A3F30))),
              const SizedBox(height: 10),
              if (_ongs.isEmpty)
                const Text('Cargando fundaciones...', style: TextStyle(color: Color(0xFF9A8A75), fontSize: 13))
              else
                ..._ongs.map((ong) => _buildListTile(
                  name: ong['nombre_fundacion'] as String? ?? 'ONG',
                  subtitle: ong['ciudad'] as String? ?? ong['email'] as String? ?? '',
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

  Widget _buildListTile({required String name, required String subtitle, required IconData icon, required Color color}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: const Color(0xFFB5976A).withOpacity(0.07), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF4A3F30))),
          if (subtitle.isNotEmpty)
            Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF9A8A75))),
        ])),
      ]),
    );
  }
}
