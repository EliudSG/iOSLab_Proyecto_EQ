# Proyecto: MI.CU — Mi Calendario Universitario (UANL)

## Visión General

MI.CU es una aplicación móvil nativa para iOS desarrollada en **Swift + SwiftUI**, con backend en **Supabase**. Su propósito es gestionar las Actividades Formativas Integrales (AFI) de la Universidad Autónoma de Nuevo León (UANL).

---

## Arquitectura de Software

**Patrón:** MVVM (Model-View-ViewModel)

```
MiCU/
├── Models/         # Structs Codable con correspondencia 1:1 a tablas de Supabase
├── ViewModels/     # Lógica de negocio, llamadas async/await a Supabase SDK
├── Views/
│   ├── Auth/       # Splash, Onboarding, Login
│   ├── Main/       # Calendario principal, vista de día
│   ├── AFI/        # Lista de AFIs, detalle de evento, inscripción
│   ├── Settings/   # Configuración, FAQ, Alarma
│   └── Personal/   # Recordatorios, notas personales
├── Services/       # SupabaseClient singleton, gestión de red y autenticación
└── Resources/
    ├── Assets/     # Imágenes, íconos, colores de categorías AFI
    └── Localizable.strings  # Soporte ES / EN
```

---

## Modelo de Datos (Supabase)

> **Regla de RLS:** `Recordatorios_Personales` y `Alarmas` son **privadas** por usuario. `Eventos` es de lectura pública para usuarios autenticados.

### Tablas y relaciones clave

```
Usuarios (1) ──── (1) Alumnos
Usuarios (1) ──── (1) Organizadores
Eventos  (1) ──── (N) Inscripciones ──── (1) Alumnos   [Many-to-Many]
Usuarios (1) ──── (N) Alarmas
Usuarios (1) ──── (N) Recordatorios_Personales
```

### Schema completo

```sql
-- Usuarios: tabla base para todos los roles
CREATE TABLE public.Usuarios (
  matricula               numeric        NOT NULL PRIMARY KEY,
  nombre                  text           NOT NULL,
  facultad                text,
  tipo_Usuario            text,
  fecha_Registro          date,
  email                   text,
  role                    user_role      NOT NULL DEFAULT 'student',
  tema                    text           DEFAULT 'claro',
  idioma                  text           DEFAULT 'español',
  notificaciones_activas  boolean        DEFAULT true,
  created_at              timestamptz    DEFAULT now()
);

-- Alumnos: extiende Usuarios para el rol estudiante
CREATE TABLE public.Alumnos (
  matricula   numeric    NOT NULL PRIMARY KEY REFERENCES public.Usuarios(matricula),
  semester    integer,
  created_at  timestamptz DEFAULT now()
);

-- Organizadores: extiende Usuarios para gestores de eventos
CREATE TABLE public.Organizadores (
  matricula   numeric  NOT NULL PRIMARY KEY REFERENCES public.Usuarios(matricula),
  department  text,
  created_at  timestamptz DEFAULT now()
);

-- Eventos: catálogo de AFIs institucionales
CREATE TABLE public.Eventos (
  id                      bigint         GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  nombre_Evento           text,
  categoria               categoria_afi, -- tipo ENUM definido abajo
  fecha_evento            date,
  hora_Inicio             time,
  hora_Fin                time,
  lugar                   text,
  aforo                   numeric,
  descripcion             text,
  image_url               text,
  telefono_Responsable    text,
  departamento_Solicitante text,
  insumos                 jsonb,         -- requerimientos flexibles por AFI
  organizador_id          numeric REFERENCES public.Usuarios(matricula),
  estado                  text           DEFAULT 'publicado'
);

-- Inscripciones: relación alumno ↔ evento
CREATE TABLE public.Inscripciones (
  id           uuid     NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  evento_id    bigint   NOT NULL REFERENCES public.Eventos(id),
  alumno_id    numeric  NOT NULL REFERENCES public.Alumnos(matricula),
  signed_up_at timestamptz DEFAULT now(),
  finalizada   boolean
);

-- Recordatorios_Personales: notas privadas del alumno
CREATE TABLE public.Recordatorios_Personales (
  id                   uuid           NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  usuario_id           numeric REFERENCES public.Usuarios(matricula),
  titulo               text           NOT NULL,
  nota                 text,
  prioridad            priority_level DEFAULT 'Básico', -- ENUM: Básico | Importante | Urgente
  fecha_recordatorio   date,
  hora_recordatorio    time,
  created_at           timestamptz    DEFAULT now()
);

-- Alarmas: alertas configuradas por el usuario
CREATE TABLE public.Alarmas (
  id          uuid    NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  usuario_id  numeric REFERENCES public.Usuarios(matricula),
  titulo      text,
  hora        time    NOT NULL,
  fecha       date,
  activa      boolean DEFAULT true
);
```

### ENUMs de dominio

```sql
-- Categorías de AFI (10 tipos oficiales UANL)
CREATE TYPE categoria_afi AS ENUM (
  'Investigación',
  'Culturales',
  'Institucional',
  'Académicas',
  'Artística',
  'Idiomas',
  'Responsabilidad Social',
  'Deportivas',
  'Intercambio Académico',
  'Innovación y Emprendimiento'
);

-- Nivel de prioridad de recordatorios personales
CREATE TYPE priority_level AS ENUM ('Básico', 'Importante', 'Urgente');

-- Roles de usuario en el sistema
CREATE TYPE user_role AS ENUM ('student', 'organizer', 'admin');
```

---

## Módulos y Flujo de Pantallas

Basado en el Diagrama de Flujo y Storyboard oficial del equipo:

### A. Autenticación y Onboarding
1. **Splash** — Logo MI.CU, transición automática (~2 s).
2. **Login** — Correo universitario + contraseña. Botón "Servicios en Línea".
3. **Onboarding (x2 slides)** — Bienvenida con imagen UANL. Botón "Siguiente".
4. **Registro / Validación de cuenta** — Validación de matrícula UANL.
5. **Configuración inicial** — Idioma (Español/Inglés), Tema (Claro/Oscuro), Notificaciones.

### B. Pantalla Principal (Home)
- Calendario mensual con navegación por flechas (← mes →).
- Botón `+` para agregar actividades rápidas.
- Menú hamburguesa (`≡`) con: Preguntas frecuentes, Cerrar sesión, Configuración, Alarma.
- Al pulsar un día: lista de AFIs disponibles ese día (categoría, hora, sede).
- Sección de notas deslizables con tarjetas de colores.

### C. Módulo AFI
- **Tab AFI** en la barra inferior: lista de tipos de AFI con filtros Pendientes / Finalizadas.
- **Detalle de evento**: imagen, nombre, hora, sede, teléfono, fecha, descripción (con scroll), botón estrella ☆ para marcar como finalizada.
- **Contador de progreso**: muestra `X/14` y distingue semestre actual vs. histórico general.
- Límite semestral visible: máx. 2 AFIs completadas por semestre.

### D. Módulo Mis Eventos (Tab derecho)
- Lista de eventos inscritos con categoría, hora, sede y badge "Tarea".
- Acceso a detalle con información completa e indicador "¡Finalizada!".

### E. Herramientas Personales
- **Recordatorios / Notas**: popup al pulsar "Añadir nota" con título, color (rosa/naranja/azul) y cuerpo de texto.
- **Alarma**: formulario con título, selector de hora (scroll HH:MM, AM/PM) y fecha. Pantalla de alarma activa con botón ✕.

### F. Configuración (desde menú hamburguesa)
- **Tema**: Oscuro / Claro (toggle, persiste en `Usuarios.tema`).
- **Idioma**: Español / Inglés (toggle, persiste en `Usuarios.idioma`).
- **Notificaciones**: toggle global.
- **Contacto**: dirección y teléfono institucional.
- **FAQ**: pantalla con acordeones de preguntas frecuentes.

---

## Paleta Visual por Categoría AFI

```swift
// Usar estos colores exactos al renderizar badges y tarjetas de categoría
extension Color {
    static let afiCulturales           = Color(hex: "#E8934A") // Naranja
    static let afiDeportivas           = Color(hex: "#5B9BD5") // Azul medio
    static let afiAcademicas           = Color(hex: "#E05C5C") // Rojo/rosa
    static let afiResponsabilidadSocial = Color(hex: "#8E7CC3") // Morado
    static let afiInnovacion           = Color(hex: "#4A90D9") // Azul oscuro
    static let afiInvestigacion        = Color(hex: "#5BA85B") // Verde
    static let afiIdiomas              = Color(hex: "#D4A017") // Amarillo dorado
    static let afiArtistica            = Color(hex: "#C06090") // Rosa fuerte
    static let afiIntercambio          = Color(hex: "#3ABFBF") // Teal
    static let afiInstitucional        = Color(hex: "#7B7B7B") // Gris
    // Color primario general de la app (barra inferior, acentos)
    static let miCuPrimary             = Color(hex: "#4A9B8E") // Verde teal
}
```

---

## Lógica de Negocio Crítica

### 1. Finalización de AFI
- El alumno toca ☆ en el detalle de un evento inscrito.
- Se actualiza `Inscripciones.finalizada = true` en Supabase.
- El contador `X/14` y el indicador de semestre se recalculan en el ViewModel.

### 2. Límite por semestre
- Máximo 2 AFIs marcadas como `finalizada = true` por semestre se cuentan para el estatus de "completado" oficial.
- El alumno puede inscribirse a más; el excedente se acumula para el siguiente semestre.

### 3. Preferencias de usuario (Tema e Idioma)
- Se guardan en `Usuarios.tema` y `Usuarios.idioma` al cambiar.
- Se aplican globalmente al lanzar la app leyendo el perfil del usuario autenticado.

---

## Convenciones de Código (Swift / SwiftUI)

- Usa **`async/await`** para todas las llamadas a la SDK de Supabase. Evita callbacks.
- Los `Model` structs deben conformar a `Codable` con `CodingKeys` que mapeen exactamente los nombres de columna de Supabase (snake_case → camelCase).
- Los `ViewModel` exponen `@Published` vars para que las `View` reaccionen automáticamente.
- No usar `UIKit` directamente; toda la UI debe estar en **SwiftUI**.
- Los colores se definen como extensión de `Color` en `Resources/Colors.swift` (ver paleta arriba).
- Las cadenas localizables van siempre en `Localizable.strings` y se acceden con `NSLocalizedString` o el macro `String(localized:)`.
- El campo `insumos` de `Eventos` es `jsonb`; modélalo en Swift como `[String: AnyCodable]` o un struct específico según el contexto.

## Convenciones de Nombrado

- **Archivos:** `NombreVista.swift`, `NombreViewModel.swift`, `NombreModel.swift`.
- **Structs de modelo:** singular en inglés que refleje la tabla (`Evento`, `Inscripcion`, `Alarma`).
- **ViewModels:** sufijo `ViewModel` (`EventoViewModel`, `AFIListViewModel`).
- **Views:** sufijo `View` (`CalendarioView`, `EventoDetalleView`).

---

## Notas para el Asistente de IA

Al generar código o responder preguntas sobre este proyecto:

1. **Supabase SDK en Swift:** usa siempre `async/await`. Ejemplo mínimo: `try await supabase.from("Eventos").select().execute()`.
2. **RLS primero:** antes de diseñar cualquier query, considera si la tabla tiene RLS activo. `Recordatorios_Personales` y `Alarmas` filtran por `usuario_id` del JWT automáticamente.
3. **`insumos` como JSONB:** no asumas una estructura fija; usa decodificación dinámica o un typealias `[String: JSONValue]`.
4. **No mezclar roles:** un `Alumno` no puede crear `Eventos`; un `Organizador` no tiene `Inscripciones`. Valida el `role` del usuario autenticado antes de mostrar opciones de UI.
5. **Localización obligatoria:** toda cadena visible en la UI debe estar en `Localizable.strings` para los idiomas `es` y `en`.
6. **Paleta de colores:** usa los colores definidos en la sección "Paleta Visual" para los badges de categoría; no uses colores arbitrarios.
7. **Arquitectura MVVM:** no pongas lógica de negocio ni llamadas a Supabase directamente en las `View`.