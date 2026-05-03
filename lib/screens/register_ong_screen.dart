import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/smart_back_button.dart';
import '../services/auth_service.dart';

class RegisterOngScreen extends StatefulWidget {
  const RegisterOngScreen({super.key});

  @override
  State<RegisterOngScreen> createState() => _RegisterOngScreenState();
}

class _RegisterOngScreenState extends State<RegisterOngScreen>
    with SingleTickerProviderStateMixin {
  final _foundationNameController = TextEditingController();
  final _nitController = TextEditingController();
  final _legalRepController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _foundationNameController.dispose();
    _nitController.dispose();
    _legalRepController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _descriptionController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Las contraseñas no coinciden.'),
          backgroundColor: Color(0xFFD32F2F),
        ),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      // Create auth user first
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      final uid = cred.user!.uid;

      // Save ONG data to 'ongs' collection (separate from users)
      await FirebaseFirestore.instance.collection('ongs').doc(uid).set({
        'nombre_fundacion': _foundationNameController.text.trim(),
        'email': _emailController.text.trim(),
        'nit': _nitController.text.trim(),
        'representante_legal': _legalRepController.text.trim(),
        'telefono': _phoneController.text.trim(),
        'ciudad': _cityController.text.trim(),
        'descripcion': _descriptionController.text.trim(),
        'logo_url': '',
        'tipo': 'ong',
        'verificada': false,
        'created_at': FieldValue.serverTimestamp(),
      });

      if (mounted) Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: const Color(0xFFD32F2F),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5EFE6),
        elevation: 0,
        title: const Text(
          'Registro Fundación',
          style: TextStyle(
            color: Color(0xFF4A3F30),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5E6C8),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFB5976A).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.volunteer_activism,
                    size: 38,
                    color: Color(0xFFB5976A),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Center(
                child: Text(
                  'Registro de Fundación ONG',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4A3F30),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              const Center(
                child: Text(
                  'Completa los datos de tu organización',
                  style: TextStyle(fontSize: 13, color: Color(0xFF7A6A55)),
                ),
              ),
              const SizedBox(height: 24),

              _buildLabel('Nombre de la fundación'),
              const SizedBox(height: 6),
              _buildTextField(
                controller: _foundationNameController,
                hint: 'Ej. Fundación Vístete',
              ),
              const SizedBox(height: 16),

              _buildLabel('NIT'),
              const SizedBox(height: 6),
              _buildTextField(
                controller: _nitController,
                hint: '900.123.456-7',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              _buildLabel('Representante legal'),
              const SizedBox(height: 6),
              _buildTextField(
                controller: _legalRepController,
                hint: 'Nombre completo',
              ),
              const SizedBox(height: 16),

              _buildLabel('Correo institucional'),
              const SizedBox(height: 6),
              _buildTextField(
                controller: _emailController,
                hint: 'contacto@fundacion.org',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              _buildLabel('Teléfono de contacto'),
              const SizedBox(height: 6),
              _buildTextField(
                controller: _phoneController,
                hint: '+57 300 000 0000',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              _buildLabel('Ciudad'),
              const SizedBox(height: 6),
              _buildTextField(
                controller: _cityController,
                hint: 'Bogotá',
              ),
              const SizedBox(height: 16),

              _buildLabel('Descripción breve de la fundación'),
              const SizedBox(height: 6),
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                style: const TextStyle(color: Color(0xFF4A3F30)),
                decoration: InputDecoration(
                  hintText: 'Cuéntanos sobre la misión de tu fundación...',
                  hintStyle: const TextStyle(color: Color(0xFFB0A090), fontSize: 13),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        color: const Color(0xFFB5976A).withOpacity(0.2)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        color: const Color(0xFFB5976A).withOpacity(0.2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Color(0xFFB5976A), width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              _buildLabel('Contraseña'),
              const SizedBox(height: 6),
              _buildPasswordField(
                controller: _passwordController,
                obscure: _obscurePassword,
                onToggle: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              const SizedBox(height: 16),

              _buildLabel('Confirmar contraseña'),
              const SizedBox(height: 6),
              _buildPasswordField(
                controller: _confirmPasswordController,
                obscure: _obscureConfirm,
                onToggle: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
              ),
              const SizedBox(height: 30),

              // Registrar Fundación button with gradient
              SizedBox(
                width: double.infinity,
                height: 50,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFC4A882), Color(0xFFB5976A)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'Registrar Fundación',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                        color: const Color(0xFFB5976A).withOpacity(0.5)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(
                      color: Color(0xFF7A6A55),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
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
              BorderSide(color: const Color(0xFFB5976A).withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              BorderSide(color: const Color(0xFFB5976A).withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFB5976A), width: 1.5),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Color(0xFF4A3F30)),
      decoration: InputDecoration(
        hintText: 'Contraseña',
        hintStyle: const TextStyle(color: Color(0xFFB0A090), fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off : Icons.visibility,
            color: const Color(0xFFB5976A),
            size: 18,
          ),
          onPressed: onToggle,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              BorderSide(color: const Color(0xFFB5976A).withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              BorderSide(color: const Color(0xFFB5976A).withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFB5976A), width: 1.5),
        ),
      ),
    );
  }
}
