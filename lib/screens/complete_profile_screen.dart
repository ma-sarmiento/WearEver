import 'dart:async';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen>
    with SingleTickerProviderStateMixin {
  final _usernameController = TextEditingController();
  bool _isLoading = false;
  bool _isChecking = false;
  bool? _isAvailable;
  String _validationMessage = '';
  Timer? _debounce;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _slideAnim =
        Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
            CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _usernameController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _onUsernameChanged(String value) {
    _debounce?.cancel();
    final username = value.trim().replaceAll('@', '');

    if (username.length < 3) {
      setState(() {
        _isAvailable = null;
        _isChecking = false;
        _validationMessage = username.isEmpty ? '' : 'Mínimo 3 caracteres.';
      });
      return;
    }

    final validPattern = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!validPattern.hasMatch(username)) {
      setState(() {
        _isAvailable = false;
        _isChecking = false;
        _validationMessage = 'Solo letras, números y guión bajo ( _ ).';
      });
      return;
    }

    setState(() {
      _isChecking = true;
      _isAvailable = null;
      _validationMessage = '';
    });

    _debounce = Timer(const Duration(milliseconds: 600), () async {
      try {
        final available = await AuthService().isUsernameAvailable(username);
        if (!mounted) return;
        setState(() {
          _isChecking = false;
          _isAvailable = available;
          _validationMessage =
          available ? 'Disponible' : 'Este username ya está en uso.';
        });
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _isChecking = false;
          _isAvailable = null;
          _validationMessage = 'Error al verificar. Intenta de nuevo.';
        });
      }
    });
  }

  Future<void> _handleContinue() async {
    final username = _usernameController.text.trim().replaceAll('@', '');
    if (username.isEmpty || _isAvailable != true) return;

    setState(() => _isLoading = true);
    try {
      // Crea el documento Firestore completo con el username elegido
      await AuthService().completeGoogleProfile(username);
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/style-selector');
      }
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

  /// Volver atrás: cierra sesión limpiamente.
  /// Como el doc Firestore aún no existe, no queda rastro.
  Future<void> _handleBack() async {
    await AuthService().logoutUser();
    if (mounted) Navigator.pushReplacementNamed(context, '/login');
  }

  bool get _canContinue =>
      _isAvailable == true &&
          !_isChecking &&
          _usernameController.text.trim().isNotEmpty;

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
          onPressed: _handleBack,
        ),
      ),
      body: SafeArea(
        top: false,
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: SingleChildScrollView(
              padding:
              const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // Logo
                  Center(
                    child: Column(children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5E6C8),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                                color:
                                const Color(0xFFB5976A).withOpacity(0.25),
                                blurRadius: 14,
                                offset: const Offset(0, 5)),
                          ],
                        ),
                        child: const Icon(Icons.checkroom_rounded,
                            size: 38, color: Color(0xFFB5976A)),
                      ),
                      const SizedBox(height: 14),
                      const Text('WearEver',
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w300,
                              color: Color(0xFF4A3F30),
                              letterSpacing: 2)),
                    ]),
                  ),

                  const SizedBox(height: 40),

                  const Text('Elige tu username',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A3F30))),
                  const SizedBox(height: 6),
                  const Text(
                    'Con él te encontrarán en WearEver.\nPuedes cambiarlo más adelante.',
                    style: TextStyle(
                        fontSize: 13, color: Color(0xFF9A8A75), height: 1.5),
                  ),

                  const SizedBox(height: 32),

                  // Campo username
                  TextField(
                    controller: _usernameController,
                    onChanged: _onUsernameChanged,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    autocorrect: false,
                    style: const TextStyle(
                        color: Color(0xFF4A3F30), fontSize: 15),
                    decoration: InputDecoration(
                      hintText: 'tu_username',
                      hintStyle: const TextStyle(
                          color: Color(0xFFB0A090), fontSize: 15),
                      prefixText: '@ ',
                      prefixStyle: const TextStyle(
                          color: Color(0xFFB5976A),
                          fontSize: 15,
                          fontWeight: FontWeight.w600),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: const Color(0xFFB5976A).withOpacity(0.2)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: const Color(0xFFB5976A).withOpacity(0.2)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: Color(0xFFB5976A), width: 1.5),
                      ),
                      suffixIcon: _buildSuffixIcon(),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Mensaje de validación
                  if (_validationMessage.isNotEmpty)
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Row(
                        key: ValueKey(_validationMessage),
                        children: [
                          Icon(
                            _isAvailable == true
                                ? Icons.check_circle_outline_rounded
                                : Icons.info_outline_rounded,
                            size: 14,
                            color: _isAvailable == true
                                ? const Color(0xFF4CAF50)
                                : const Color(0xFFD32F2F),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _validationMessage,
                            style: TextStyle(
                                fontSize: 12,
                                color: _isAvailable == true
                                    ? const Color(0xFF4CAF50)
                                    : const Color(0xFFD32F2F)),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 40),

                  // Botón Continuar
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed:
                      (_canContinue && !_isLoading) ? _handleContinue : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB5976A),
                        disabledBackgroundColor:
                        const Color(0xFFB5976A).withOpacity(0.35),
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
                          : const Text('Continuar',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget? _buildSuffixIcon() {
    if (_isChecking) {
      return const Padding(
        padding: EdgeInsets.all(14),
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
              color: Color(0xFFB5976A), strokeWidth: 2),
        ),
      );
    }
    if (_isAvailable == true) {
      return const Icon(Icons.check_circle_rounded,
          color: Color(0xFF4CAF50), size: 22);
    }
    if (_isAvailable == false) {
      return const Icon(Icons.cancel_rounded,
          color: Color(0xFFD32F2F), size: 22);
    }
    return null;
  }
}