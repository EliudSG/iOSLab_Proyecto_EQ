import Foundation
import Supabase
#if canImport(Combine)
import Combine
#endif
@MainActor
class AFIListViewModel: ObservableObject {
    // Arrays que mantienen el estado de los datos bajados de la BD
    @Published var todosLosEventos: [Evento] = []
    @Published var misInscripciones: [Inscripcion] = []
    
    // Variables de estado visual
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    // Filtro para los Tabs por Categoría en la interfaz AFI
    @Published var categoriaActiva: CategoriaAFI? = nil
    
    init() {}
    
    // MARK: - API de Cartelera General (Lectura Pública)
    
    /// Descarga absolutamente toda la cartelera de eventos disponibles que estén "publicados".
    func fetchCarteleraEventos() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response: [Evento] = try await supabase
                .from("Eventos")
                .select()
                .eq("estado", value: "publicado") // Filtro de Backend: Solo mostrar publicados
                .order("fecha_evento", ascending: true) // Filtro de Backend: Ordenados del más cercano al más lejano
                .execute()
                .value
            
            self.todosLosEventos = response
            
        } catch {
            print("Error bajando cartelera: \(error)")
            self.errorMessage = "No pudimos cargar la cartelera de AFIs. Revisa tu internet."
        }
        
        isLoading = false
    }
    
    // MARK: - Filtros Computados Localmente (Ahorra peticiones al backend)
    
    /// Filtra y muestra la cartelera a partir de la Categoría seleccionada (ej. si el usuario presiona el botón naranja "Culturales")
    var carteleraFiltrada: [Evento] {
        guard let categoria = categoriaActiva else {
            // Si es nil, devolvemos todo sin filtro
            return todosLosEventos 
        }
        return todosLosEventos.filter { $0.categoria == categoria }
    }
    
    // MARK: - Lógica de Alumno Privada (Mis Inscripciones)
    
    /// Descarga el puente relacional de a qué eventos me he registrado (Módulo 'Mis Eventos')
    func fetchMisActividades(matricula: Double) async {
        do {
            let misInscritas: [Inscripcion] = try await supabase
                .from("Inscripciones")
                .select()
                .eq("alumno_id", value: matricula)
                .execute()
                .value
            
            self.misInscripciones = misInscritas
        } catch {
            print("No pudimos bajar tus actividades inscritas: \(error.localizedDescription)")
        }
    }
    
    /// Motor: Acción para que el estudiante dé click en "Inscribirme"
    func inscribirmeAEvento(eventoId: Int, matricula: Double) async {
        // Estructura anónima temporal para el Insert SQL
        struct NuevaInscripcion: Codable {
            let evento_id: Int
            let alumno_id: Double
            let finalizada: Bool
        }
        
        errorMessage = nil
        do {
            let doc = NuevaInscripcion(evento_id: eventoId, alumno_id: matricula, finalizada: false)
            
            try await supabase
                .from("Inscripciones")
                .insert(doc)
                .execute()
            
            // Volvemos a bajar sus actividades para que el UI se refresque inmediatamente
            await fetchMisActividades(matricula: matricula)
        } catch {
            self.errorMessage = "Ups, falló la inscripción. Intenta de nuevo más tarde."
        }
    }
    
    /// Motor: Lógica Crítica - Finalizar AFI (El alumno presiona la ⭐ cuando termina la AFI)
    func marcarAFIFinalizada(inscripcionId: UUID, _ status: Bool = true) async {
        struct UpdateDoc: Codable {
            let finalizada: Bool
        }
        
        do {
            try await supabase
                .from("Inscripciones")
                .update(UpdateDoc(finalizada: status))
                .eq("id", value: inscripcionId)
                .execute()
            
            // Actualización Local Optimista, para que la estrellita brille al instante sin esperar a recargar todo
            if let index = misInscripciones.firstIndex(where: { $0.id == inscripcionId }) {
                // Muta el elemento localmente reconstruyéndolo
                let vieja = misInscripciones[index]
                self.misInscripciones[index] = Inscripcion(
                    id: vieja.id, 
                    eventoId: vieja.eventoId, 
                    alumnoId: vieja.alumnoId, 
                    signedUpAt: vieja.signedUpAt, 
                    finalizada: status
                )
            }
        } catch {
            self.errorMessage = "No pudimos guardar tus avances."
        }
    }
    
    // MARK: - Contadores Oficiales Semestrales
    
    /// Revisa si un evento en la pantalla principal ya está inscrito por el usuario (Para pintarle UI gris)
    func isEventoInscrito(eventoId: Int) -> Bool {
        return misInscripciones.contains(where: { $0.eventoId == eventoId })
    }
    
    /// Contador crítico de la meta 14 semestral
    var totalAfiCompletadasMismoSemestre: Int {
        // En una app real, acá validarías las fechas para asegurarte de que están en los últimos 6 meses.
        // Por ahora contaremos todas las finalizadas que tiene en su vida escolar.
        return misInscripciones.filter { $0.finalizada == true }.count
    }
}
