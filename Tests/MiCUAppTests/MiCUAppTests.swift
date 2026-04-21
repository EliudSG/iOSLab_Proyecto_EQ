import Testing
import Foundation
@testable import MiCUApp

@Suite("Pruebas de Lógica de Negocio (ViewModels)")
struct MiCUAppTests {

    @Test("Validar decodificación Categoría AFI")
    func testCategoriaAFI() throws {
        let json = """
        {"id": 1, "categoria": "Culturales"}
        """.data(using: .utf8)!
        
        // Asumiendo que el Decodificador funciona correctamente con CodingKeys
        let decoder = JSONDecoder()
        let evento = try decoder.decode(Evento.self, from: json)
        #expect(evento.categoria == .culturales)
    }
    
    @Test("Contador de AFI completadas funciona correctamente")
    @MainActor
    func testConteoAFI() async throws {
        let viewModel = AFIListViewModel()
        
        let inscripcionFalsa1 = Inscripcion(id: UUID(), eventoId: 1, alumnoId: 123456, signedUpAt: "2026-04-20", finalizada: true)
        let inscripcionFalsa2 = Inscripcion(id: UUID(), eventoId: 2, alumnoId: 123456, signedUpAt: "2026-04-21", finalizada: false)
        let inscripcionFalsa3 = Inscripcion(id: UUID(), eventoId: 3, alumnoId: 123456, signedUpAt: "2026-04-21", finalizada: true)
        
        viewModel.misInscripciones = [inscripcionFalsa1, inscripcionFalsa2, inscripcionFalsa3]
        
        let terminadas = viewModel.totalAfiCompletadasMismoSemestre
        #expect(terminadas == 2, "El modelo debe contar exactamente 2 eventos finalizados.")
    }
    
    @Test("Verificación local if isEventoInscrito")
    @MainActor
    func testIsEventoInscrito() async throws {
        let viewModel = AFIListViewModel()
        
        let inscripcionFalsa = Inscripcion(id: UUID(), eventoId: 99, alumnoId: 123456, signedUpAt: "2026-04-20", finalizada: false)
        viewModel.misInscripciones = [inscripcionFalsa]
        
        #expect(viewModel.isEventoInscrito(eventoId: 99) == true)
        #expect(viewModel.isEventoInscrito(eventoId: 100) == false)
    }
    
    @Test("Filtro Cartelera por Categoría")
    @MainActor
    func testFiltroCartelera() async throws {
        let viewModel = AFIListViewModel()
        let evento1 = Evento(id: 1, fechaEvento: nil, nombreEvento: "Partido de Tigres", lugar: nil, aforo: nil, departamentoSolicitante: nil, horaInicio: nil, horaFin: nil, telefonoResponsable: nil, insumos: nil, organizadorId: nil, categoria: .deportivas, imageUrl: nil, estado: "publicado", descripcion: nil)
        
        let evento2 = Evento(id: 2, fechaEvento: nil, nombreEvento: "Concierto Orquesta", lugar: nil, aforo: nil, departamentoSolicitante: nil, horaInicio: nil, horaFin: nil, telefonoResponsable: nil, insumos: nil, organizadorId: nil, categoria: .culturales, imageUrl: nil, estado: "publicado", descripcion: nil)
        
        viewModel.todosLosEventos = [evento1, evento2]
        
        // 1. Sin filtro, debe devolver todos
        viewModel.categoriaActiva = nil
        #expect(viewModel.carteleraFiltrada.count == 2)
        
        // 2. Filtro deportivas solo debe devolver Tigres
        viewModel.categoriaActiva = .deportivas
        #expect(viewModel.carteleraFiltrada.count == 1)
        #expect(viewModel.carteleraFiltrada.first?.categoria == .deportivas)
    }
    
    @Test("Validación Organizador: Alerta si formato de Aforo falla", arguments: [
        ("Cien", false), // Debe fallar por no ser un número (String alfanumérico)
        ("150", true)    // Debe ser exitoso
    ])
    @MainActor
    func testCrearEventoAforo(aforoString: String, simulacionExitosa: Bool) async throws {
        let vm = EventoViewModel()
        vm.nombreEvento = "Muestra Universitaria Experimental"
        vm.lugar = "Explanada Explanada"
        vm.aforoTexto = aforoString
        
        await vm.crearEvento(matriculaOrganizador: 999999)
        
        if simulacionExitosa {
            #expect(vm.errorMessage == nil, "No debe fallar la validación si el aforo es \(aforoString)")
            #expect(vm.isSuccess == true, "La red simulada debió haber respondido OK")
            #expect(vm.nombreEvento.isEmpty, "El formulario debe autolimpiarse después de un éxito")
        } else {
            #expect(vm.errorMessage != nil, "Debe alertar que el aforo debe ser numérico")
            #expect(vm.isSuccess == false)
            #expect(!vm.nombreEvento.isEmpty, "El formulario NO debe limpiarse si falló, para que el usuario corrija el error textualmente")
        }
    }
    
    @Test("Validación Base de Motor de Calendario (Filtro por Fechas)", arguments: [
        ("2026-04-20", 2),
        ("2026-04-24", 1),
        ("2026-10-31", 0)
    ])
    @MainActor
    func testFiltroPorFechaDeCalendario(fechaMockString: String, conteoEsperado: Int) async throws {
        let calendario = CalendarioViewModel()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        // Simulación: El alumno presionó el botón de "fechaMockString"
        let diaTocado = try #require(formatter.date(from: fechaMockString), "El DateFormatter no logró parsear bajo el estándar ISO.")
        
        // Mock de Supabase para este contexto (Tres fechas en la semana)
        let evt1 = Evento(id: 1, fechaEvento: "2026-04-20", nombreEvento: "ExpoArquitectura", lugar: nil, aforo: nil, departamentoSolicitante: nil, horaInicio: nil, horaFin: nil, telefonoResponsable: nil, insumos: nil, organizadorId: nil, categoria: nil, imageUrl: nil, estado: nil, descripcion: nil)
        let evt2 = Evento(id: 2, fechaEvento: "2026-04-20", nombreEvento: "Visita Laboratorios", lugar: nil, aforo: nil, departamentoSolicitante: nil, horaInicio: nil, horaFin: nil, telefonoResponsable: nil, insumos: nil, organizadorId: nil, categoria: nil, imageUrl: nil, estado: nil, descripcion: nil)
        let evt3 = Evento(id: 3, fechaEvento: "2026-04-24", nombreEvento: "Torneo Intramuros", lugar: nil, aforo: nil, departamentoSolicitante: nil, horaInicio: nil, horaFin: nil, telefonoResponsable: nil, insumos: nil, organizadorId: nil, categoria: nil, imageUrl: nil, estado: nil, descripcion: nil)
        
        let baseDeDatosFalsa = [evt1, evt2, evt3]
        
        let resultados = calendario.eventosParaElDia(todosLosEventos: baseDeDatosFalsa, date: diaTocado)
        
        #expect(resultados.count == conteoEsperado, "El filtro interno cruzando Strings de la API y Dates de UI debe coincidir para desplegar en el Home.")
    }
    
    @Test("Validación Conversión Matemática de Horas de Alarma para Supabase", arguments: [
        ("14:30", "14:30:00"),
        ("08:15", "08:15:00"),
        ("23:59", "23:59:00"),
        ("00:00", "00:00:00")
    ])
    @MainActor
    func testAlarmaTimeConverter(horaEntrada: String, conversionEsperada: String) async throws {
        let herramV = HerramientasViewModel()
        
        let inputFormatter = DateFormatter()
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        inputFormatter.dateFormat = "HH:mm"
        
        // Simulación: Apple Date Picker entrega un Objeto Date() genérico
        let appleDate = try #require(inputFormatter.date(from: horaEntrada), "Fallo la inyección nativa del Input")
        
        let stringDeSalida = herramV.procesarHoraParaDB(horaNative: appleDate)
        
        #expect(stringDeSalida == conversionEsperada, "La conversión a formato hora de PostgreSQL de \(horaEntrada) debe coincidir estrictamente a los segundos.")
    }
    
    @Test("Diccionario Base de Datos para Preferencias de Tema e Idioma", arguments: [
        (true, "English", "oscuro", "ingles"),
        (false, "Español", "claro", "español"),
        (true, "Español", "oscuro", "español")
    ])
    @MainActor
    func testConversionesConfiguracionDB(mockIsDark: Bool, mockLang: String, temaEsperado: String, langEsperado: String) async throws {
        let configVM = ConfiguracionViewModel()
        
        // El usuario manipula en pantalla (SwiftUI Picker/Toggle):
        configVM.isDarkTheme = mockIsDark
        configVM.selectedLanguage = mockLang
        
        // Emulamos el empaquetado para el UPDATE .execute() de Postgres
        let stringTemaPosgres = configVM.mapaTemaDB()
        let stringIdiomaPosgres = configVM.mapaIdiomaDB()
        
        #expect(stringTemaPosgres == temaEsperado, "Alguien en \(!mockIsDark ? "Blanco" : "Oscuro") rompió la codificación esperada (\(temaEsperado)) de DB.")
        #expect(stringIdiomaPosgres == langEsperado, "Alguien en \(mockLang) causó una rotura en el guardado de strings (\(langEsperado)).")
    }
}
