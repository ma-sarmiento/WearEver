import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> registerUser({
    required String email,
    required String password,
    required String nombre,
    required String apellido,
    required String username,
    required String tipo,
    Map<String, dynamic>? extraData,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = cred.user!.uid;
      final data = {
        'nombre': nombre,
        'apellido': apellido,
        'username': username,
        'email': email,
        'tipo': tipo,
        'es_vendedor': false,
        'foto_perfil': '',
        'gustos_estilos': [],
        'created_at': FieldValue.serverTimestamp(),
        ...?extraData,
      };
      await _db.collection('users').doc(uid).set(data);
    } on FirebaseAuthException catch (e) {
      throw _formatError(e.code);
    } catch (e) {
      throw 'Error inesperado. Intenta de nuevo.';
    }
  }

  Future<void> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw _formatError(e.code);
    } catch (e) {
      throw 'Error inesperado. Intenta de nuevo.';
    }
  }

  Future<void> logoutUser() async {
    await _auth.signOut();
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    try {
      final doc = await _db.collection('users').doc(uid).get();
      return doc.data();
    } catch (_) {
      return null;
    }
  }

  String _formatError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Correo no registrado.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Correo o contraseña incorrectos.';
      case 'email-already-in-use':
        return 'Este correo ya está registrado.';
      case 'weak-password':
        return 'La contraseña es muy débil (mínimo 6 caracteres).';
      case 'invalid-email':
        return 'El correo no es válido.';
      case 'network-request-failed':
        return 'Error de conexión. Verifica tu internet.';
      case 'too-many-requests':
        return 'Demasiados intentos. Intenta más tarde.';
      default:
        return 'Error: $code';
    }
  }
  Future<void> changePassword({required String currentPassword, required String newPassword}) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) throw Exception('Usuario no autenticado');
    
    // Re-authenticate first
    final cred = EmailAuthProvider.credential(email: user.email!, password: currentPassword);
    await user.reauthenticateWithCredential(cred);
    
    // Then change password
    await user.updatePassword(newPassword);
  }
}