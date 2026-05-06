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
  final _ciudadController = TextEditingController();
  final _direccionController = TextEditingController();
  final _descripcionController = TextEditingController();

  final List<File> _photos = [];
  final Set<String> _selectedTipos = {};
  String? _cantidad;
  DateTime? _fechaLimite;
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

  @override
  void dispose() {
    _tituloController.dispose();
    _ciudadController.dispose();
    _direccionController.dispose();
    _descripcionController.dispose();
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

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFFB5976A),
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: Color(0xFF4A3F30),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _fechaLimite = picked);
  }

  Future<void> _submit() async {
    if (_tituloController.text.trim().isEmpty) {
      _showError('Ingresa un título para la publicación');
      return;
    }
    if (_selectedTipos.isEmpty) {
      _showError('Selecciona al menos un tipo de ropa');
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

      await _firestoreService.createOngPost({
        'titulo': _tituloController.text.trim(),
        'tipos_ropa': _selectedTipos.toList(),
        'cantidad': _cantidad ?? '',
        'ciudad': _ciudadController.text.trim(),
        'direccion': _direccionController.text.trim(),
        'fecha_limite': _fechaLimite != null
            ? Timestamp.fromDate(_fechaLimite!)
            : null,
        'descripcion': _descripcionController.text.trim(),
        'fotos': photoUrls,
        'ong_nombre': ongData['nombre_fundacion'] ?? '',
        'ong_logo': ongData['logo_url'] ?? '',
      });

      if (mounted) Navigator.pushReplacementNamed(context, '/home');
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPhotoSection(),
            const SizedBox(height: 20),
            _buildLabel('Título *'),
            const SizedBox(height: 6),
            _buildTextField(_tituloController, 'Ej. Donación de ropa de invierno'),
            const SizedBox(height: 16),
            _buildLabel('Tipos de ropa *'),
            const SizedBox(height: 8),
            _buildTiposChips(),
            const SizedBox(height: 16),
            _buildLabel('Cantidad de prendas'),
            const SizedBox(height: 6),
            _buildCantidadDropdown(),
            const SizedBox(height: 16),
            _buildLabel('Ciudad'),
            const SizedBox(height: 6),
            _buildTextField(_ciudadController, 'Ej. Bogotá'),
            const SizedBox(height: 16),
            _buildLabel('Dirección de entrega'),
            const SizedBox(height: 6),
            _buildTextField(_direccionController, 'Carrera 7 # 43-12, piso 3'),
            const SizedBox(height: 16),
            _buildLabel('Fecha límite de donación'),
            const SizedBox(height: 6),
            _buildDateButton(),
            const SizedBox(height: 16),
            _buildLabel('Descripción'),
            const SizedBox(height: 6),
            _buildDescriptionField(),
            const SizedBox(height: 28),
            _buildSubmitButton(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Fotos (máx. 3)'),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              ..._photos.asMap().entries.map(
                  (e) => _buildPhotoThumb(e.key, e.value)),
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
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color:
                  isSelected ? const Color(0xFFB5976A) : Colors.white,
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
                color: isSelected
                    ? Colors.white
                    : const Color(0xFF4A3F30),
                fontWeight: isSelected
                    ? FontWeight.w600
                    : FontWeight.normal,
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
        border: Border.all(
            color: const Color(0xFFB5976A).withValues(alpha: 0.2)),
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

  Widget _buildDateButton() {
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: const Color(0xFFB5976A).withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined,
                color: Color(0xFFB5976A), size: 18),
            const SizedBox(width: 10),
            Text(
              _fechaLimite != null
                  ? '${_fechaLimite!.day}/${_fechaLimite!.month}/${_fechaLimite!.year}'
                  : 'Seleccionar fecha',
              style: TextStyle(
                color: _fechaLimite != null
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

  Widget _buildDescriptionField() {
    return TextField(
      controller: _descripcionController,
      maxLines: 4,
      style: const TextStyle(color: Color(0xFF4A3F30)),
      decoration: InputDecoration(
        hintText:
            'Describe qué tipo de ropa necesitan, condiciones, etc.',
        hintStyle:
            const TextStyle(color: Color(0xFFB0A090), fontSize: 13),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
              color: const Color(0xFFB5976A).withValues(alpha: 0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
              color: const Color(0xFFB5976A).withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: Color(0xFFB5976A), width: 1.5),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFB5976A),
          disabledBackgroundColor:
              const Color(0xFFB5976A).withValues(alpha: 0.4),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5),
              )
            : const Text('Publicar',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600)),
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
        hintStyle:
            const TextStyle(color: Color(0xFFB0A090), fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
              color: const Color(0xFFB5976A).withValues(alpha: 0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
              color: const Color(0xFFB5976A).withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: Color(0xFFB5976A), width: 1.5),
        ),
      ),
    );
  }
}
