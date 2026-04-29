# ♻️ WearEver: Moda Circular Inteligente

Aplicación móvil multiplataforma desarrollada en **Flutter**, diseñada para mitigar el impacto ambiental de la industria textil en Colombia. Facilita la compra, venta, donación y reciclaje de prendas, integrando un sistema de puntos y recomendaciones inteligentes para fomentar la economía circular.

Este proyecto nace como una solución a las **160,000 toneladas de residuos textiles** que terminan anualmente en el relleno sanitario Doña Juana de Bogotá.

---
## 👥 Contribuidores

Este proyecto es desarrollado por estudiantes de Ingeniería de Sistemas:
- 👨‍💻 **Miguel Sarmiento**
- 👨‍💻 **Daniel Cristancho**
- 👨‍💻 **Andrés Pinzón**
- 👨‍💻 **Juan Nonsoque**
  
---

## 🚀 Funcionalidades principales

- ✅ **Marketplace Sostenible:** Catálogo dinámico para la compra y venta de ropa de segunda mano.
- ✅ **Gestión de Donaciones:** Conexión directa con ONGs para facilitar el flujo de prendas a personas en situación de vulnerabilidad.
- ✅ **Sistema de Puntos:** Gamificación para usuarios que realizan acciones sostenibles (donar/reciclar).
- ✅ **Tito (Smart Assistant):** Recomendaciones personalizadas basadas en el perfil y preferencias del usuario.
- ✅ **Geolocalización:** Mapa interactivo con puntos de recolección, reciclaje y sedes de ONGs.
- ✅ **Perfil de Usuario:** Seguimiento de impacto ambiental y gestión de publicaciones.

---

## 📁 Estructura del proyecto

```plaintext


```
## 📌 Importante: ¿Por qué no se incluyen las carpetas nativas (android, ios, web)?

Para mantener el repositorio:

✅ **Más limpio:** Enfocado exclusivamente en la lógica de negocio y arquitectura.  
✅ **Más ligero:** Se evita subir archivos binarios y configuraciones generadas automáticamente.   

*Nota: Las carpetas nativas son generadas automáticamente por Flutter y se pueden regenerar localmente con el comando `flutter create .`*

---

## 📄 Modelo de datos

El proyecto utiliza una arquitectura orientada a objetos para manejar la complejidad del negocio textil:

- **Items (Prendas):** Gestión de tallas (XS-XL), colores, marcas y estados de conservación.
- **Transacciones:** Lógica para compra directa o coordinación de donaciones.
- **Impacto Social:** Registro de donaciones y algoritmo de puntos para premiar la circularidad.

**Patrones aplicados:**
- Separation of Concerns (SoC).
- Repository Pattern para el manejo de datos.
- Manejo de estados eficiente (Provider).

---

## 📸 Capturas de pantalla (UI Design)

> *Próximamente: Capturas de pantalla de la interfaz final y prototipos de alta fidelidad.*

---

## 🚀 Instalación y ejecución

Sigue estos pasos para clonar y ejecutar el proyecto correctamente en tu entorno local.

### 1️⃣ Clonar el repositorio
```bash

git clone [https://github.com/ma-sarmiento/WearEver](https://github.com/ma-sarmiento/WearEver)
cd WearEver
```
### 2️⃣ Instalar Dependencias
```bash
flutter pub get
```

### 3️⃣ Regenerar Carpetas Nativas
```bash
flutter create .
```

### 4️⃣ Ejecutar el Proyecto
```bash
flutter run
```
---

📦 Dependencias principales
```plaintext
provider: ^6.1.1
google_maps_flutter: ^2.5.3
http: ^1.2.0
cupertino_icons: ^1.0.8
```
---

>  Nota: Por razones de derechos académicos, el enunciado original del proyecto **no será publicado en este repositorio**.

> Nota Académica: WearEver es un proyecto de innovación desarrollado para abordar problemáticas reales de sostenibilidad en el sector textil de Bogotá, Colombia.
