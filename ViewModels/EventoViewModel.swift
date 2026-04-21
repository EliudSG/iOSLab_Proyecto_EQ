import Foundation
#if canImport(Supabase)
import Supabase
#endif
#if canImport(Combine)
import Combine
#endif

/// Estructura separada del Modelo Base ya que al crear (INSERT), omitimos el ID (Auto-inrementable) de PostgreSQL
struct CreateEventoRequest: Codable, Sendable {
    let nombreEvento: String
    let categoria: CategoriaAFI
    let fechaEvento: String
    let horaInicio: String
    let horaFin: String
    let lugar: String
    let aforo: Double
    let descripcion: String
    let imageUrl: String?
    let telefonoResponsable: String
    let departamentoSolicitante: String
    let organizadorId: Double
    let estado: String
    
    enum CodingKeys: String, CodingKey {
        case nombreEvento = "nombre_Evento"
        case categoria
        case fechaEvento = "fecha_evento"
        case horaInicio = "hora_Inicio"
        case horaFin = "hora_Fin"
        case lugar
        case aforo
        case descripcion
        case imageUrl = "image_url"
        case telefonoResponsable = "telefono_Responsable"
        case departamentoSolicitante = "departamento_Solicitante"
        case organizadorId = "organizador_id"
        case estado
    }
}

@MainActor
class EventoViewModel: ObservableObject {
    @Published var nombreEvento: String = ""
    @Published var categoria: CategoriaAFI = .culturales
    @Published var fechaEvento: Date = Date()
    @Published var horaInicio: Date = Date()
    @Published var horaFin: Date = Date().addingTimeInterval(3600) // 1 hora de duracion por defecto
    @Published var lugar: String = ""
    @Published var aforoTexto: String = ""
    @Published var descripcion: String = ""
    @Published var telefonoResponsable: String = ""
    @Published var departamentoSolicitante: String = ""
    
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var isSuccess = false
    
    init() {}
    
    // Formateadores privados estrictos para inyectarlos limpiamente en PostgreSQL (DATE, TIME)
    private var posgresDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
    
    private var posgresTimeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }
    
    func crearEvento(matriculaOrganizador: Double) async {
        guard !nombreEvento.trimmingCharacters(in: .whitespaces).isEmpty,
              !lugar.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "El nombre y el lugar son obligatorios."
            return
        }
        
        guard let aforoNum = Double(aforoTexto) else {
            errorMessage = "El aforo debe detallarse numéricamente (ej. 100)."
            return
        }
        
        let stringFecha = posgresDateFormatter.string(from: fechaEvento)
        let stringHoraInicio = posgresTimeFormatter.string(from: horaInicio)
        let stringHoraFin = posgresTimeFormatter.string(from: horaFin)
        
        let nuevoEvento = CreateEventoRequest(
            nombreEvento: nombreEvento.trimmingCharacters(in: .whitespaces),
            categoria: categoria,
            fechaEvento: stringFecha,
            horaInicio: stringHoraInicio,
            horaFin: stringHoraFin,
            lugar: lugar.trimmingCharacters(in: .whitespaces),
            aforo: aforoNum,
            descripcion: descripcion,
            imageUrl: nil, // Expandible a Storage futuro
            telefonoResponsable: telefonoResponsable,
            departamentoSolicitante: departamentoSolicitante,
            organizadorId: matriculaOrganizador,
            estado: "publicado"
        )
        
        isLoading = true
        errorMessage = nil
        isSuccess = false
        
        do {
            _ = try await supabase
                .from("Eventos")
                .insert(nuevoEvento)
                .execute()
                
            isSuccess = true
            resetForm()
        } catch {
            errorMessage = "Ocurrió un error al subir el evento."
        }
        isLoading = false
    }
    
    func resetForm() {
        nombreEvento = ""
        fechaEvento = Date()
        horaInicio = Date()
        horaFin = Date().addingTimeInterval(3600)
        lugar = ""
        aforoTexto = ""
        descripcion = ""
        telefonoResponsable = ""
        departamentoSolicitante = ""
    }
}
