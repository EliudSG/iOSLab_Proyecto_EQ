import Foundation
#if canImport(Combine)
import Combine
#endif

@MainActor
class ConfiguracionViewModel: ObservableObject {
    @Published var isDarkTheme: Bool = false
    @Published var selectedLanguage: String = "Español"
    @Published var notificationsEnabled: Bool = true
    
    // Convertidores aislados para el formato estricto de Supabase
    // Evita errores tipográficos al pasar de UI Toggle a Postgres String
    func mapaTemaDB() -> String {
        return isDarkTheme ? "oscuro" : "claro"
    }
    
    func mapaIdiomaDB() -> String {
        // Normalización exacta pedida
        return selectedLanguage == "English" ? "ingles" : "español"
    }
    
    // Stub de conexión remota para cuando se integre `var supabase` real en Auth.
    func guardarPreferencias(matricula: Double) async throws {
        // Aquí conectaremos la SDK de Supabase:
        // try await supabase.from("Usuarios").update(["tema": mapaTemaDB(), "idioma": mapaIdiomaDB(), "notificaciones_activas": notificationsEnabled]).eq("matricula", matricula).execute()
    }
}
