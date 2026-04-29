import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  // ─────────────────────────────────────────────
  // USUARIO
  // ─────────────────────────────────────────────

  Future<void> updateUserStyles(List<String> styles) async {
    final uid = _uid;
    if (uid == null) return;
    await _db.collection('users').doc(uid).update({'gustos_estilos': styles});
  }

  Future<List<String>> getUserStyles() async {
    final uid = _uid;
    if (uid == null) return [];
    final doc = await _db.collection('users').doc(uid).get();
    final data = doc.data();
    if (data == null) return [];
    return List<String>.from(data['gustos_estilos'] ?? []);
  }

  Future<void> updateUserField(String field, dynamic value) async {
    final uid = _uid;
    if (uid == null) return;
    await _db.collection('users').doc(uid).update({field: value});
  }

  Stream<Map<String, dynamic>?> getUserStream() {
    final uid = _uid;
    if (uid == null) return const Stream.empty();
    return _db.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return {'id': doc.id, ...?doc.data()};
    });
  }

  Future<Map<String, dynamic>?> getUserById(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    if (!doc.exists) return null;
    return {'id': doc.id, ...?doc.data()};
  }

  /// Nombre visible de un usuario o ONG dado su uid/id
  Future<String> getUserDisplayName(String userId) async {
    try {
      // 1. Buscar en 'users' (usuarios normales y ONGs registradas via Auth)
      final userDoc = await _db.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final data = userDoc.data()!;
        final nombre =
        '${data['nombre'] ?? ''} ${data['apellido'] ?? ''}'.trim();
        if (nombre.isNotEmpty) return nombre;
        return data['username'] as String? ?? 'Usuario';
      }
      // 2. Buscar en 'ongs' por id de documento (la colección separada de fundaciones)
      final ongDoc = await _db.collection('ongs').doc(userId).get();
      if (ongDoc.exists) {
        final data = ongDoc.data()!;
        return data['nombre_fundacion'] as String? ?? 'ONG';
      }
      return 'Usuario';
    } catch (_) {
      return 'Usuario';
    }
  }

  // ─────────────────────────────────────────────
  // SEGUIDORES / SEGUIDOS
  // ─────────────────────────────────────────────

  Future<void> followUser(String targetUid) async {
    final uid = _uid;
    if (uid == null || uid == targetUid) return;
    final batch = _db.batch();
    final followingRef = _db.collection('users').doc(uid).collection('following').doc(targetUid);
    batch.set(followingRef, {'followed_at': FieldValue.serverTimestamp()});
    final followerRef = _db.collection('users').doc(targetUid).collection('followers').doc(uid);
    batch.set(followerRef, {'followed_at': FieldValue.serverTimestamp()});
    await batch.commit();
  }

  Future<void> unfollowUser(String targetUid) async {
    final uid = _uid;
    if (uid == null) return;
    final batch = _db.batch();
    batch.delete(_db.collection('users').doc(uid).collection('following').doc(targetUid));
    batch.delete(_db.collection('users').doc(targetUid).collection('followers').doc(uid));
    await batch.commit();
  }

  Future<bool> isFollowing(String targetUid) async {
    final uid = _uid;
    if (uid == null) return false;
    final doc = await _db.collection('users').doc(uid).collection('following').doc(targetUid).get();
    return doc.exists;
  }

  Future<int> getFollowersCount(String userId) async {
    final snap = await _db.collection('users').doc(userId).collection('followers').get();
    return snap.size;
  }

  Future<int> getFollowingCount(String userId) async {
    final snap = await _db.collection('users').doc(userId).collection('following').get();
    return snap.size;
  }

  /// Retorna la lista de UIDs de seguidores o seguidos de un usuario.
  /// [mode] puede ser 'followers' o 'following'.
  Future<List<String>> getFollowList({required String uid, required String mode}) async {
    final subCollection = mode == 'followers' ? 'followers' : 'following';
    final snap = await _db.collection('users').doc(uid).collection(subCollection).get();
    return snap.docs.map((d) => d.id).toList();
  }

  Future<Map<String, int>> getUserStats() async {
    final uid = _uid;
    if (uid == null) return {'compras': 0, 'ventas': 0, 'seguidores': 0, 'seguidos': 0};
    final results = await Future.wait([
      _db.collection('orders').where('comprador_id', isEqualTo: uid).count().get(),
      _db.collection('products').where('vendedor_id', isEqualTo: uid).where('activo', isEqualTo: true).count().get(),
      _db.collection('users').doc(uid).collection('followers').count().get(),
      _db.collection('users').doc(uid).collection('following').count().get(),
    ]);
    return {
      'compras': results[0].count ?? 0,
      'ventas': results[1].count ?? 0,
      'seguidores': results[2].count ?? 0,
      'seguidos': results[3].count ?? 0,
    };
  }

  // ─────────────────────────────────────────────
  // PRODUCTOS
  // ─────────────────────────────────────────────

  Stream<List<Map<String, dynamic>>> getProductsStream() {
    return _db.collection('products').where('activo', isEqualTo: true).orderBy('created_at', descending: true).snapshots().map((snap) => snap.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  Stream<List<Map<String, dynamic>>> getProductsByCategory(String categoria) {
    return _db
        .collection('products')
        .where('activo', isEqualTo: true)
        .where('categoria', isEqualTo: categoria)
        .snapshots()
        .map((snap) {
      final docs = snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
      // Ordenar por created_at en el cliente — evita requerir índice compuesto
      docs.sort((a, b) {
        final aTs = a['created_at'];
        final bTs = b['created_at'];
        if (aTs == null && bTs == null) return 0;
        if (aTs == null) return 1;
        if (bTs == null) return -1;
        try {
          final aDt = (aTs as dynamic).toDate() as DateTime;
          final bDt = (bTs as dynamic).toDate() as DateTime;
          return bDt.compareTo(aDt);
        } catch (_) {
          return 0;
        }
      });
      return docs;
    });
  }

  Stream<List<Map<String, dynamic>>> getProductsByVendedor(String vendedorId) {
    return _db
        .collection('products')
        .where('vendedor_id', isEqualTo: vendedorId)
        .where('activo', isEqualTo: true)
        .snapshots()
        .map((snap) {
      final docs = snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
      docs.sort((a, b) {
        final aTs = a['created_at'];
        final bTs = b['created_at'];
        if (aTs == null && bTs == null) return 0;
        if (aTs == null) return 1;
        if (bTs == null) return -1;
        try {
          final aDt = (aTs as dynamic).toDate() as DateTime;
          final bDt = (bTs as dynamic).toDate() as DateTime;
          return bDt.compareTo(aDt);
        } catch (_) {
          return 0;
        }
      });
      return docs;
    });
  }

  Future<Map<String, dynamic>?> getProductById(String productId) async {
    final doc = await _db.collection('products').doc(productId).get();
    if (!doc.exists) return null;
    return {'id': doc.id, ...?doc.data()};
  }

  Future<void> addProduct(Map<String, dynamic> product) async {
    await _db.collection('products').add(product);
  }

  Future<void> deleteProduct(String productId) async {
    await _db.collection('products').doc(productId).update({'activo': false});
  }

  // ─────────────────────────────────────────────
  // GUARDADOS (saved)
  // ─────────────────────────────────────────────

  Stream<List<Map<String, dynamic>>> getSavedStream() {
    final uid = _uid;
    if (uid == null) return const Stream.empty();
    return _db.collection('users').doc(uid).collection('saved').orderBy('saved_at', descending: true).snapshots().map((snap) => snap.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  Future<bool> isProductSaved(String productId) async {
    final uid = _uid;
    if (uid == null) return false;
    final doc = await _db.collection('users').doc(uid).collection('saved').doc(productId).get();
    return doc.exists;
  }

  Future<void> toggleSaved(Map<String, dynamic> product) async {
    final uid = _uid;
    if (uid == null) return;
    final ref = _db.collection('users').doc(uid).collection('saved').doc(product['id'] as String);
    final doc = await ref.get();
    if (doc.exists) {
      await ref.delete();
    } else {
      await ref.set({...product, 'saved_at': FieldValue.serverTimestamp()});
    }
  }

  Future<void> removeSaved(String productId) async {
    final uid = _uid;
    if (uid == null) return;
    await _db.collection('users').doc(uid).collection('saved').doc(productId).delete();
  }

  // ─────────────────────────────────────────────
  // CARRITO (cart)
  // ─────────────────────────────────────────────

  Stream<List<Map<String, dynamic>>> getCartStream() {
    final uid = _uid;
    if (uid == null) return const Stream.empty();
    return _db.collection('users').doc(uid).collection('cart').orderBy('added_at', descending: true).snapshots().map((snap) => snap.docs.map((d) => {'cartItemId': d.id, ...d.data()}).toList());
  }

  Future<void> addToCart({required String productId, required String nombre, required String vendedorNombre, required double precio, required String talla, required List<String> fotos}) async {
    final uid = _uid;
    if (uid == null) return;
    final existing = await _db.collection('users').doc(uid).collection('cart').where('product_id', isEqualTo: productId).where('talla', isEqualTo: talla).get();
    if (existing.docs.isNotEmpty) {
      final doc = existing.docs.first;
      await doc.reference.update({'cantidad': (doc.data()['cantidad'] as int) + 1});
    } else {
      await _db.collection('users').doc(uid).collection('cart').add({'product_id': productId, 'nombre': nombre, 'vendedor_nombre': vendedorNombre, 'precio': precio, 'talla': talla, 'fotos': fotos, 'cantidad': 1, 'added_at': FieldValue.serverTimestamp()});
    }
  }

  Future<void> updateCartQuantity(String cartItemId, int cantidad) async {
    final uid = _uid;
    if (uid == null) return;
    if (cantidad <= 0) {
      await removeFromCart(cartItemId);
    } else {
      await _db.collection('users').doc(uid).collection('cart').doc(cartItemId).update({'cantidad': cantidad});
    }
  }

  Future<void> removeFromCart(String cartItemId) async {
    final uid = _uid;
    if (uid == null) return;
    await _db.collection('users').doc(uid).collection('cart').doc(cartItemId).delete();
  }

  Future<void> clearCart() async {
    final uid = _uid;
    if (uid == null) return;
    final snap = await _db.collection('users').doc(uid).collection('cart').get();
    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  // ─────────────────────────────────────────────
  // PEDIDOS (orders)
  // ─────────────────────────────────────────────

  Stream<List<Map<String, dynamic>>> getOrdersStream() {
    final uid = _uid;
    if (uid == null) return const Stream.empty();
    return _db.collection('orders').where('comprador_id', isEqualTo: uid).orderBy('created_at', descending: true).snapshots().map((snap) => snap.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  Future<String> createOrder({required List<Map<String, dynamic>> items, required Map<String, dynamic> direccion, required String metodoPago, required double subtotal, required double envio, required double total}) async {
    final uid = _uid;
    if (uid == null) throw Exception('Usuario no autenticado');
    final userDoc = await _db.collection('users').doc(uid).get();
    final userData = userDoc.data();
    final ref = await _db.collection('orders').add({'comprador_id': uid, 'comprador_nombre': '${userData?['nombre'] ?? ''} ${userData?['apellido'] ?? ''}'.trim(), 'items': items, 'direccion': direccion, 'metodo_pago': metodoPago, 'subtotal': subtotal, 'envio': envio, 'total': total, 'estado': 'Pendiente', 'created_at': FieldValue.serverTimestamp()});
    await clearCart();
    return ref.id;
  }

  Future<Map<String, dynamic>?> getOrderById(String orderId) async {
    final doc = await _db.collection('orders').doc(orderId).get();
    if (!doc.exists) return null;
    return {'id': doc.id, ...?doc.data()};
  }

  // ─────────────────────────────────────────────
  // DIRECCIONES
  // ─────────────────────────────────────────────

  Stream<List<Map<String, dynamic>>> getAddressesStream() {
    final uid = _uid;
    if (uid == null) return const Stream.empty();
    return _db.collection('users').doc(uid).collection('addresses').orderBy('created_at', descending: false).snapshots().map((snap) => snap.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  Future<void> addAddress(Map<String, dynamic> address) async {
    final uid = _uid;
    if (uid == null) return;
    final existing = await _db.collection('users').doc(uid).collection('addresses').get();
    await _db.collection('users').doc(uid).collection('addresses').add({...address, 'is_primary': existing.docs.isEmpty, 'created_at': FieldValue.serverTimestamp()});
  }

  Future<void> setPrimaryAddress(String addressId) async {
    final uid = _uid;
    if (uid == null) return;
    final snap = await _db.collection('users').doc(uid).collection('addresses').get();
    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'is_primary': doc.id == addressId});
    }
    await batch.commit();
  }

  Future<void> deleteAddress(String addressId) async {
    final uid = _uid;
    if (uid == null) return;
    await _db.collection('users').doc(uid).collection('addresses').doc(addressId).delete();
  }

  // ─────────────────────────────────────────────
  // CHATS (mensajes entre usuarios)
  // ─────────────────────────────────────────────

  String _chatId(String otherUid) {
    final ids = [_uid!, otherUid]..sort();
    return ids.join('_');
  }

  // FIX: Se quitó orderBy('last_message_at') que requería índice compuesto
  // y causaba que el stream fallara silenciosamente cuando no existía.
  // El ordenamiento ahora se hace en el cliente.
  Stream<List<Map<String, dynamic>>> getChatsStream() {
    final uid = _uid;
    if (uid == null) return const Stream.empty();
    return _db
        .collection('chats')
        .where('participants', arrayContains: uid)
        .snapshots()
        .map((snap) {
      final docs = snap.docs
          .map((d) => {'id': d.id, ...d.data()})
      // Filtrar chats que el usuario ocultó
      // PERO si llegó un mensaje nuevo después de ocultarlo, volver a mostrarlo
          .where((chat) {
        final hiddenFor = List<String>.from(chat['hidden_for'] ?? []);
        if (!hiddenFor.contains(uid)) return true;
        // Si hay mensajes después de que se ocultó, mostrar de nuevo
        // Para simplicidad: si last_message no está vacío y hidden_for contiene uid,
        // comparar con cuando se ocultó. Usamos un approach simple:
        // el chat se vuelve visible si el otro usuario envió algo después.
        // Guardamos hidden_at_last_message para comparar.
        final hiddenAtMsg = chat['hidden_at_last_message'] as String?;
        final lastMsg = chat['last_message'] as String? ?? '';
        if (hiddenAtMsg != null && lastMsg != hiddenAtMsg) return true;
        return false;
      })
          .toList();

      docs.sort((a, b) {
        final aTs = a['last_message_at'];
        final bTs = b['last_message_at'];
        if (aTs == null && bTs == null) return 0;
        if (aTs == null) return 1;
        if (bTs == null) return -1;
        try {
          final aDt = (aTs as dynamic).toDate() as DateTime;
          final bDt = (bTs as dynamic).toDate() as DateTime;
          return bDt.compareTo(aDt);
        } catch (_) {
          return 0;
        }
      });
      return docs;
    });
  }

  Stream<List<Map<String, dynamic>>> getMessagesStream(String otherUid) {
    final chatId = _chatId(otherUid);
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('sent_at', descending: false)
        .snapshots()
        .map((snap) => snap.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  Future<void> sendMessage({
    required String otherUid,
    required String text,
    String? productId,
    String? productNombre,
  }) async {
    final uid = _uid;
    if (uid == null) return;
    final chatId = _chatId(otherUid);
    final chatRef = _db.collection('chats').doc(chatId);
    final msgRef = chatRef.collection('messages').doc();
    final batch = _db.batch();

    batch.set(msgRef, {
      'sender_id': uid,
      'text': text,
      'product_id': productId,
      'product_nombre': productNombre,
      'sent_at': FieldValue.serverTimestamp(),
      'read': false,
      'edited': false,
    });

    batch.set(
      chatRef,
      {
        'participants': [uid, otherUid],
        'last_message': text,
        'last_message_at': FieldValue.serverTimestamp(),
        'unread_$otherUid': FieldValue.increment(1),
        'hidden_for': [],           // reaparecer para ambos al recibir mensaje nuevo
        'hidden_at_last_message': '',
      },
      SetOptions(merge: true),
    );

    await batch.commit();
  }

  // NUEVO: Editar un mensaje propio
  Future<void> editMessage({
    required String otherUid,
    required String messageId,
    required String newText,
  }) async {
    final uid = _uid;
    if (uid == null) return;
    final chatId = _chatId(otherUid);
    final chatRef = _db.collection('chats').doc(chatId);
    final msgRef = chatRef.collection('messages').doc(messageId);

    final doc = await msgRef.get();
    if (!doc.exists || doc.data()?['sender_id'] != uid) return;

    await msgRef.update({
      'text': newText,
      'edited': true,
      'edited_at': FieldValue.serverTimestamp(),
    });

    // Actualizar preview si era el último mensaje
    final lastMsgSnap = await chatRef
        .collection('messages')
        .orderBy('sent_at', descending: true)
        .limit(1)
        .get();
    if (lastMsgSnap.docs.isNotEmpty && lastMsgSnap.docs.first.id == messageId) {
      await chatRef.update({'last_message': newText});
    }
  }

  // NUEVO: Eliminar un mensaje propio
  Future<void> deleteMessage({
    required String otherUid,
    required String messageId,
  }) async {
    final uid = _uid;
    if (uid == null) return;
    final chatId = _chatId(otherUid);
    final chatRef = _db.collection('chats').doc(chatId);
    final msgRef = chatRef.collection('messages').doc(messageId);

    final doc = await msgRef.get();
    if (!doc.exists || doc.data()?['sender_id'] != uid) return;

    await msgRef.delete();

    // Actualizar preview del chat con el nuevo último mensaje
    final lastMsgSnap = await chatRef
        .collection('messages')
        .orderBy('sent_at', descending: true)
        .limit(1)
        .get();

    if (lastMsgSnap.docs.isEmpty) {
      await chatRef.update({'last_message': ''});
    } else {
      final lastData = lastMsgSnap.docs.first.data();
      await chatRef.update({
        'last_message': lastData['text'] ?? '',
        'last_message_at': lastData['sent_at'],
      });
    }
  }

  // FIX: Cambiado de update() a set(merge:true) para no fallar
  // cuando el documento del chat todavía no existe.
  Future<void> markChatAsRead(String otherUid) async {
    final uid = _uid;
    if (uid == null) return;
    final chatId = _chatId(otherUid);
    await _db
        .collection('chats')
        .doc(chatId)
        .set({'unread_$uid': 0}, SetOptions(merge: true));
  }

  // NUEVO: Eliminar un chat completo (documento + subcolección de mensajes)
  // Ocultar un chat solo para el usuario actual (no lo elimina para el otro)
  Future<void> deleteChat(String chatId) async {
    final uid = _uid;
    if (uid == null) return;
    // Obtener el último mensaje para saber desde cuándo está oculto
    final chatDoc = await _db.collection('chats').doc(chatId).get();
    final lastMsg = chatDoc.data()?['last_message'] as String? ?? '';
    await _db.collection('chats').doc(chatId).set(
      {
        'hidden_for': FieldValue.arrayUnion([uid]),
        'hidden_at_last_message': lastMsg,
      },
      SetOptions(merge: true),
    );
  }

  // ─────────────────────────────────────────────
  // ONGs
  // ─────────────────────────────────────────────

  Stream<List<Map<String, dynamic>>> getONGsStream() {
    return _db.collection('ongs').snapshots().map(
            (snap) => snap.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  Future<Map<String, dynamic>?> getONGById(String ongId) async {
    final doc = await _db.collection('ongs').doc(ongId).get();
    if (!doc.exists) return null;
    return {'id': doc.id, ...?doc.data()};
  }

  // ─────────────────────────────────────────────
  // LIKES en productos
  // ─────────────────────────────────────────────

  Future<void> toggleLike(String productId) async {
    final uid = _uid;
    if (uid == null) return;
    final likeRef = _db.collection('products').doc(productId).collection('likes').doc(uid);
    final doc = await likeRef.get();
    final productRef = _db.collection('products').doc(productId);
    if (doc.exists) {
      await likeRef.delete();
      await productRef.update({'likes_count': FieldValue.increment(-1)});
    } else {
      await likeRef.set({'liked_at': FieldValue.serverTimestamp()});
      await productRef.update({'likes_count': FieldValue.increment(1)});
    }
  }

  Future<bool> isProductLiked(String productId) async {
    final uid = _uid;
    if (uid == null) return false;
    final doc = await _db.collection('products').doc(productId).collection('likes').doc(uid).get();
    return doc.exists;
  }

  // ─────────────────────────────────────────────
  // RESEÑAS (reviews)
  // ─────────────────────────────────────────────

  /// Stream de todas las reseñas de un producto, ordenadas por fecha desc
  Stream<List<Map<String, dynamic>>> getReviewsStream(String productId) {
    return _db
        .collection('products')
        .doc(productId)
        .collection('reviews')
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  /// Stream con promedio y conteo de reseñas de un producto
  Stream<Map<String, dynamic>> getReviewsSummaryStream(String productId) {
    return _db
        .collection('products')
        .doc(productId)
        .collection('reviews')
        .snapshots()
        .map((snap) {
      if (snap.docs.isEmpty) return {'avg': 0.0, 'count': 0};
      final ratings = snap.docs
          .map((d) => (d.data()['rating'] as num?)?.toDouble() ?? 0)
          .toList();
      final avg = ratings.reduce((a, b) => a + b) / ratings.length;
      return {'avg': avg, 'count': snap.docs.length};
    });
  }

  /// Obtiene la reseña del usuario actual para un producto (si existe)
  Future<Map<String, dynamic>?> getMyReview(String productId) async {
    final uid = _uid;
    if (uid == null) return null;
    final doc = await _db
        .collection('products')
        .doc(productId)
        .collection('reviews')
        .doc(uid)
        .get();
    if (!doc.exists) return null;
    return {'id': doc.id, ...?doc.data()};
  }

  /// Crea o actualiza la reseña del usuario actual para un producto
  Future<void> submitReview({
    required String productId,
    required int rating,
    required String comment,
  }) async {
    final uid = _uid;
    if (uid == null) return;

    // Obtener el nombre del usuario para mostrarlo en la reseña
    final userDoc = await _db.collection('users').doc(uid).get();
    final data = userDoc.data();
    final nombre = '${data?['nombre'] ?? ''} ${data?['apellido'] ?? ''}'.trim();
    final authorName = nombre.isNotEmpty
        ? nombre
        : (data?['username'] as String? ?? 'Usuario');

    // Usar el uid como ID del documento → 1 reseña por usuario por producto
    await _db
        .collection('products')
        .doc(productId)
        .collection('reviews')
        .doc(uid)
        .set({
      'author_uid': uid,
      'author_name': authorName,
      'rating': rating,
      'comment': comment,
      'created_at': FieldValue.serverTimestamp(),
    });

    // Actualizar rating_avg y rating_count en el producto para consultas rápidas
    final reviewsSnap = await _db
        .collection('products')
        .doc(productId)
        .collection('reviews')
        .get();
    final ratings = reviewsSnap.docs
        .map((d) => (d.data()['rating'] as num?)?.toDouble() ?? 0)
        .toList();
    final avg = ratings.isEmpty
        ? 0.0
        : ratings.reduce((a, b) => a + b) / ratings.length;

    await _db.collection('products').doc(productId).update({
      'rating_avg': avg,
      'rating_count': ratings.length,
    });
  }
}
