import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

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

  Future<String> _resolveEmail(String emailOrUsername) async {
    if (emailOrUsername.contains('@')) return emailOrUsername;
    final snap = await _db
        .collection('users')
        .where('username', isEqualTo: emailOrUsername)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) throw 'Usuario no encontrado.';
    return snap.docs.first.data()['email'] as String;
  }

  Future<void> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final resolvedEmail = await _resolveEmail(email.trim());
      await _auth.signInWithEmailAndPassword(
          email: resolvedEmail, password: password);
    } on FirebaseAuthException catch (e) {
      throw _formatError(e.code);
    } catch (e) {
      if (e is String) rethrow;
      throw 'Error inesperado. Intenta de nuevo.';
    }
  }

  /// Verifica si un username está disponible en Firestore.
  Future<bool> isUsernameAvailable(String username) async {
    final snap = await _db
        .collection('users')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();
    return snap.docs.isEmpty;
  }

  /// Actualiza el username del usuario actual.
  Future<void> updateUsername(String username) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw 'Usuario no autenticado.';
    final available = await isUsernameAvailable(username);
    if (!available) throw 'Ese username ya fue tomado. Elige otro.';
    await _db.collection('users').doc(uid).update({'username': username});
  }

  /// Crea el documento Firestore del usuario de Google con el username elegido.
  /// Llamar desde CompleteProfileScreen al confirmar el username.
  Future<void> completeGoogleProfile(String username) async {
    final user = _auth.currentUser;
    if (user == null) throw 'No hay sesión activa.';

    // Verificar disponibilidad justo antes de guardar
    final available = await isUsernameAvailable(username);
    if (!available) throw 'Ese username ya fue tomado. Elige otro.';

    final displayName = user.displayName ?? '';
    final parts = displayName.split(' ');
    final nombre = parts.isNotEmpty ? parts.first : '';
    final apellido = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    await _db.collection('users').doc(user.uid).set({
      'nombre': nombre,
      'apellido': apellido,
      'username': username,
      'email': user.email ?? '',
      'tipo': 'usuario',
      'foto_perfil': user.photoURL ?? '',
      'gustos_estilos': [],
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  /// Google Sign In.
  ///
  /// [loginOnly] = true  → solo permite cuentas ya existentes en Firestore.
  /// [loginOnly] = false → autentica con Firebase pero NO crea doc Firestore.
  ///   El usuario nuevo debe completar su perfil en CompleteProfileScreen.
  Future<bool> signInWithGoogle({bool loginOnly = false}) async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return false;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCred = await _auth.signInWithCredential(credential);
      final user = userCred.user!;

      final doc = await _db.collection('users').doc(user.uid).get();

      if (!doc.exists) {
        if (loginOnly) {
          // No tiene cuenta → rechazar
          await _auth.signOut();
          await _googleSignIn.signOut();
          throw 'No tienes una cuenta registrada con este correo de Google. Por favor regístrate primero.';
        }
        // Usuario nuevo: autenticado en Firebase pero sin doc Firestore.
        // El doc se crea en completeGoogleProfile() tras elegir username.
        return true;
      }

      return false; // usuario existente → ir a /home
    } on FirebaseAuthException catch (e) {
      throw _formatError(e.code);
    } catch (e) {
      if (e is String) rethrow;
      throw 'Error al iniciar sesión con Google.';
    }
  }

  Future<void> logoutUser() async {
    await _googleSignIn.signOut();
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

  Future<void> changePassword(
      {required String currentPassword, required String newPassword}) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null)
      throw Exception('Usuario no autenticado');
    final cred = EmailAuthProvider.credential(
        email: user.email!, password: currentPassword);
    await user.reauthenticateWithCredential(cred);
    await user.updatePassword(newPassword);
  }

  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _formatError(e.code);
    }
  }
}