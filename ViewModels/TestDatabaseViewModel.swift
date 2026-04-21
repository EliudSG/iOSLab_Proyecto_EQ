import Foundation
#if canImport(Combine)
import Combine
#endif
@MainActor
class TestDatabaseViewModel: ObservableObject {
    @Published var eventos: [Evento] = []
    @Published var errorMessage: String? = nil
    @Published var isLoading: Bool = false
    
    init() {}
    
    /// Esta función intentará conectarse a Supabase y descargar todos los eventos al modelo Swift
    func fetchEventos() async {
        isLoading = true
        errorMessage = nil
        do {
            print("🚀 Iniciando petición a la tabla 'Eventos' en Supabase...")
            
            // Hacemos un SELECT a la tabla Eventos usando el cliente global de `SupabaseClient.swift`
            let response: [Evento] = try await supabase
                .from("Eventos")
                .select()
                .execute()
                .value
            
            self.eventos = response
            print("✅ ¡Éxito! Se descargaron \(response.count) eventos.")
        } catch {
            print("❌ Error de Conexión: \(error)")
            self.errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
