# 📅 MI.CU — (UANL)

![Swift](https://img.shields.io/badge/Swift-FA7343?style=for-the-badge&logo=swift&logoColor=white)
![SwiftUI](https://img.shields.io/badge/SwiftUI-000000?style=for-the-badge&logo=swift&logoColor=white)
![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white)
![iOS](https://img.shields.io/badge/iOS-000000?style=for-the-badge&logo=apple&logoColor=white)

MI.CU es una aplicación móvil nativa para iOS diseñada para ayudar a la comunidad de la **Universidad Autónoma de Nuevo León (UANL)** a organizar y gestionar sus **Actividades Formativas Integrales (AFI)**.

Este proyecto fue desarrollado en equipo para la materia *iOSLab*.

---

## 🚀 Características Principales

* **Gestión de AFI**: Explora, inscríbete y haz un seguimiento de tus actividades formativas integrales.
* **Calendario Integrado**: Visualiza fácil y rápidamente todos tus eventos universitarios mes a mes y día por día.
* **Herramientas Personales**: Añade recordatorios en notas de distintos colores (según su prioridad) y configura alarmas para mantenerte al día con tus labores académicas.
* **Progreso Semestral**: Sigue el estado de tus AFIs con contadores interactivos para asegurarte de cumplir tus requisitos.
* **Diseño Nativo y Accesible**: Desarrollado 100% en SwiftUI utilizando lineamientos modernos; cuenta con opciones de Modo Claro / Oscuro, así como soporte bilingüe (Español / Inglés).

---

## 🛠 Arquitectura Tecnológica

El proyecto se apega al patrón arquitectónico **MVVM (Model-View-ViewModel)**. 

### Stack
* **Frontend**: App nativa iOS creada con **Swift** y **SwiftUI**.
* **Backend**: **Supabase** (Postgres DB, API, Autenticación) consumido directamente en el cliente mediante concurrencia moderna de iOS usando `async/await`.
* **Flujo de Datos**: Propiedades `@Published` dentro de los *ViewModels* que exponen la lógica de negocio a las vistas, reaccionando fluidamente a cualquier cambio de estado.

### Estructura del Proyecto
```text
MiCU/
├── Models/         # Structs (Codable) que mapean 1:1 con las tablas en Supabase
├── ViewModels/     # Lógica de negocio y manejo de datos asincrónicos
├── Views/          # Vistas de la aplicación (Auth, Main, AFI, Personal, Settings)
├── Services/       # Funcionalidad core como Singleton de Supabase, Auth Service
└── Resources/      # Media, Colores de dominio AFI y Localización de strings
```

---

## 💻 Guía de Instalación y Compilación (Xcode)

Para compilar y correr el celular interactivo en tu Mac o Simulador en lugar de leer el código plano, sigue estas instrucciones para montar el proyecto (ya que el archivo crudo `.xcodeproj` no se versiona por conflictos de compilación):

1. **Obtén tus archivos**: Clona o descarga todo este repositorio.
2. **Crea el Proyecto Vacío**: Abre **Xcode** y haz clic en **"Create a new Xcode project"**. Selecciona la pestaña **iOS > App**. Nómbralo `MiCU` y asegúrate de elegir tipo **SwiftUI** y lenguaje **Swift**. Guárdalo provisionalmente en tu Escritorio.
3. **Limpia y Remplaza**: Ve al nuevo proyecto en Finder o Xcode y elimina los archivos por defecto que generó Apple (`ContentView.swift` y `MiCUApp.swift`). Con cuidado, selecciona las carpetas de este repositorio que clonaste (`Models/`, `ViewModels/`, `Views/`, `Services/`, `Resources/` y tu archivo especial `MiCUApp.swift`) y arrástralas al árbol izquierdo en tu proyecto de Xcode (marcando en el checkbox **"Copy items if needed"**).
4. **Agrega la Gráfica**: Arrastra el archivo de imagen original de la universidad `UANL-Logo.png` que proporcionamos a la carpeta `Assets.xcassets`.
5. **Configura el Backend de Supabase**: Como el proyecto usa Supabase de forma nativa:
   * En tu barra principal superior de Xcode, ve a **File > Add Package Dependencies...**
   * En el buscador pega este enlace oficial: `https://github.com/supabase/supabase-swift`
   * Instálalo para el target `MiCU`.
6. ¡Listo! Presiona **Play** `(Cmd + R)` o el ícono triangular para compilar el Simulador de iOS.

---

## 🗄 Modelo y Tablas de Base de Datos (Supabase / Postgres)

Nuestra base de datos relacional y escalable en Supabase funciona bajo políticas estrictas de seguridad de filas (**RLS**). La información personal como *Recordatorios* o *Alarmas* es de acceso estrictamente privado por usuario autenticado gracias al uso del JWT interno de sesión, previniendo fuga de datos de los alumnos. Los eventos, en contraste, son de sólo lectura de forma pública.

### Las 7 Tablas Pivotes del Sistema
1. **`Usuarios`**: Tabla de control global. Contiene el rol del usuario (Ej. *Student, Organizer*). Su llave principal (`matricula`) se correlaciona con la de Autenticación de Supabase de manera programática.
2. **`Alumnos` / `Organizadores`**: Tablas filiales vinculadas a `Usuarios` para delimitar particularidades especiales según el uso de la sesión (Ej. el departamento o grado de la persona).
3. **`Eventos`**: El catálogo central de AFIs listadas por los organizadores y consumidas por nuestro Switch de UI bajo *Eventos Publicados*. Existe una columna `insumos` adaptada a ser **dinámica (jsonb)** que la app descifra sin crashear gracias a tecnología `AnyCodable` que configuramos en **Modelos**.
4. **`Inscripciones`**: Es la estructura transmedia que rompe de manera segura la relación "Muchos a Muchos" entre estudiantes y exposiciones. Contiene el valioso bit `finalizada` que es manipulado mediante Updates remotos dentro de la app para pintar de color Verde la tarjeta AFI en el *HomeView*.
5. **`Recordatorios_Personales` / `Alarmas`**: Son los arreglos en donde `HerramientasView` incrusta notas cifradas.

### Catálogo del Dominio AFI (GAMIFICACIÓN)
Para unificación gráfica que evite equivocaciones tipográficas del editor en la base de datos, las AFIs oficiales tienen un *ENUM Constrained User-Defined Typo* estricto y un código de color emparejado en el repositorio UI (`Colors.swift`):
* Investigación
* Culturales
* Institucional
* Académicas
* Artística
* Idiomas
* Responsabilidad Social
* Deportivas
* Intercambio Académico
* Innovación y Emprendimiento

---

## 📲 Módulos de la Aplicación

1. **Autenticación y Perfil**: Validado para correos institucionales de la facultad, pasando por un agradable *onboarding*.
2. **Pantalla Principal (Home)**: Navegación de calendario en la cual podrás previsualizar y consultar horas exactas y sede de los eventos próximos.
3. **Módulo AFI y Listados**: Ve todos los eventos en catálogo, inscríbete y marca tu estatus como *finalizada* marcándolas con una estrella ⭐ en los detalles del evento. 
4. **Utilidades del Alumno**: Utiliza tus tiempos muertos para tomar recados importantes y ajustar tus tiempos de estudio.
5. **Configuración General**: Cambios de temas visuales, ajustes de notificaciones, tablero interactivo de preguntas y contactos de tu facultad.
