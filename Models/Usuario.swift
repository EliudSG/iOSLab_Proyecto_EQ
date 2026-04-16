import Foundation

struct Usuario: Codable, Identifiable {
    var id: Double { matricula } // Identificable para poder iterarlo en Listas de SwiftUI
    
    let matricula: Double
    let nombre: String
    let facultad: String?
    let tipoUsuario: String?
    let fechaRegistro: String?
    let email: String?
    let role: UserRole
    let tema: String?
    let idioma: String?
    let notificacionesActivas: Bool?
    let createdAt: String?
    
    enum CodingKeys: String, CodingKey {
        case matricula
        case nombre
        case facultad
        case tipoUsuario = "tipo_Usuario"
        case fechaRegistro = "fecha_Registro"
        case email
        case role
        case tema
        case idioma
        case notificacionesActivas = "notificaciones_activas"
        case createdAt = "created_at"
    }
}

enum UserRole: String, Codable {
    case student = "student"
    case organizer = "organizer"
    case admin = "admin"
}
