import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ImageCropScreen extends StatefulWidget {
  final File imageFile;

  const ImageCropScreen({super.key, required this.imageFile});

  @override
  State<ImageCropScreen> createState() => _ImageCropScreenState();
}

class _ImageCropScreenState extends State<ImageCropScreen> {
  final GlobalKey _repaintKey = GlobalKey();
  final TransformationController _controller = TransformationController();
  bool _isSaving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      final boundary = _repaintKey.currentContext!.findRenderObject()
      as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) throw 'No se pudo procesar la imagen.';

      final bytes = byteData.buffer.asUint8List();
      final tempFile = File(
          '${Directory.systemTemp.path}/crop_${DateTime.now().millisecondsSinceEpoch}.png');
      await tempFile.writeAsBytes(bytes);

      if (mounted) Navigator.pop(context, tempFile);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error al recortar: $e'),
              backgroundColor: const Color(0xFFD32F2F)),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cropDiameter = size.width * 0.78;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Área interactiva + captura ───────────────────────────────────
          Positioned.fill(
            child: Center(
              child: RepaintBoundary(
                key: _repaintKey,
                child: ClipOval(
                  child: SizedBox.square(
                    dimension: cropDiameter,
                    child: InteractiveViewer(
                      transformationController: _controller,
                      // Sin límite de paneo para que el usuario pueda mover libremente
                      boundaryMargin: const EdgeInsets.all(double.infinity),
                      minScale: 0.5,
                      maxScale: 8.0,
                      clipBehavior: Clip.none,
                      child: Image.file(
                        widget.imageFile,
                        width: cropDiameter,
                        height: cropDiameter,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Overlay oscuro con hueco circular ───────────────────────────
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _CropOverlayPainter(cropDiameter / 2),
              ),
            ),
          ),

          // ── Instrucción arriba ───────────────────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 0,
            right: 0,
            child: const Center(
              child: Text(
                'Mueve y amplía la foto',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    shadows: [
                      Shadow(
                          color: Colors.black54,
                          blurRadius: 6,
                          offset: Offset(0, 1))
                    ]),
              ),
            ),
          ),

          // ── Botones abajo ────────────────────────────────────────────────
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 32,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Cancelar
                TextButton(
                  onPressed:
                  _isSaving ? null : () => Navigator.pop(context, null),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 14),
                    foregroundColor: Colors.white70,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    side: const BorderSide(color: Colors.white24),
                  ),
                  child: const Text('Cancelar',
                      style: TextStyle(fontSize: 15)),
                ),

                // Guardar
                ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB5976A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 36, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                      : const Text('Guardar',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Pinta una capa oscura semitransparente con un agujero circular en el centro.
class _CropOverlayPainter extends CustomPainter {
  final double cropRadius;

  const _CropOverlayPainter(this.cropRadius);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withOpacity(0.58);
    final center = Offset(size.width / 2, size.height / 2);

    // Agujero con even-odd fill rule
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addOval(Rect.fromCircle(center: center, radius: cropRadius));
    path.fillType = PathFillType.evenOdd;
    canvas.drawPath(path, paint);

    // Borde del círculo
    canvas.drawCircle(
      center,
      cropRadius,
      Paint()
        ..color = Colors.white.withOpacity(0.75)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant _CropOverlayPainter old) =>
      old.cropRadius != cropRadius;
}