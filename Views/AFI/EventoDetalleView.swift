import SwiftUI

#if canImport(SwiftUI)
struct EventoDetalleView: View {
    let evento: Evento
    
    // Inyectamos el ViewModel de AFI list que opera las inscripciones
    @StateObject private var viewModel = AFIListViewModel()
    @State private var inscripcionEnVuelo = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                // Header Image Container
                Rectangle()
                    .fill(Color.miCuPrimary.opacity(0.15))
                    .frame(height: 220)
                    .overlay(
                        VStack(spacing: 10) {
                            Image(systemName: "photo.artframe")
                                .font(.system(size: 60))
                                .foregroundColor(Color.miCuPrimary.opacity(0.6))
                            Text("Espacio reservado para Logo o Portada")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    )
                
                VStack(alignment: .leading, spacing: 18) {
                    
                    // Titulo y Categoria
                    VStack(alignment: .leading, spacing: 8) {
                        Text(evento.nombreEvento ?? "Actividad UANL")
                            .font(.title)
                            .fontWeight(.bold)
                            .fixedSize(horizontal: false, vertical: true) // Wrap en múltiples renglones
                        
                        Text(evento.categoria?.rawValue ?? "Clasificación General")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.miCuPrimary)
                            .cornerRadius(8)
                    }
                    
                    Divider()
                    
                    // Estadisticas Claves Operativas (Iconografía pedida por GEMINI)
                    HStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Image(systemName: "calendar")
                                    .foregroundColor(.miCuPrimary)
                                    .frame(width: 20)
                                Text(evento.fechaEvento ?? "Próximamente")
                                    .font(.subheadline)
                            }
                            HStack {
                                Image(systemName: "clock")
                                    .foregroundColor(.miCuPrimary)
                                    .frame(width: 20)
                                Text("\(formatTime(evento.horaInicio)) - \(formatTime(evento.horaFin))")
                                    .font(.subheadline)
                            }
                        }
                        
                        Divider().frame(height: 40)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Image(systemName: "person.2.fill")
                                    .foregroundColor(.gray)
                                    .frame(width: 20)
                                Text(evento.aforo != nil ? "Aforo: \(Int(evento.aforo!))" : "Aforo ilimitado")
                                    .font(.subheadline)
                            }
                            HStack {
                                Image(systemName: "mappin.and.ellipse")
                                    .foregroundColor(.gray)
                                    .frame(width: 20)
                                Text(evento.lugar ?? "Sede Universitaria")
                                    .font(.subheadline)
                                    .lineLimit(1)
                            }
                        }
                    }
                    
                    // Información de Contacto Directo
                    if let telefono = evento.telefonoResponsable {
                        HStack {
                            Image(systemName: "phone.fill")
                                .foregroundColor(.green)
                            Text("Responsable: \(telefono)")
                                .font(.subheadline)
                        }
                        .padding(.top, 5)
                    }
                    
                    Divider()
                    
                    // Descripción Larga
                    Text("Descripción de la Actividad")
                        .font(.headline)
                        .padding(.bottom, 2)
                    
                    Text(evento.descripcion ?? "Sin detalles de organización adicionales.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineSpacing(4)
                        
                    Spacer(minLength: 40)
                    
                    // El "Botón Estrella" de Interacción Fuerte solicitado
                    Button(action: {
                        Task {
                            inscripcionEnVuelo = true
                            // TODO: Cambiar '99999' temporal por 'authService.perfilLocal.matricula'
                            await viewModel.inscribirmeAEvento(eventoId: evento.id, alumnoId: 99999)
                            inscripcionEnVuelo = false
                        }
                    }) {
                        HStack {
                            if inscripcionEnVuelo {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Image(systemName: "star.fill")
                                Text("Inscribirme a este AFI")
                                    .fontWeight(.bold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.miCuPrimary)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(color: Color.miCuPrimary.opacity(0.3), radius: 5, x: 0, y: 3)
                    }
                    .disabled(inscripcionEnVuelo)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
            }
        }
        .navigationTitle("Ficha Técnica")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func formatTime(_ time: String?) -> String {
        return time ?? "--:--"
    }
}
#endif
