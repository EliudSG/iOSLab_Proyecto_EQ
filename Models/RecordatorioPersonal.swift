import Foundation

struct RecordatorioPersonal: Codable, Identifiable {
    let id: UUID
    let usuarioId: Double?
    let titulo: String
    let nota: String?
    let prioridad: PriorityLevel?
    let fechaRecordatorio: String?
    let horaRecordatorio: String?
    let createdAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case usuarioId = "usuario_id"
        case titulo
        case nota
        case prioridad
        case fechaRecordatorio = "fecha_recordatorio"
        case horaRecordatorio = "hora_recordatorio"
        case createdAt = "created_at"
    }
}

enum PriorityLevel: String, Codable {
    case basico = "Básico"
    case importante = "Importante"
    case urgente = "Urgente"
}
