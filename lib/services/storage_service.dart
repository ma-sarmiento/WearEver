import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Sube la foto de perfil a Firebase Storage y retorna la URL de descarga.
  ///
  /// Usa un timestamp en el nombre del archivo para que la URL cambie
  /// en cada subida, rompiendo el caché de Flutter's NetworkImage.
  Future<String?> uploadProfilePhoto(File imageFile) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final ref =
      _storage.ref().child('profiles/$uid/photo_$timestamp.jpg');
      await ref.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      return await ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw Exception('Error subiendo foto de perfil: ${e.message}');
    }
  }

  /// Sube una foto de producto a Firebase Storage y retorna la URL de descarga.
  Future<String> uploadProductPhoto(File imageFile, String productId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('No hay usuario autenticado.');

    final filename = DateTime.now().millisecondsSinceEpoch.toString();
    final ref =
    _storage.ref().child('products/$productId/$filename.jpg');

    try {
      final task = await ref.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      return await task.ref.getDownloadURL();
    } on FirebaseException catch (e) {
      switch (e.code) {
        case 'storage/unauthorized':
          throw Exception(
              'Sin permiso para subir imágenes. Verifica las reglas de Firebase Storage.');
        case 'storage/object-not-found':
          throw Exception('No se encontró el archivo en Storage.');
        case 'storage/bucket-not-found':
          throw Exception(
              'El bucket de Firebase Storage no existe. ¿Lo activaste en la consola?');
        case 'storage/quota-exceeded':
          throw Exception('Se superó la cuota de almacenamiento.');
        default:
          throw Exception('Error de Storage (${e.code}): ${e.message}');
      }
    } catch (e) {
      throw Exception('Error inesperado al subir imagen: $e');
    }
  }
}