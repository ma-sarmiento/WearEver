import 'package:flutter/material.dart';
import '../widgets/smart_back_button.dart';
import '../services/firestore_service.dart';

class StyleSelectorScreen extends StatefulWidget {
  const StyleSelectorScreen({super.key});

  @override
  State<StyleSelectorScreen> createState() => _StyleSelectorScreenState();
}

class _StyleSelectorScreenState extends State<StyleSelectorScreen>
    with SingleTickerProviderStateMixin {
  final Set<String> _selectedStyles = {};

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  final List<Map<String, dynamic>> _styles = [
    {'label': 'Streetwear', 'icon': Icons.skateboarding},
    {'label': 'Vintage', 'icon': Icons.local_florist_outlined},
    {'label': 'Deportivo', 'icon': Icons.sports_volleyball_outlined},
    {'label': 'Casual', 'icon': Icons.weekend_outlined},
    {'label': 'Elegante', 'icon': Icons.woman_outlined},
    {'label': 'Formal', 'icon': Icons.business_center_outlined},
    {'label': 'Minimalista', 'icon': Icons.straighten_outlined},
    {'label': 'Sostenible', 'icon': Icons.recycling_outlined},
    {'label': 'Accesorios', 'icon': Icons.watch_outlined},
    {'label': 'Zapatos', 'icon': Icons.directions_walk_outlined},
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  bool _showMaxError = false;

  void _toggleStyle(String style) {
    setState(() {
      if (_selectedStyles.contains(style)) {
        _selectedStyles.remove(style);
        _showMaxError = false;
      } else if (_selectedStyles.length >= 3) {
        _showMaxError = true;
      } else {
        _selectedStyles.add(style);
        _showMaxError = false;
      }
    });
  }

  Future<void> _onContinue() async {
    final styles = _selectedStyles.toList();
    await FirestoreService().updateUserStyles(styles);
    if (mounted) Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      appBar: AppBar(
      automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFF5EFE6),
        elevation: 0,
        ),
      body: SafeArea(
        top: false,
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                const Text(
                  'Cuéntanos qué te gusta',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4A3F30),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Esto nos ayudará a recomendarte lo que más te interesa',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFFB5976A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Selecciona hasta 3 estilos',
                  style: TextStyle(
                    fontSize: 12,
                    color: _showMaxError ? const Color(0xFFD32F2F) : const Color(0xFF9A8A75),
                    fontWeight: _showMaxError ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 1.4,
                    ),
                    itemCount: _styles.length,
                    itemBuilder: (context, index) {
                      final style = _styles[index];
                      final isSelected =
                      _selectedStyles.contains(style['label']);
                      return _buildStyleCard(
                        label: style['label'],
                        icon: style['icon'],
                        isSelected: isSelected,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _selectedStyles.isEmpty ? null : _onContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB5976A),
                      disabledBackgroundColor:
                      const Color(0xFFB5976A).withOpacity(0.4),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Continuar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStyleCard({
    required String label,
    required IconData icon,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => _toggleStyle(label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFB5976A) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFB5976A)
                : const Color(0xFFE0D0BC),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFFB5976A).withOpacity(0.3)
                  : Colors.black.withOpacity(0.04),
              blurRadius: isSelected ? 12 : 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? Colors.white : const Color(0xFF8B7355),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF4A3F30),
              ),
            ),
          ],
        ),
      ),
    );
  }
}