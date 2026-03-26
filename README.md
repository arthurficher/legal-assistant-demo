# Legal Assistant - Demo para Entrevista

Aplicación de demostración que muestra un asistente legal potenciado por IA usando Google Gemini.

## Características

- **Autenticación Mock**: Login de prueba para demostración rápida
- **Chat con IA**: Integración con Google Gemini 2.5 Flash
- **Asistente Legal Especializado**: IA configurada para responder solo preguntas legales de Paraguay
- **Interfaz Moderna**: UI limpia y profesional con soporte para modo oscuro
- **Chat Inteligente**: Campo de texto multilínea con capitalización automática

## Credenciales de Prueba

Para acceder a la aplicación, usa estas credenciales:

- **Email**: `test@test.com`
- **Password**: `test123`

## Tecnologías Utilizadas

- **Flutter**: Framework multiplataforma
- **Google Generative AI**: Gemini 2.5 Flash para respuestas inteligentes
- **Provider**: Gestión de estado
- **Hive**: Base de datos local
- **Material 3**: Diseño moderno

## Requisitos Previos

- Flutter SDK (>=3.3.1 <4.0.0)
- Dart SDK
- Android Studio / VS Code
- API Key de Google Gemini (para usar la IA real)

## Instalación y Ejecución

### 1. Clonar el repositorio

```bash
git clone <URL_DEL_NUEVO_REPOSITORIO>
cd flutter_gemini
```

### 2. Instalar dependencias

```bash
flutter pub get
```

### 3. Configurar API Key (Opcional)

Si quieres usar Gemini real en lugar del modo mock:

1. Crea un archivo `.env` en la raíz del proyecto:
```bash
GEMINI_API_KEY=tu_api_key_aqui
```

2. En `lib/constants.dart`, cambia:
```dart
static const bool useMockChat = false;
```

### 4. Ejecutar la aplicación

```bash
flutter run
```

## Generar APK

### APK de Debug (Rápido)

```bash
flutter build apk --debug
```

El APK se generará en: `build/app/outputs/flutter-apk/app-debug.apk`

### APK de Release (Optimizado)

```bash
flutter build apk --release
```

El APK se generará en: `build/app/outputs/flutter-apk/app-release.apk`

### APK dividido por arquitectura (Más pequeño)

```bash
flutter build apk --split-per-abi --release
```

Genera 3 APKs optimizados:
- `app-armeabi-v7a-release.apk` (ARM 32-bit)
- `app-arm64-v8a-release.apk` (ARM 64-bit) ← Recomendado para la mayoría
- `app-x86_64-release.apk` (x86 64-bit)

## Características de la Demo

### Modo Mock Activado
Por defecto, la aplicación usa respuestas mock para demostración:
- **Login Mock**: Autenticación simulada
- **Chat Mock**: Respuestas predefinidas para demostración sin API key

### Modo Real (Con API Key)
Con una API key de Gemini configurada:
- **Chat Real**: Respuestas inteligentes de Google Gemini
- **Especialización Legal**: La IA solo responde preguntas del ámbito legal paraguayo

## Estructura del Proyecto

```
lib/
├── main.dart                 # Punto de entrada
├── constants.dart            # Configuración (mock/real)
├── providers/
│   └── chat_provider.dart    # Lógica del chat
├── screens/
│   ├── login.dart           # Pantalla de login
│   ├── chat_screen.dart     # Pantalla de chat
│   └── home_screen.dart     # Pantalla principal
├── widgets/
│   ├── bottom_chat_field.dart  # Campo de entrada
│   └── chat_messages.dart      # Lista de mensajes
└── models/
    └── message.dart         # Modelo de mensaje
```

## Pruebas Sugeridas

1. **Login**: Usa `test@test.com` / `test123`
2. **Saludo**: Escribe "Hola" → La IA responde amablemente
3. **Pregunta Legal**: "¿Cuáles son los requisitos para un divorcio en Paraguay?" → Respuesta legal
4. **Pregunta No Legal**: "¿Cuál es la capital de Francia?" → Rechaza cortésmente
5. **Multilínea**: Escribe un mensaje largo con Enter para probar el campo expandible

## Contacto

Este es un proyecto de demostración creado para proceso de entrevista.

---

**Nota**: Esta es una versión simplificada para demostración. No incluye funcionalidades completas de producción.
