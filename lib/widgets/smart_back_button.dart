import 'package:flutter/material.dart';

/// Botón de atrás inteligente.
/// Usa ModalRoute.canPop que es confiable con MaterialApp y rutas nombradas.
/// - Si hay pantalla anterior en la pila → muestra flecha y hace pop.
/// - Si NO hay pantalla anterior → no se muestra (invisible).
class SmartBackButton extends StatelessWidget {
  final Color color;
  const SmartBackButton({super.key, this.color = const Color(0xFF4A3F30)});

  @override
  Widget build(BuildContext context) {
    final canPop = ModalRoute.of(context)?.canPop ?? false;
    if (!canPop) return const SizedBox.shrink();
    return IconButton(
      icon: Icon(Icons.arrow_back, color: color),
      onPressed: () => Navigator.of(context).pop(),
    );
  }
}

/// Versión para SliverAppBar con fondo blanco circular.
class SmartBackGesture extends StatelessWidget {
  final Color color;
  const SmartBackGesture({super.key, this.color = const Color(0xFF4A3F30)});

  @override
  Widget build(BuildContext context) {
    final canPop = ModalRoute.of(context)?.canPop ?? false;
    if (!canPop) return const SizedBox.shrink();
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        margin: const EdgeInsets.all(8),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.arrow_back, color: color, size: 20),
      ),
    );
  }
}
