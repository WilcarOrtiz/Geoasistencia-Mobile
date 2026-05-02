<p align="center">
  <img src="https://storage.googleapis.com/cms-storage-bucket/6a07d8a62f4308d2b854.svg" width="80" alt="Flutter" />
</p>

<h1 align="center">GeoAsistencia — App Móvil</h1>

<p align="center">
  Aplicación Flutter para el control de asistencia académica basada en <strong>geolocalización GPS</strong> y <strong>Bluetooth BLE</strong>.<br/>
  Diseñada para docentes y estudiantes del SENA.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-SDK%203.11-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/Supabase-Auth-3FCF8E?style=for-the-badge&logo=supabase&logoColor=white" alt="Supabase" />
  <img src="https://img.shields.io/badge/Riverpod-3.x-0560FD?style=for-the-badge&logo=dart&logoColor=white" alt="Riverpod" />
  <img src="https://img.shields.io/badge/Plataforma-Android%20%7C%20iOS-lightgrey?style=for-the-badge&logo=android&logoColor=white" alt="Plataformas" />
  <img src="https://img.shields.io/badge/Estado-En%20desarrollo-orange?style=for-the-badge" alt="Estado" />
</p>

---

## ✨ Descripción general

GeoAsistencia Mobile es el cliente móvil del sistema de control de asistencia del SENA. Funciona en conjunto con el **backend NestJS** (GeoAsistencia-SENA) y permite a docentes y estudiantes gestionar el llamado a lista de forma segura y verificable mediante dos capas de validación:

1. **Proximidad BLE (Bluetooth Low Energy):** el docente emite un código de sesión como beacon BLE; el estudiante solo puede recibirlo si está físicamente cerca (~10 m).
2. **Geolocalización GPS:** al marcar asistencia, el backend valida que las coordenadas del estudiante estén dentro del radio configurado respecto a la ubicación del docente.

---

## 🏗️ Arquitectura

El proyecto sigue una arquitectura **Feature-First** con separación clara entre capas de datos, dominio y presentación. El manejo de estado global se hace con **Riverpod**.

```
lib/
├── core/
│   ├── constants/        # Rutas de navegación (AppRoutes)
│   ├── network/          # Cliente Dio + modelos de respuesta paginada
│   ├── services/
│   │   ├── ble_service.dart        # Advertising y escaneo BLE
│   │   ├── location_service.dart   # GPS de alta precisión
│   │   └── permission_service.dart # Manejo de permisos del dispositivo
│   ├── theme/            # Tema Material 3
│   └── utils/            # Almacenamiento local (SharedPreferences)
│
└── features/
    ├── auth/             # Login, onboarding, splash, roles
    ├── groups/           # Listado y detalle de grupos de clase
    ├── sessions/         # Apertura de sesión de lista (docente)
    ├── attendance/       # Marcado e historial de asistencia (estudiante)
    └── home/             # Pantalla principal post-login
```

---

## 🔄 Flujo de uso por rol

### Docente
1. Inicia sesión con sus credenciales de Supabase.
2. Ve sus grupos de clase asignados.
3. Entra al detalle de un grupo y presiona **"Iniciar llamado a lista"**.
4. El sistema obtiene su ubicación GPS y la envía al backend para crear la sesión.
5. El dispositivo comienza a **emitir un beacon BLE** con el código UUID de la sesión.
6. Cuando termina, presiona **"Detener llamado a lista"**: el BLE se apaga y la sesión se cierra en el backend.

### Estudiante
1. Inicia sesión con sus credenciales de Supabase.
2. Ve sus grupos matriculados.
3. Entra al detalle de un grupo y presiona **"Registrar mi asistencia"**.
4. El app **escanea dispositivos BLE** cercanos, extrae el código de sesión del beacon del docente.
5. Obtiene su ubicación GPS actual.
6. Envía el código + coordenadas al backend, que valida la proximidad y marca la asistencia.
7. Si fue exitoso, el mapa muestra la ubicación donde se registró la asistencia.
8. Puede ver su **historial de asistencia** por grupo con tasa de asistencia acumulada.

---

## 📦 Dependencias principales

| Paquete | Versión | Uso |
|---|---|---|
| `supabase_flutter` | ^2.12.4 | Autenticación y cliente de base de datos |
| `flutter_riverpod` | ^3.3.1 | Manejo de estado global |
| `dio` | ^5.9.2 | Cliente HTTP para el backend NestJS |
| `flutter_blue_plus` | ^2.2.1 | Escaneo BLE (estudiante) |
| `flutter_ble_peripheral` | ^2.1.0 | Advertising BLE (docente) |
| `geolocator` | ^14.0.2 | GPS de alta precisión |
| `google_maps_flutter` | ^2.17.0 | Mapa de confirmación de asistencia |
| `permission_handler` | ^12.0.1 | Solicitud de permisos en runtime |
| `shared_preferences` | ^2.5.5 | Almacenamiento local (UUID de dispositivo) |
| `flutter_dotenv` | ^6.0.1 | Variables de entorno desde `.env` |
| `uuid` | ^4.5.3 | Generación de UUID de dispositivo |
| `intl` | ^0.20.2 | Formato de fechas y horas |

---

## 🚀 Cómo correr el proyecto

### Requisitos previos

- **Flutter SDK** `>= 3.11.5` ([instalar Flutter](https://docs.flutter.dev/get-started/install))
- **Dart SDK** `>= 3.11.5` (incluido con Flutter)
- **Android Studio** o **Xcode** (para emuladores/dispositivos)
- Dispositivo físico o emulador con soporte Bluetooth (BLE requiere hardware real para funcionar correctamente)
- **Google Maps API Key** configurada para Android/iOS
- Cuenta de **Supabase** con el proyecto del backend activo

### 1. Clonar el repositorio

```bash
git clone https://github.com/WilcarOrtiz/Geoasistencia-Mobile.git
cd Geoasistencia-Mobile
```

### 2. Instalar dependencias

```bash
flutter pub get
```

### 3. Configurar variables de entorno

Crea un archivo `.env` en la raíz del proyecto con el siguiente contenido:

```env
SUPABASE_URL=https://tu-proyecto.supabase.co
SUPABASE_ANON_KEY=tu_anon_key_publica
```

> ⚠️ **Importante:** el archivo `.env` ya está listado como asset en `pubspec.yaml`. No lo renombres.

### 4. Configurar Google Maps

#### Android
Agrega tu API Key en `android/app/src/main/AndroidManifest.xml`:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="TU_API_KEY_AQUÍ"/>
```

#### iOS
Agrega tu API Key en `ios/Runner/AppDelegate.swift`:

```swift
GMSServices.provideAPIKey("TU_API_KEY_AQUÍ")
```

### 5. Correr la aplicación

```bash
# En modo debug
flutter run

# Para un dispositivo específico
flutter run -d <device_id>

# Listar dispositivos disponibles
flutter devices
```

---

## 🔐 Permisos requeridos

### Android (declarados en `AndroidManifest.xml`)

| Permiso | Motivo |
|---|---|
| `BLUETOOTH_SCAN` | Escanear beacons BLE cercanos (estudiante) |
| `BLUETOOTH_ADVERTISE` | Emitir beacon BLE con código de sesión (docente) |
| `BLUETOOTH_CONNECT` | Gestionar conexiones Bluetooth |
| `ACCESS_FINE_LOCATION` | GPS de alta precisión para validar asistencia |
| `ACCESS_COARSE_LOCATION` | Ubicación aproximada (requerido por Android junto con FINE) |

> **Nota:** Android 12+ requiere los permisos `BLUETOOTH_SCAN` y `BLUETOOTH_ADVERTISE` además de ubicación. La app los solicita en tiempo de ejecución desde `PermissionService`.

### iOS (`Info.plist`)

- `NSLocationWhenInUseUsageDescription`
- `NSBluetoothAlwaysUsageDescription`

---

## 🗺️ Pantallas y navegación

| Ruta | Pantalla | Descripción |
|---|---|---|
| `/onboarding` | `OnboardingScreen` | Pantalla de bienvenida inicial |
| `/` | `SplashScreen` | Verifica sesión activa y redirige |
| `/login` | `LoginScreen` | Formulario de autenticación con Supabase |
| `/permissions` | `PermissionGateScreen` | Solicita permisos BLE y GPS antes de continuar |
| `/home` | `HomeScreen` | Panel principal con grupos del usuario |
| `/group-detail` | `GroupDetailScreen` | Detalle de grupo: info, días y acciones por rol |
| `/open-session` | `OpenSessionScreen` | Docente: inicia llamado a lista con BLE activo |
| `/mark-attendance` | `MarkAttendanceScreen` | Estudiante: escanea BLE y registra asistencia con GPS |
| `/my-attendance` | `MyAttendanceScreen` | Estudiante: historial y estadísticas de asistencia |

---

## ⚙️ Configuración técnica del BLE

La lógica BLE está centralizada en `lib/core/services/ble_service.dart`:

- **Docente (periférico):** usa `flutter_ble_peripheral` para anunciar el UUID de sesión en el campo `manufacturerData` del beacon. Company ID: `0xFFFF`. No se requiere conexión (advertising pasivo).
- **Estudiante (central):** usa `flutter_blue_plus` para escanear durante máximo 15 segundos. Filtra los beacons por el `companyId` y valida que el payload sea un UUID v4 válido.
- **Timeout:** si no se detecta sesión en 15 s, lanza excepción descriptiva al usuario.

---

## 📊 Manejo de estado (Riverpod)

| Provider | Tipo | Responsabilidad |
|---|---|---|
| `authProvider` | `AsyncNotifier` | Sesión de Supabase y perfil del usuario |
| `userRoleProvider` | `Provider` | Rol activo del usuario (TEACHER / STUDENT) |
| `groupsProvider` | `AsyncNotifier` | Listado de grupos según rol |
| `classDayProvider` | `FutureProvider.family` | Días de clase de un grupo |
| `openSessionProvider` | `AsyncNotifier` | Estado del llamado a lista activo (docente) |
| `markAttendanceProvider` | `AsyncNotifier.family` | Proceso de escaneo BLE + GPS + registro |
| `attendanceProvider` | `FutureProvider.family` | Historial de asistencias del estudiante |

---

## 🔗 Integración con el Backend

La app se comunica con el backend **GeoAsistencia-SENA** (NestJS) mediante HTTP a través de `DioClient`. El token JWT emitido por Supabase se adjunta automáticamente en cada petición.

Endpoints principales consumidos:

| Método | Endpoint | Uso en la app |
|---|---|---|
| `GET` | `/api/class-groups` | Cargar grupos del usuario |
| `GET` | `/api/class-days/group/:id` | Días de clase de un grupo |
| `POST` | `/api/class-sessions` | Abrir sesión (docente) |
| `PATCH` | `/api/class-sessions/:id/close` | Cerrar sesión (docente) |
| `PATCH` | `/api/attendances` | Registrar asistencia (estudiante) |
| `GET` | `/api/attendances/group/:id/my-history` | Historial del estudiante |

---

## 🧱 Estructura del `.env`

```env
# URL del proyecto Supabase
SUPABASE_URL=https://<referencia>.supabase.co

# Clave anónima pública de Supabase (safe to expose in client)
SUPABASE_ANON_KEY=sb_publishable_...
```

---

## 📄 Licencia

Este proyecto es de uso académico y fue desarrollado como proyecto de grado para el **SENA**. No está destinado a publicación en tiendas de aplicaciones.
