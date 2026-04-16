import Foundation

struct Inscripcion: Codable, Identifiable {
    let id: UUID
    let eventoId: Int
    let alumnoId: Double
    let signedUpAt: String?
    let finalizada: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id
        case eventoId = "evento_id"
        case alumnoId = "alumno_id"
        case signedUpAt = "signed_up_at"
        case finalizada
    }
}
