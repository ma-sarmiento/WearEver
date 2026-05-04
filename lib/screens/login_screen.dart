import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isOng = false;
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showForgotPassword() {
    final emailCtrl = TextEditingController(text: _emailController.text.trim());
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Recuperar contraseña',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A3F30))),
              const SizedBox(height: 8),
              const Text(
                  'Te enviaremos un enlace para restablecer tu contraseña.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF9A8A75))),
              const SizedBox(height: 20),
              TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Color(0xFF4A3F30), fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Correo electrónico',
                  hintStyle: const TextStyle(color: Color(0xFFB0A090)),
                  filled: true,
                  fillColor: const Color(0xFFF5EFE6),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none),
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    final email = emailCtrl.text.trim();
                    if (email.isEmpty) return;
                    try {
                      await AuthService().sendPasswordReset(email);
                      if (ctx.mounted) Navigator.pop(ctx);
                      if (mounted)
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text('Enlace enviado a tu correo ✓'),
                            backgroundColor: Color(0xFFB5976A)));
                    } catch (e) {
                      if (mounted)
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(e.toString()),
                            backgroundColor: Colors.red));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB5976A),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  child: const Text('Enviar enlace',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ]),
      ),
    );
  }

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);
    try {
      await AuthService().loginUser(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (mounted) Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(e.toString()),
            backgroundColor: const Color(0xFFD32F2F)));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isGoogleLoading = true);
    try {
      // loginOnly: true → lanza error si la cuenta no existe en Firestore
      await AuthService().signInWithGoogle(loginOnly: true);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(e.toString()),
            backgroundColor: const Color(0xFFD32F2F)));
      }
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // Logo & title
                  Center(
                    child: Column(children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5E6C8),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                                color:
                                const Color(0xFFB5976A).withOpacity(0.2),
                                blurRadius: 16,
                                offset: const Offset(0, 6)),
                          ],
                        ),
                        child: const Icon(Icons.checkroom_outlined,
                            size: 42, color: Color(0xFFB5976A)),
                      ),
                      const SizedBox(height: 16),
                      const Text('WearEver',
                          style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4A3F30),
                              letterSpacing: 0.5)),
                      const SizedBox(height: 4),
                      const Text('Tu moda, tu identidad',
                          style: TextStyle(
                              fontSize: 13, color: Color(0xFF9A8A75))),
                    ]),
                  ),
                  const SizedBox(height: 32),
                  // Toggle Usuario / ONG
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8D5C4).withOpacity(0.4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(children: [
                      _buildToggleTab('Usuario', !_isOng,
                              () => setState(() => _isOng = false)),
                      _buildToggleTab('ONG / Fundación', _isOng,
                              () => setState(() => _isOng = true)),
                    ]),
                  ),
                  const SizedBox(height: 24),
                  // Email o usuario (solo para usuarios, no ONGs)
                  if (!_isOng) ...[
                    _buildLabel('Correo o usuario'),
                    const SizedBox(height: 6),
                    _buildTextField(
                      controller: _emailController,
                      hint: 'correo@ejemplo.com o @usuario',
                      keyboardType: TextInputType.text,
                    ),
                  ] else ...[
                    _buildLabel('Correo electrónico'),
                    const SizedBox(height: 6),
                    _buildTextField(
                      controller: _emailController,
                      hint: 'correo@ejemplo.com',
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ],
                  const SizedBox(height: 16),
                  // Password
                  _buildLabel('Contraseña'),
                  const SizedBox(height: 6),
                  _buildPasswordField(),
                  const SizedBox(height: 8),
                  // Forgot password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _showForgotPassword,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('¿Olvidaste tu contraseña?',
                          style: TextStyle(
                              color: Color(0xFFB5976A),
                              fontSize: 13,
                              fontWeight: FontWeight.w500)),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 1. Botón principal: Iniciar sesión
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB5976A),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                          : const Text('Iniciar sesión',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),

                  // 2. Continúa con Google — solo para usuarios, no ONGs
                  if (!_isOng) ...[
                    const SizedBox(height: 20),
                    Row(children: [
                      Expanded(
                          child: Divider(
                              color: const Color(0xFFB5976A).withOpacity(0.3),
                              thickness: 1)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('o continúa con',
                            style: TextStyle(
                                fontSize: 12,
                                color: const Color(0xFF9A8A75)
                                    .withOpacity(0.8))),
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
                        onPressed:
                        _isGoogleLoading ? null : _handleGoogleSignIn,
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
                              child: CustomPaint(
                                  painter: _GoogleIconPainter()),
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
                  ],

                  // 3. Registrarse — al final
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pushNamed(
                          context, _isOng ? '/register-ong' : '/register'),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: const Color(0xFFB5976A).withOpacity(0.5)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(
                        _isOng ? 'Registrar fundación' : 'Registrarse',
                        style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF4A3F30),
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleTab(String label, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isActive
                ? [
              BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 2))
            ]
                : [],
          ),
          child: Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                fontSize: 13,
                color: isActive
                    ? const Color(0xFF4A3F30)
                    : const Color(0xFF9A8A75),
              )),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text,
        style: const TextStyle(
            fontSize: 13,
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
      style: const TextStyle(color: Color(0xFF4A3F30), fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFB0A090), fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      style: const TextStyle(color: Color(0xFF4A3F30), fontSize: 14),
      decoration: InputDecoration(
        hintText: '••••••••',
        hintStyle: const TextStyle(color: Color(0xFFB0A090), fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        suffixIcon: IconButton(
          icon: Icon(
              _obscurePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: const Color(0xFFB0A090),
              size: 20),
          onPressed: () =>
              setState(() => _obscurePassword = !_obscurePassword),
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

    // Fondo blanco
    paint.color = Colors.white;
    canvas.drawCircle(center, radius, paint);

    // Dibujar la "G" simplificada con arco y rectángulo
    final rect = Rect.fromCircle(center: center, radius: radius * 0.78);

    // Arco azul (parte superior e izquierda)
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, 3.14 * 0.25, 3.14 * 1.0, false,
        paint..style = PaintingStyle.stroke
          ..strokeWidth = size.width * 0.22
          ..strokeCap = StrokeCap.butt);

    // Arco rojo (parte superior derecha)
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, -3.14 * 0.25, 3.14 * 0.5, false,
        paint..color = const Color(0xFFEA4335));

    // Arco amarillo (parte inferior derecha)
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect, 3.14 * 0.25, 3.14 * 0.5, false,
        paint..color = const Color(0xFFFBBC05));

    // Arco verde (parte inferior izquierda)
    canvas.drawArc(rect, 3.14 * 0.75, 3.14 * 0.5, false,
        paint..color = const Color(0xFF34A853));

    // Barra horizontal derecha (parte característica de la G)
    paint
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(center.dx - size.width * 0.02, center.dy - size.height * 0.12,
          size.width * 0.52, size.height * 0.24),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}