# WearEver — Moda Circular

Marketplace sostenible de moda de segunda mano desarrollado en **Flutter**, diseñado para mitigar el impacto ambiental de la industria textil en Colombia. Facilita la compra, venta y donación de prendas usadas, conectando usuarios con ONGs y puntos de recolección.

**Problema que resuelve:** Colombia genera aprox. 160,000 toneladas de residuos textiles anuales que terminan en rellenos sanitarios como Doña Juana (Bogotá).

---

## Equipo

| Nombre | Rol                |
|--------|--------------------|
| Miguel Sarmiento | Desarrollo Flutter / Firebase |
| Daniel Cristancho | Firebase           |
| Andrés Pinzón | Desarrollo Flutter |
| Juan Nonsoque | Firebase           |

---

## Stack tecnológico

| Capa | Tecnología |
|------|-----------|
| Framework | Flutter 3.x / Dart 3.9.2+ |
| UI | Material Design 3 |
| Autenticación | Firebase Auth + Google Sign-In |
| Base de datos | Cloud Firestore (NoSQL, tiempo real) |
| Almacenamiento | Firebase Storage |
| Notificaciones push | Firebase Cloud Messaging (FCM) |
| Mapas | Google Maps Flutter |
| Geolocalización | Geolocator + Geocoding |
| Persistencia local | SharedPreferences |

---

## Estructura del proyecto

```
wearever/
├── lib/
│   ├── main.dart                   # Entry point, Firebase init, routing (32 rutas)
│   ├── screens/                    # 34 pantallas
│   ├── services/                   # 4 servicios de negocio
│   └── widgets/                    # Widgets reutilizables
├── android/
│   ├── app/
│   │   ├── google-services.json    # Config Firebase Android
│   │   └── src/main/AndroidManifest.xml
│   └── gradle/
├── ios/
│   └── Runner/
│       └── Info.plist
├── test/
├── pubspec.yaml
└── analysis_options.yaml
```

---

## Módulos principales

### Autenticación (`lib/services/auth_service.dart`)
- Registro con email/password y con Google Sign-In
- Login por email o por username
- Cambio y reset de contraseña
- Validación de username único
- Manejo de errores en español

### Acceso a datos (`lib/services/firestore_service.dart`)
Servicio central (~967 líneas) que gestiona todas las operaciones contra Firestore:
- Usuarios, seguidores y estilos preferidos
- Productos: CRUD, likes, reseñas, ratings
- Carrito y órdenes de compra
- Chats en tiempo real
- Wishlist (guardados)
- ONGs y publicaciones
- Notificaciones internas

### Almacenamiento (`lib/services/storage_service.dart`)
- Subida de fotos de perfil, productos y posts de ONG a Firebase Storage

### Notificaciones (`lib/services/notification_service.dart`)
- Inicialización y permisos de FCM
- Obtención y persistencia de token FCM
- Handler de mensajes en background (isolate top-level)

---

## Pantallas (34)

### Autenticación
| Ruta | Pantalla |
|------|----------|
| `/` | `SplashScreen` — animación typewriter y detección de sesión activa |
| `/login` | `LoginScreen` — email/username + Google Sign-In |
| `/register` | `RegisterScreen` — registro de usuario estándar |
| `/register-ong` | `RegisterOngScreen` — registro de fundaciones |
| `/complete-profile` | `CompleteProfileScreen` — completar datos post-Google Sign-In |
| `/style-selector` | `StyleSelectorScreen` — estilos de ropa preferidos |

### Marketplace
| Ruta | Pantalla |
|------|----------|
| `/home` | `HomeScreen` — catálogo principal |
| `/explore` | `ExploreScreen` — exploración por categoría |
| `/product-detail` | `ProductDetailScreen` — fotos, descripción y reseñas |
| `/create-product` | `CreateProductScreen` — publicar nueva prenda |
| `/my-products` | `MyProductsScreen` — gestión de productos propios |
| `/saved` | `SavedScreen` — wishlist del usuario |

### Compra
| Ruta | Pantalla |
|------|----------|
| `/cart` | `CartScreen` — carrito de compras |
| `/checkout-1` | `CheckoutStep1Screen` — seleccionar dirección de envío |
| `/checkout-2` | `CheckoutStep2Screen` — seleccionar método de pago (PSE / Nequi) |
| `/checkout-3` | `CheckoutStep3Screen` — confirmar pedido |
| `/order-confirmed` | `OrderConfirmedScreen` — confirmación post-compra |
| `/order-tracking` | `OrderTrackingScreen` — seguimiento de pedido |
| `/orders` | `OrdersScreen` — historial de compras |

### Perfil y cuenta
| Ruta | Pantalla |
|------|----------|
| `/profile` | `ProfileScreen` — perfil propio con estadísticas |
| `/seller-profile` | `SellerProfileScreen` — perfil de otros vendedores |
| `/followers` | `FollowersScreen` — seguidores / seguidos |
| `/addresses` | `AddressesScreen` — gestión de direcciones de envío |
| `/payment-methods` | `PaymentMethodsScreen` — métodos de pago guardados |
| `/settings` | `SettingsScreen` — configuración de cuenta |
| `/my-sales` | `MySalesScreen` — historial de ventas propias |

### Social y mensajería
| Ruta | Pantalla |
|------|----------|
| `/chats-list` | `ChatsListScreen` — listado de conversaciones |
| `/chat` | `ChatScreen` — chat directo en tiempo real |
| `/notifications` | `NotificationsScreen` — centro de notificaciones |

### ONGs y mapa
| Ruta | Pantalla |
|------|----------|
| `/ong` | `OngScreen` — directorio de fundaciones |
| `/create-ong-post` | `CreateOngPostScreen` — publicar campaña |
| `/map` | `MapScreen` — mapa con puntos de recolección y ONGs |

---

## Widgets reutilizables

- **`BottomNav`** — barra de navegación inferior con 5 tabs y badge de mensajes no leídos en tiempo real
- **`SmartBackButton`** — botón atrás que solo se muestra si hay pantalla anterior (`ModalRoute.canPop()`)

---

## Modelo de datos (Firestore)

### `users/{uid}`
```
nombre, apellido, username, email, tipo ("usuario" | "ong"),
foto_perfil, gustos_estilos[], fcm_token, created_at
  ├── following/{uid}
  ├── followers/{uid}
  ├── saved/{productId}
  ├── cart/{itemId}
  ├── addresses/{addressId}
  ├── payment_data/
  └── settings/
```

### `products/{productId}`
```
nombre, descripcion, precio, categoria, talla, fotos[],
vendedor_id, vendedor_nombre, vendedor_foto, activo,
likes_count, rating_avg, rating_count, created_at
  ├── likes/{userId}
  └── reviews/{userId}
```

### `orders/{orderId}`
```
comprador_id, comprador_nombre, items[],
direccion{}, metodo_pago, subtotal, envio, total,
estado ("Pendiente" | "Enviado" | "Entregado"), created_at
```

### `chats/{chatId}` — formato `uid1_uid2`
```
participants[], last_message, last_message_at,
unread_{uid}, hidden_for[], deleted_at_{uid}
  └── messages/{messageId}
        sender_id, text, product_id?, sent_at, read, edited
```

### `ongs/{ongId}`
```
nombre_fundacion, descripcion, foto_perfil, ubicacion, created_at
```

### `ong_posts/{postId}`
```
ong_id, ong_nombre, titulo, descripcion, fotos[], created_at
```

### `notifications/{notifId}`
```
tipo ("nuevo_seguidor" | "nuevo_mensaje" | "pedido_actualizado" | "nueva_donacion"),
destinatario_uid, remitente_uid, remitente_nombre, preview, leido, created_at
```

---

## Funcionalidades implementadas

- [x] Registro e inicio de sesión (email/password y Google)
- [x] Perfil con foto, bio y estadísticas (compras, ventas, seguidores)
- [x] Publicar, editar y eliminar prendas
- [x] Catálogo con filtros por categoría
- [x] Likes y wishlist de productos
- [x] Reseñas con rating (1–5 estrellas)
- [x] Carrito con checkout en 3 pasos
- [x] Múltiples direcciones de envío
- [x] Métodos de pago: PSE y Nequi
- [x] Historial de órdenes con seguimiento y cancelación
- [x] Chat directo en tiempo real con edición y borrado de mensajes
- [x] Badge de mensajes no leídos en tiempo real
- [x] Sistema de seguidores y seguidos
- [x] Directorio de ONGs con posts y campañas
- [x] Notificaciones push (FCM) y notificaciones internas en app
- [x] Mapa interactivo con geolocalización y geocodificación
- [x] Historial de ventas propias

---

## Tema visual

| Token | Valor | Uso |
|-------|-------|-----|
| Color primario | `#B5976A` | Botones, íconos activos |
| Fondo scaffold | `#F5EFE6` | Fondo general de pantallas |
| Fuente | Georgia | Tipografía global |
| Design system | Material Design 3 | Componentes UI |

---

## Permisos requeridos

| Permiso | Plataforma | Uso |
|---------|-----------|-----|
| `ACCESS_FINE_LOCATION` | Android | GPS de alta precisión |
| `ACCESS_COARSE_LOCATION` | Android | GPS de baja precisión |
| `INTERNET` | Android | Conectividad |
| `READ_MEDIA_IMAGES` | Android 13+ | Selección de fotos |
| `READ_EXTERNAL_STORAGE` | Android ≤12 | Selección de fotos |
| `POST_NOTIFICATIONS` | Android 13+ | Notificaciones push |

---

## Configuración Firebase

- **Project ID:** `wearever-eb19c`
- **Storage Bucket:** `wearever-eb19c.firebasestorage.app`
- **Package Android:** `com.wearever.wearever`
- Servicios activos: Authentication, Firestore, Storage, Cloud Messaging

> Los archivos `google-services.json` y `GoogleService-Info.plist` son necesarios para compilar. Solicítalos al equipo.

---

## Instalación y ejecución

```bash
# Clonar el repositorio
git clone https://github.com/ma-sarmiento/WearEver.git
cd WearEver

# Instalar dependencias
flutter pub get

# Ejecutar en modo debug
flutter run

# Build Android release
flutter build apk --release

# Build iOS release
flutter build ipa --release
```

**Requisitos previos:**
- Flutter SDK ≥ 3.0 / Dart SDK ≥ 3.9.2
- Android SDK (API 21+) o Xcode (para iOS)
- Archivos de configuración de Firebase en sus rutas correspondientes

---

> Proyecto académico de Ingeniería de Sistemas desarrollado para abordar problemáticas reales de sostenibilidad en el sector textil de Bogotá, Colombia.
