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

## 🗄 Modelo de Datos y Backend

Nuestra base de datos en Supabase funciona bajo políticas estrictas de seguridad de filas (**RLS**). Información personal como *Recordatorios* o *Alarmas* es de acceso completamente privado por usuario (usando su JWT de sesión), mientras que los eventos generales de la UANL son de sólo lectura de forma pública.

### Catálogo de Categorías AFI
El proyecto toma en consideración la oficialidad e identifica cada rama con una paleta visual integrada en UI:
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
