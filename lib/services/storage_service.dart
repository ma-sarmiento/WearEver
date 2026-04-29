import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> uploadProfilePhoto(File imageFile) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    try {
      final ref = _storage.ref().child('profiles/$uid/photo.jpg');
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (_) {
      return null;
    }
  }

  Future<String?> uploadProductPhoto(File imageFile, String productId) async {
    try {
      final filename = DateTime.now().millisecondsSinceEpoch.toString();
      final ref =
          _storage.ref().child('products/$productId/$filename.jpg');
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (_) {
      return null;
    }
  }
}
