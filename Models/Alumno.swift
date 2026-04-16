import Foundation

struct Alumno: Codable, Identifiable {
    var id: Double { matricula }
    
    let matricula: Double
    let semester: Int?
    let createdAt: String?
    
    enum CodingKeys: String, CodingKey {
        case matricula
        case semester
        case createdAt = "created_at"
    }
}
