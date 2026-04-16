import Foundation
import Supabase

@MainActor
class HerramientasViewModel: ObservableObject {
    @Published var notas: [RecordatorioPersonal] = []
    @Published var alarmas: [Alarma] = []
    @Published var isLoading = false
    
    // UUID / Matrícula desde el Auth global para evitar que vea los de otros alumnos
    var matriculaAlumno: Double? = nil 
    
    func fetchHerramientas() async {
        guard let matricula = matriculaAlumno else { return }
        isLoading = true
        
        do {
            // Nota: Podríamos usar un TaskGroup para bajar al mismo tiempo,
            // pero para simplificar hacemos awaits secuenciales muy eficientes
            let misNotas: [RecordatorioPersonal] = try await supabase
                .from("Recordatorios_Personales")
                .select()
                .eq("usuario_id", value: matricula)
                .order("created_at", ascending: false) // Las nuevas arriba
                .execute()
                .value
            
            let misAlarmas: [Alarma] = try await supabase
                .from("Alarmas")
                .select()
                .eq("usuario_id", value: matricula)
                .execute()
                .value
            
            self.notas = misNotas
            self.alarmas = misAlarmas
            
        } catch {
            print("Error bajando herramientas personales: \(error)")
        }
        isLoading = false
    }
    
    /// Inserta una nueva nota directamente pasando por el cumplimiento de RLS.
    func crearNotaRapida(titulo: String, descripcion: String, prioridad: PriorityLevel) async {
        guard let matricula = matriculaAlumno else { return }
        
        // Documento Temporal Codable
        struct NuevaNota: Codable {
            let usuario_id: Double
            let titulo: String
            let nota: String
            let prioridad: PriorityLevel
        }
        
        let doc = NuevaNota(usuario_id: matricula, titulo: titulo, nota: descripcion, prioridad: prioridad)
        
        do {
            try await supabase.from("Recordatorios_Personales").insert(doc).execute()
            await fetchHerramientas() // Refresca lista silenciosamente despues de crear
        } catch {
            print("No se pudo agregar nota: \(error)")
        }
    }
}
