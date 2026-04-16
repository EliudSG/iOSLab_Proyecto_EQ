import SwiftUI

struct EventoRowCard: View {
    let evento: Evento
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                // Etiqueta (Badge) con Color Oficial AFI
                Text(evento.categoria?.rawValue ?? "Sin Categoría")
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(colorForCategoria(evento.categoria).opacity(0.15))
                    .foregroundColor(colorForCategoria(evento.categoria))
                    .cornerRadius(8)
                
                Spacer()
                
                Text(evento.lugar ?? "Sede no especificada")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Text(evento.nombreEvento ?? "Actividad Universitaria UANL")
                .font(.headline)
                .fontWeight(.bold)
                .lineLimit(2)
            
            HStack {
                Label(formatoHora(evento.horaInicio), systemImage: "clock")
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
                if let aforo = evento.aforo {
                    Text("Aforo: \(Int(aforo))")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    // Mapeo seguro a los colores establecidos de tu manual
    func colorForCategoria(_ cat: CategoriaAFI?) -> Color {
        guard let categoria = cat else { return .miCuPrimary }
        switch categoria {
        case .culturales: return .afiCulturales
        case .deportivas: return .afiDeportivas
        case .academicas: return .afiAcademicas
        case .responsabilidadSocial: return .afiResponsabilidadSocial
        case .innovacionYEmprendimiento: return .afiInnovacion
        case .investigacion: return .afiInvestigacion
        case .idiomas: return .afiIdiomas
        case .artistica: return .afiArtistica
        case .intercambioAcademico: return .afiIntercambio
        case .institucional: return .afiInstitucional
        }
    }
    
    // Para no mostrar Hora vacía
    func formatoHora(_ h: String?) -> String {
        return h ?? "--:--"
    }
}
