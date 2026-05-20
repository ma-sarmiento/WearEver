import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';

class CreateOngPostScreen extends StatefulWidget {
  const CreateOngPostScreen({super.key});

  @override
  State<CreateOngPostScreen> createState() => _CreateOngPostScreenState();
}

class _CreateOngPostScreenState extends State<CreateOngPostScreen> {
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _ciudadController = TextEditingController();
  final _direccionController = TextEditingController();

  final List<File> _photos = [];
  final Set<String> _selectedTipos = {};
  String? _cantidad;
  DateTime? _fechaLimite;
  DateTime? _fechaEvento;
  String _tipoPost = 'donacion';
  bool _isLoading = false;

  final _firestoreService = FirestoreService();
  final _storageService = StorageService();

  final List<String> _tiposRopa = [
    'Camisas',
    'Pantalones',
    'Vestidos',
    'Abrigos',
    'Zapatos',
    'Accesorios',
    'Ropa deportiva',
    'Ropa infantil',
    'Ropa interior',
    'Otros',
  ];

  final List<String> _cantidades = ['1-10', '10-20', '20-50', '50-100', '100+'];

  final List<Map<String, dynamic>> _tiposPost = [
    {
      'id': 'donacion',
      'label': 'Donación',
      'icon': Icons.volunteer_activism,
      'hint': 'Cuéntanos qué tipo de ropa necesitan y para quién...',
    },
    {
      'id': 'evento',
      'label': 'Evento',
      'icon': Icons.event,
      'hint': 'Describe el evento y cómo pueden participar...',
    },
    {
      'id': 'campana',
      'label': 'Campaña',
      'icon': Icons.campaign,
      'hint': 'Comparte los detalles de tu campaña...',
    },
  ];

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _ciudadController.dispose();
    _direccionController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    if (_photos.length >= 3) return;
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) setState(() => _photos.add(File(picked.path)));
  }

  Future<void> _pickFechaLimite() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) => _datePickerTheme(context, child!),
    );
    if (picked != null) setState(() => _fechaLimite = picked);
  }

  Future<void> _pickFechaEvento() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) => _datePickerTheme(context, child!),
    );
    if (picked != null) setState(() => _fechaEvento = picked);
  }

  Widget _datePickerTheme(BuildContext context, Widget child) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: const ColorScheme.light(
          primary: Color(0xFFB5976A),
          onPrimary: Colors.white,
          surface: Colors.white,
          onSurface: Color(0xFF4A3F30),
        ),
      ),
      child: child,
    );
  }

  Future<void> _submit() async {
    if (_tituloController.text.trim().isEmpty) {
      _showError('Ingresa un título para la publicación');
      return;
    }
    if (_descripcionController.text.trim().isEmpty) {
      _showError('Ingresa una descripción');
      return;
    }
    if (_tipoPost == 'donacion' && _selectedTipos.isEmpty) {
      _showError('Selecciona al menos un tipo de ropa que necesitan');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final storageId = DateTime.now().millisecondsSinceEpoch.toString();
      final List<String> photoUrls = [];
      for (final photo in _photos) {
        final url = await _storageService.uploadOngPostPhoto(photo, storageId);
        photoUrls.add(url);
      }

      final uid = FirebaseAuth.instance.currentUser?.uid;
      final ongDoc = await FirebaseFirestore.instance
          .collection('ongs')
          .doc(uid)
          .get();
      final ongData = ongDoc.data() ?? {};

      final Map<String, dynamic> postData = {
        'tipo_post': _tipoPost,
        'titulo': _tituloController.text.trim(),
        'descripcion': _descripcionController.text.trim(),
        'fotos': photoUrls,
        'ong_nombre': ongData['nombre_fundacion'] ?? '',
        'ong_logo': ongData['logo_url'] ?? '',
      };

      if (_tipoPost == 'donacion') {
        postData['tipos_ropa'] = _selectedTipos.toList();
        postData['cantidad'] = _cantidad ?? '';
        postData['ciudad'] = _ciudadController.text.trim();
        postData['direccion'] = _direccionController.text.trim();
        if (_fechaLimite != null) {
          postData['fecha_limite'] = Timestamp.fromDate(_fechaLimite!);
        }
      } else if (_tipoPost == 'evento') {
        postData['ciudad'] = _ciudadController.text.trim();
        postData['direccion'] = _direccionController.text.trim();
        if (_fechaEvento != null) {
          postData['fecha_evento'] = Timestamp.fromDate(_fechaEvento!);
        }
      }

      await _firestoreService.createOngPost(postData);

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) _showError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: const Color(0xFFD32F2F)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentTipo = _tiposPost.firstWhere((t) => t['id'] == _tipoPost);
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5EFE6),
        elevation: 0,
        title: const Text(
          'Nueva publicación',
          style: TextStyle(
            color: Color(0xFF4A3F30),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF4A3F30)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: TextButton(
              onPressed: _isLoading ? null : _submit,
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFB5976A),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Publicar',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTipoSelector(),
            const SizedBox(height: 20),
            _buildPhotoSection(),
            const SizedBox(height: 20),
            _buildLabel('Título *'),
            const SizedBox(height: 6),
            _buildTextField(
              _tituloController,
              'Ej. ${_tipoPost == 'donacion' ? 'Necesitamos ropa de invierno para familias' : _tipoPost == 'evento' ? 'Feria de ropa solidaria' : 'Campaña de reciclaje textil'}',
            ),
            const SizedBox(height: 16),
            _buildLabel('Descripción *'),
            const SizedBox(height: 6),
            _buildDescriptionField(currentTipo['hint'] as String),
            const SizedBox(height: 16),
            if (_tipoPost == 'donacion') ..._buildDonacionFields(),
            if (_tipoPost == 'evento') ..._buildEventoFields(),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildTipoSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipo de publicación',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF9A8A75),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: _tiposPost.map((tipo) {
            final isSelected = _tipoPost == tipo['id'];
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() {
                  _tipoPost = tipo['id'] as String;
                  _selectedTipos.clear();
                  _cantidad = null;
                  _fechaLimite = null;
                  _fechaEvento = null;
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: EdgeInsets.only(
                    right: tipo['id'] != 'campana' ? 8 : 0,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFB5976A)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFB5976A)
                          : const Color(0xFFE0D0BC),
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color:
                                  const Color(0xFFB5976A).withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            )
                          ]
                        : [],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        tipo['icon'] as IconData,
                        size: 22,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFFB5976A),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        tipo['label'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color:
                              isSelected ? Colors.white : const Color(0xFF4A3F30),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Imágenes',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF4A3F30),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '(opcional, máx. 3)',
              style: TextStyle(
                  fontSize: 12,
                  color: const Color(0xFF9A8A75).withValues(alpha: 0.8)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              ..._photos.asMap().entries.map((e) => _buildPhotoThumb(e.key, e.value)),
              if (_photos.length < 3) _buildAddPhotoButton(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoThumb(int index, File photo) {
    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          margin: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(
              image: FileImage(photo),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 14,
          child: GestureDetector(
            onTap: () => setState(() => _photos.removeAt(index)),
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Color(0xFFD32F2F),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddPhotoButton() {
    return GestureDetector(
      onTap: _pickPhoto,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE0D0BC)),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate_outlined,
                color: Color(0xFFB5976A), size: 30),
            SizedBox(height: 4),
            Text('Agregar',
                style: TextStyle(color: Color(0xFF9A8A75), fontSize: 11)),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDonacionFields() {
    return [
      _buildLabel('¿Qué tipo de ropa necesitan? *'),
      const SizedBox(height: 8),
      _buildTiposChips(),
      const SizedBox(height: 16),
      _buildLabel('Cantidad de prendas'),
      const SizedBox(height: 6),
      _buildCantidadDropdown(),
      const SizedBox(height: 16),
      _buildLabel('Ciudad de entrega'),
      const SizedBox(height: 6),
      _buildTextField(_ciudadController, 'Ej. Bogotá'),
      const SizedBox(height: 16),
      _buildLabel('Dirección de entrega'),
      const SizedBox(height: 6),
      _buildTextField(_direccionController, 'Ej. Carrera 7 # 43-12, piso 3'),
      const SizedBox(height: 16),
      _buildLabel('Fecha límite de donación'),
      const SizedBox(height: 6),
      _buildDateButton(
        date: _fechaLimite,
        hint: 'Seleccionar fecha límite',
        onTap: _pickFechaLimite,
      ),
      const SizedBox(height: 16),
    ];
  }

  List<Widget> _buildEventoFields() {
    return [
      _buildLabel('Ciudad'),
      const SizedBox(height: 6),
      _buildTextField(_ciudadController, 'Ej. Medellín'),
      const SizedBox(height: 16),
      _buildLabel('Lugar o dirección'),
      const SizedBox(height: 6),
      _buildTextField(_direccionController, 'Ej. Parque El Poblado'),
      const SizedBox(height: 16),
      _buildLabel('Fecha del evento'),
      const SizedBox(height: 6),
      _buildDateButton(
        date: _fechaEvento,
        hint: 'Seleccionar fecha del evento',
        onTap: _pickFechaEvento,
      ),
      const SizedBox(height: 16),
    ];
  }

  Widget _buildTiposChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _tiposRopa.map((tipo) {
        final isSelected = _selectedTipos.contains(tipo);
        return GestureDetector(
          onTap: () => setState(() {
            if (isSelected) {
              _selectedTipos.remove(tipo);
            } else {
              _selectedTipos.add(tipo);
            }
          }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFB5976A) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFFB5976A)
                    : const Color(0xFFE0D0BC),
              ),
            ),
            child: Text(
              tipo,
              style: TextStyle(
                fontSize: 13,
                color: isSelected ? Colors.white : const Color(0xFF4A3F30),
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCantidadDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border:
            Border.all(color: const Color(0xFFB5976A).withValues(alpha: 0.2)),
      ),
      child: DropdownButton<String>(
        value: _cantidad,
        hint: const Text('Seleccionar rango',
            style: TextStyle(color: Color(0xFFB0A090), fontSize: 14)),
        isExpanded: true,
        underline: const SizedBox.shrink(),
        style: const TextStyle(color: Color(0xFF4A3F30), fontSize: 14),
        items: _cantidades
            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
            .toList(),
        onChanged: (val) => setState(() => _cantidad = val),
      ),
    );
  }

  Widget _buildDateButton({
    required DateTime? date,
    required String hint,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border:
              Border.all(color: const Color(0xFFB5976A).withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined,
                color: Color(0xFFB5976A), size: 18),
            const SizedBox(width: 10),
            Text(
              date != null
                  ? '${date.day}/${date.month}/${date.year}'
                  : hint,
              style: TextStyle(
                color: date != null
                    ? const Color(0xFF4A3F30)
                    : const Color(0xFFB0A090),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionField(String hint) {
    return TextField(
      controller: _descripcionController,
      maxLines: 5,
      style: const TextStyle(color: Color(0xFF4A3F30), fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFB0A090), fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              BorderSide(color: const Color(0xFFB5976A).withValues(alpha: 0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              BorderSide(color: const Color(0xFFB5976A).withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFB5976A), width: 1.5),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Color(0xFF4A3F30),
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String hint) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(color: Color(0xFF4A3F30)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFB0A090), fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              BorderSide(color: const Color(0xFFB5976A).withValues(alpha: 0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              BorderSide(color: const Color(0xFFB5976A).withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFB5976A), width: 1.5),
        ),
      ),
    );
  }
}
