import Foundation

struct Organizador: Codable, Identifiable {
    var id: Double { matricula }
    
    let matricula: Double
    let department: String?
    let createdAt: String?
    
    enum CodingKeys: String, CodingKey {
        case matricula
        case department
        case createdAt = "created_at"
    }
}
