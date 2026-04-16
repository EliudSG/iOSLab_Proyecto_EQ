import SwiftUI

// Extension para inicializar con Hex Code de colores exactos AFI
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// Colores de la UANL y Categorías AFI implementados globales
extension Color {
    static let miCuPrimary             = Color(hex: "#4A9B8E") // Verde teal (Acento Principal)
    static let afiCulturales           = Color(hex: "#E8934A") // Naranja
    static let afiDeportivas           = Color(hex: "#5B9BD5") // Azul medio
    static let afiAcademicas           = Color(hex: "#E05C5C") // Rojo/rosa
    static let afiResponsabilidadSocial = Color(hex: "#8E7CC3") // Morado
    static let afiInnovacion           = Color(hex: "#4A90D9") // Azul oscuro
    static let afiInvestigacion        = Color(hex: "#5BA85B") // Verde
    static let afiIdiomas              = Color(hex: "#D4A017") // Amarillo dorado
    static let afiArtistica            = Color(hex: "#C06090") // Rosa fuerte
    static let afiIntercambio          = Color(hex: "#3ABFBF") // Teal
    static let afiInstitucional        = Color(hex: "#7B7B7B") // Gris
}
