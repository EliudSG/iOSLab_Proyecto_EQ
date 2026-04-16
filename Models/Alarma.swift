import Foundation

struct Alarma: Codable, Identifiable {
    let id: UUID
    let usuarioId: Double?
    let titulo: String?
    let hora: String
    let fecha: String?
    let activa: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id
        case usuarioId = "usuario_id"
        case titulo
        case hora
        case fecha
        case activa
    }
}
