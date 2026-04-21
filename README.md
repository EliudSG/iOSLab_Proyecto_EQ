# 📅 MI.CU — Mi Calendario Universitario UANL

![Swift](https://img.shields.io/badge/Swift-FA7343?style=for-the-badge&logo=swift&logoColor=white)
![SwiftUI](https://img.shields.io/badge/SwiftUI-000000?style=for-the-badge&logo=swift&logoColor=white)
![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white)
![iOS](https://img.shields.io/badge/iOS-000000?style=for-the-badge&logo=apple&logoColor=white)
![TDD](https://img.shields.io/badge/TDD_Swift_Testing-Expert-blue?style=for-the-badge&logo=swift)

MI.CU es una aplicación nativa para iOS de última generación diseñada para la comunidad de la **Universidad Autónoma de Nuevo León (UANL)**. Su principal objetivo es simplificar, organizar y gamificar un requisito indispensable de graduación para los universitarios: **Las Actividades Formativas Integrales (AFI)**.

Este repositorio documenta todo el ecosistema y la arquitectura de este cliente iOS, preparado con "Zero Crashes" técnicos de interplataforma y respaldado en la nube con Supabase.

---

## 🎓 ¿Qué es MI.CU y qué problema resuelve?

En la dinámica universitaria, los estudiantes deben acumular "Puntos AFI" asistiendo a eventos extra-académicos (exposiciones, deportes, conferencias, etc). Sin embargo, saber qué eventos están disponibles, dónde se realizan y cuántos puntos tienen validez a lo largo del duro semestre suele ser muy caótico y desordenado. 

**MI.CU** soluciona esto democratizando el catálogo de AFIs en un diseño amigable:
1. **Para Estudiantes**: Es tu agenda íntima. Ves el calendario, encuentras eventos atractivos (Arte, Investigación, Deportes), te registras, apartas tus alarmas y le das "Check" a la tarea. La app te marcará tu estatus semestral (`Ej: Tienes X límite de 14 permitidos`).
2. **Para Organizadores**: Brinda una plataforma expedita para publicar en masa los próximos foros y sus ubicaciones sin dependencias a sistemas obsoletos institucionales.

---

## 🚀 Soluciones y Módulos de la Aplicación

* 🗓️ **Motor de Calendario Híbrido**: No usamos componentes genéricos de UI engañosos. Un modelo nativo cruza la matemática de fechas en tu huso horario local y la codifica inmediatamente al estándar estricto esperado por PostgreSQL (`yyyy-MM-dd`), imprimiendo solo en tarjetas SwiftUI los eventos que suceden el día preciso que seleccionas.
* 🚦 **Sistema Seguro de Interacción AFI**: El catálogo muestra todos los eventos AFI generados por directivos. Tu puedes "Inscribirte" y "Marcar Acabado (⭐)" cualquier evento y el contador gamificado sabrá qué límite llevas por semestre o en global. 
* 🛠️ **Utilería Persistente de Estudiante**: Módulos locales inyectados de Alarmas personales (usando `WheelDatePickers` blindados contra el mismatch horario con en_US_POSIX) y tableros interactivos de Notas Rápidas asignadas por colores de urgencia.
* 🛡️ **Políticas Centralizados RLS (Aislamientos de Seguridad en BD)**: Jamás verás las notas rápidas o alarmas de tus compañeros, porque tu firma `User_ID` de tu Token Apple-Supabase se interpone entre la inyección a Postgres, asegurando blindaje.
* 📱 **Arquitectura Aislada UI/Lógica**: La base del código tiene independencia matemática y lógica del renderizado de tu pantalla. Lo cual posibilita correr el 100% de la lógica pesada sin simulador y sin Mac a la velocidad de la luz en servidores CI/CD.

---

## 🛠 Arquitectura Tecnológica Estricta (MVVM)

La app fue diseñada y testeada con separación implacable de contextos **Model-View-ViewModel** para favorecer el mantenimiento. Toda la UI es reactiva mediante el poderoso framework observador de entorno de Apple `Combine`.

### Estructura de Directorios Resultante
```text
MiCU/
├── Models/         # Structs Codable espejos 1:1 de Supabase (Evento, Alarma, etc).
├── ViewModels/     # Directores y Filtros lógicos (@MainActor). Sin tocar nada gráfico.
├── Views/          
│   ├── Auth/       # Splash Animado, Onboarding de Bienvenida.
│   ├── Main/       # Home interactivo, integrando un calendario dinámico reactivo a toques.
│   ├── AFI/        # Detalle extenso, Formularios de Alta, Scrollables.
│   ├── Personal/   # Listas de alarmas y bloques rápidos + Modales de Inyección (`.sheets`).
│   └── Settings/   # Controles que guardan tus modos Oscuros/Claros y lenguajes en BD.
├── Services/       # Singleton general, Auth Supabase.
├── Tests/          # Conjunto agresivo de simulaciones unitarias puras "Swift Testing".
└── Resources/      # Reglas mnemotécnicas de color para cada materia AFI.
```

---

## 🧪 Ingeniería de Pruebas y Certificación de Calidad

> **8 Pruebas Parametrizadas Asíncronas Certificadas.**

¿Cómo validamos que tu Alarma no explote tu cuenta de Postgres si seleccionas horarios complicados? No lo probamos dándole click con el dedo... lo inyectamos al núcleo en milisegundos mediante el modernísimo **Swift Testing**.

En este repositorio incluimos un entorno "Headless Test Environment". Nuestra lógica está blindada de tal forma que podemos aislar la matemática de Apple o SwiftUI inyectando Mocks de bases de datos, validando simulaciones como:
- Intercambio de formatos de horas (`14:30:00` POSIX vs. String).
- Pruebas iterativas contra eventos inexistentes para validar filtros de calendarios o categorías "Deportivas".
- Formato de errores correctivos sobre "Aforo Textual" de organizadores antes de golpear el servidor.

---

## 💻 Guía de Activación (Xcode y Tu Aplicación)

Gracias a las barreras lógicas creadas con etiquetas condicionales **`#if canImport(SwiftUI)`** y la separación rigurosa de dependencias en `SPM (Swift Package Manager)`, el proyecto está libre de basura y listo para conectar con tu Xcode sin dañar un solo Target ni arrojarte conflictos raros de metadatos Linux o `.git`:

1.  **Abre "iOSLab_Proyecto_EQ.xcodeproj"**: Tan rápido clonas el Repo de GitHub y lo extraes en tu Mac, ejecuta el archivo padre.
2.  **SDK Autónomo**: Gracias a que limpiamos el repo con un `gitignore` estricto en el paquete independiente de desarrollo, verás que tu Xcode descargará instantáneamente e íntegramente la versión pulida oficial de tu *Supabase SDK*. 
3.  **Configura el Arte Gráfico**: En `Assets.xcassets`, arrastra el logo original universitario `UANL-Logo.png`.
4.  ¡**Rueda el Simulador**! Todos los imports se detectarán como `True` de cara a SwiftUI local activando el gigantesco mundo visual que creamos y lo unirá con un cable transparente a la base lógica de los `.swift` que jamás chocarán en entorno ni compilarán en desorden.

---

## 🗄 Modelo Criptográfico Relacional (Supabase postgres)

El núcleo de PostgreSQL sostiene siete tablas pivotes y tres Tipos *ENUM Custom* interconectadas con RLS. 

1. **`Usuarios` / `Alumnos` / `Organizadores`**: El rol global maneja tus metadatos universales (Preferencias visuales y tu matrícula real institucional). Los sub-modelos delimitan el permiso. Un Alumno nunca podrá escribir encima del Catálogo de Operaciones.
2. **`Eventos` (Catálogo Maestro)**: La tabla pública (pero blindada) de las actividades AFIs. Es flexible al contar con la estructura especializada `jsonb` modelada en el frontend bajo tipos abstractos `AnyCodable()`.
3. **`Inscripciones` (El Punto Clave)**: La tabla transitiva *N..to..N*. Alberga el crucial UUID y la bandera bit asíncrona de si una materia particular AFI está palomeada como `finalizada` a favor del progreso en semestres universitarios.
4. **`Alarmas` / `Recordatorios_Personales`**: Bases asiladas vinculadas por Llaves foráneas (`usuario_id`). La UI transforma toda información de manera precisa mediante DataFormatters antes de mandar en JSON a estos alojamientos para que el parseo sea idéntico 1:1 a un `TIME/DATE` y a sus Tipos `ENUM` (Prioridad `Básico, Urgente`, etc).

---

🔥 **¡MI.CU está compilado y listo para optimizar los horarios universitarios!**
