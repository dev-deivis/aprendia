# Aprendía

Aplicación móvil Android desarrollada en Flutter que actúa como tutora con inteligencia artificial para adultos mexicanos en situación de rezago educativo, apoyando el programa **INEA / MEVyT** (Modelo Educación para la Vida y el Trabajo).

---

## ¿Qué problema resuelve?

En México, millones de adultos mayores de 15 años no completaron su educación básica. El programa INEA/MEVyT les ofrece una segunda oportunidad, pero muchos no tienen acceso a tutores presenciales ni horarios flexibles.

**Aprendía** pone una tutora inteligente en el bolsillo del usuario: disponible a cualquier hora, adaptada a su nivel educativo y diseñada para el contexto cultural mexicano.

---

## ¿Cómo funciona?

La tutora sigue la filosofía **Khanmigo** — nunca da la respuesta directa. En cambio, guía al usuario con preguntas para que llegue a la solución por sí mismo, construyendo confianza y comprensión real.

### Niveles educativos soportados

| Nivel | Descripción |
|-------|-------------|
| **Alfabetización** | Aprender a leer y escribir por primera vez |
| **Primaria** | Equivalente a 1° a 6° grado |
| **Secundaria** | Equivalente a 1° a 3° de secundaria |

Cada nivel tiene un **system prompt distinto** que adapta el vocabulario, los ejemplos y la pedagogía de la tutora.

---

## Características principales

- **Tutora IA adaptativa** — respuestas personalizadas por nivel educativo usando Gemini 2.5 Flash
- **Ejemplos cotidianos mexicanos** — mercado, pesos, tortillas, fiestas patrias, campo
- **Onboarding sencillo** — el usuario elige su nivel y nombre en menos de 1 minuto
- **Persistencia local** — el perfil del usuario se guarda en el dispositivo con Hive
- **Texto a voz** — las respuestas de la tutora se pueden escuchar en español mexicano
- **Interfaz cálida** — paleta de colores inspirada en artesanía mexicana (terracota, marigold, verde jade)

---

## Stack tecnológico

| Capa | Tecnología |
|------|-----------|
| Framework | Flutter 3.41+ |
| Lenguaje | Dart 3 |
| IA | Google Gemini 2.5 Flash (via REST API) |
| Estado | Riverpod (StateNotifier) |
| Persistencia | Hive Flutter |
| Texto a voz | flutter_tts (español mexicano) |
| Plataforma objetivo | Android físico |

---

## Estructura del proyecto

```
lib/
├── core/
│   ├── constants/       # Colores, strings, rutas
│   └── theme/           # Tema global Material 3
├── features/
│   ├── onboarding/      # Selección de nivel educativo
│   ├── chat/            # Pantalla principal del tutor
│   └── profile/         # Progreso del usuario
└── shared/
    ├── models/          # UserProfile, Message
    ├── services/        # GeminiService, TtsService
    └── widgets/         # Widgets reutilizables
```

---

## Capturas de pantalla

> _Próximamente_

---

## Configuración para desarrolladores

### Requisitos previos

- Flutter 3.41 o superior
- Android SDK (dispositivo físico recomendado)
- Cuenta en [Google AI Studio](https://aistudio.google.com) para obtener API key gratuita

### 1. Clonar el repositorio

```bash
git clone https://github.com/TU_USUARIO/aprendia.git
cd aprendia
```

### 2. Configurar la API key

El archivo con la API key **no se incluye en el repositorio** por seguridad. Cada desarrollador debe crearlo localmente:

```bash
cp lib/shared/services/claude_service.example.dart \
   lib/shared/services/claude_service.dart
```

Luego abre `lib/shared/services/claude_service.dart` y reemplaza `YOUR_GEMINI_API_KEY` con tu key real:

```dart
static const String _apiKey = 'TU_API_KEY_AQUI';
```

**¿Cómo obtener tu API key gratuita?**
1. Ve a [aistudio.google.com](https://aistudio.google.com)
2. Inicia sesión con tu cuenta Google
3. Haz clic en **Get API key** → **Create API key**
4. Copia la key (empieza con `AIza...`)

> El plan gratuito incluye suficientes requests para desarrollo y pruebas.

### 3. Instalar dependencias y correr

```bash
flutter pub get
flutter run
```

### Nota importante

Nunca subas tu `claude_service.dart` con la API key real al repositorio. El archivo ya está en `.gitignore` para protegerlo.

---

## Equipo

Proyecto desarrollado en el **Instituto Tecnológico de Oaxaca** — 8vo semestre.
