import Foundation

struct Evento: Codable, Identifiable {
    let id: Int
    let fechaEvento: String?
    let nombreEvento: String?
    let lugar: String?
    let aforo: Double?
    let departamentoSolicitante: String?
    let horaInicio: String?
    let horaFin: String?
    let telefonoResponsable: String?
    let insumos: [String: AnyCodable]? // JSONB dinámico map
    let organizadorId: Double?
    let categoria: CategoriaAFI?
    let imageUrl: String?
    let estado: String?
    let descripcion: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case fechaEvento = "fecha_evento"
        case nombreEvento = "nombre_Evento"
        case lugar
        case aforo
        case departamentoSolicitante = "departamento_Solicitante"
        case horaInicio = "hora_Inicio"
        case horaFin = "hora_Fin"
        case telefonoResponsable = "telefono_Responsable"
        case insumos
        case organizadorId = "organizador_id"
        case categoria
        case imageUrl = "image_url"
        case estado
        case descripcion
    }
}

enum CategoriaAFI: String, Codable, CaseIterable, Sendable {
    case investigacion = "Investigación"
    case culturales = "Culturales"
    case institucional = "Institucional"
    case academicas = "Académicas"
    case artistica = "Artística"
    case idiomas = "Idiomas"
    case responsabilidadSocial = "Responsabilidad Social"
    case deportivas = "Deportivas"
    case intercambioAcademico = "Intercambio Académico"
    case innovacionYEmprendimiento = "Innovación y Emprendimiento"
}
