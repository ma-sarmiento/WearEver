import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
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
      await AuthService().registerUser(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        nombre: _firstNameController.text.trim(),
        apellido: _lastNameController.text.trim(),
        username: _usernameController.text.trim(),
        tipo: 'usuario',
      );
      if (mounted) Navigator.pushReplacementNamed(context, '/style-selector');
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

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isGoogleLoading = true);
    try {
      // loginOnly: false → permite crear cuenta nueva con Google
      final isNewUser = await AuthService().signInWithGoogle(loginOnly: false);
      if (!mounted) return;
      if (isNewUser) {
        Navigator.pushReplacementNamed(context, '/complete-profile');
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
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
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5EFE6),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF4A3F30), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        top: false,
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                // Logo & title
                Center(
                  child: Column(
                    children: [
                      Container(
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
                          Icons.checkroom_rounded,
                          size: 40,
                          color: Color(0xFFB5976A),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'WearEver',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w300,
                          color: Color(0xFF4A3F30),
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Dale nueva vida a tu estilo.',
                        style: TextStyle(fontSize: 14, color: Color(0xFF7A6A55)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Nombre y apellido
                _buildLabel('Nombre y apellido'),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                          controller: _firstNameController, hint: 'Nombre'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                          controller: _lastNameController, hint: 'Apellido'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _buildLabel('Username'),
                const SizedBox(height: 6),
                _buildTextField(
                    controller: _usernameController, hint: '@usuario'),
                const SizedBox(height: 16),

                _buildLabel('Correo'),
                const SizedBox(height: 6),
                _buildTextField(
                  controller: _emailController,
                  hint: 'name@example.com',
                  keyboardType: TextInputType.emailAddress,
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

                _buildLabel('Confirmar Contraseña'),
                const SizedBox(height: 6),
                _buildPasswordField(
                  controller: _confirmPasswordController,
                  obscure: _obscureConfirm,
                  onToggle: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
                const SizedBox(height: 30),

                // 1. Botón principal: Registrarse
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB5976A),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5),
                    )
                        : const Text('Registrarse',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500)),
                  ),
                ),
                const SizedBox(height: 24),

                // 2. Divisor "o regístrate con" + botón Google
                Row(children: [
                  Expanded(
                      child: Divider(
                          color: const Color(0xFFB5976A).withOpacity(0.3),
                          thickness: 1)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('o regístrate con',
                        style: TextStyle(
                            fontSize: 12,
                            color: const Color(0xFF9A8A75).withOpacity(0.8))),
                  ),
                  Expanded(
                      child: Divider(
                          color: const Color(0xFFB5976A).withOpacity(0.3),
                          thickness: 1)),
                ]),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: _isGoogleLoading ? null : _handleGoogleSignIn,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: BorderSide(
                          color: const Color(0xFFB5976A).withOpacity(0.3)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _isGoogleLoading
                        ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Color(0xFFB5976A), strokeWidth: 2))
                        : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child:
                          CustomPaint(painter: _GoogleIconPainter()),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Continuar con Google',
                          style: TextStyle(
                              fontSize: 15,
                              color: Color(0xFF4A3F30),
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ONG link
                Center(
                  child: GestureDetector(
                    onTap: () =>
                        Navigator.pushNamed(context, '/register-ong'),
                    child: RichText(
                      text: const TextSpan(
                        style:
                        TextStyle(fontSize: 13, color: Color(0xFF9A8A75)),
                        children: [
                          TextSpan(text: '¿Eres una fundación? '),
                          TextSpan(
                            text: 'Regístrate aquí',
                            style: TextStyle(
                              color: Color(0xFFB5976A),
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text,
        style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF4A3F30)));
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
        hintText: '••••••••',
        hintStyle: const TextStyle(color: Color(0xFFB0A090), fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility,
              color: const Color(0xFFB5976A), size: 18),
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

// Pintor del ícono G de Google con sus colores oficiales
class _GoogleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    paint.color = Colors.white;
    canvas.drawCircle(center, radius, paint);

    final rect = Rect.fromCircle(center: center, radius: radius * 0.78);

    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, 3.14 * 0.25, 3.14 * 1.0, false,
        paint
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.width * 0.22
          ..strokeCap = StrokeCap.butt);

    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, -3.14 * 0.25, 3.14 * 0.5, false,
        paint..color = const Color(0xFFEA4335));

    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect, 3.14 * 0.25, 3.14 * 0.5, false,
        paint..color = const Color(0xFFFBBC05));

    canvas.drawArc(rect, 3.14 * 0.75, 3.14 * 0.5, false,
        paint..color = const Color(0xFF34A853));

    paint
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(
          center.dx - size.width * 0.02,
          center.dy - size.height * 0.12,
          size.width * 0.52,
          size.height * 0.24),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}