import SwiftUI

struct MisEventosView: View {
    @StateObject private var viewModel = AFIListViewModel()
    @EnvironmentObject var authService: AuthService
    
    @State private var filtroActivo: StatusFiltro = .pendientes
    
    enum StatusFiltro: String, CaseIterable {
        case pendientes = "Por Asistir"
        case finalizadas = "Completadas ★"
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Selector Superior (Picker)
                Picker("Filtrar eventos", selection: $filtroActivo) {
                    ForEach(StatusFiltro.allCases, id: \.self) { status in
                        Text(status.rawValue).tag(status)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Extraer solo los `Evento` cruzando el JSON the supbabase `misInscripciones`
                let miListaDeInscripciones = viewModel.misInscripciones.filter { ins in
                    filtroActivo == .pendientes ? (ins.finalizada == false || ins.finalizada == nil) : (ins.finalizada == true)
                }
                
                let misEventosFiltrados = viewModel.todosLosEventos.filter { evento in 
                    miListaDeInscripciones.contains(where: { $0.eventoId == evento.id })
                }
                
                if viewModel.isLoading {
                    Spacer()
                    ProgressView("Buscando tus boletas...")
                    Spacer()
                } else if misEventosFiltrados.isEmpty {
                    Spacer()
                    VStack {
                        Image(systemName: "folder.badge.questionmark")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                        Text(filtroActivo == .pendientes ? "No te has inscrito a nada aún." : "No has finalizado tu primer AFI.")
                            .foregroundColor(.gray)
                            .padding(.top, 5)
                            .multilineTextAlignment(.center)
                    }
                    Spacer()
                } else {
                    List(misEventosFiltrados) { evento in
                        VStack(alignment: .leading) {
                            EventoRowCard(evento: evento)
                            
                            // Botón especial para interactuar si está en "Pendientes"
                            if filtroActivo == .pendientes {
                                Button(action: {
                                    if let ins = viewModel.misInscripciones.first(where: { $0.eventoId == evento.id }) {
                                        Task { await viewModel.marcarAFIFinalizada(inscripcionId: ins.id, true) }
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: "star")
                                        Text("Marcar como Finalizada")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(Color.yellow.opacity(0.15))
                                    .foregroundColor(.orange)
                                    .cornerRadius(10)
                                }
                                .padding(.top, 5)
                            } else {
                                // Indicador visual de que la meta se ha cumplido
                                HStack {
                                    Image(systemName: "checkmark.seal.fill")
                                        .foregroundColor(.green)
                                    Text("¡AFI Validada y Aprobada!")
                                        .font(.caption)
                                        .foregroundColor(.green)
                                        .fontWeight(.bold)
                                }
                                .padding(.top, 10)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Mi Portafolio")
            .onAppear {
                Task {
                    // PLACEHOLDER: Debemos reemplazar este userID por el UUID/Matrícula real luego
                    let simulatedUserId: Double = 1234567 
                    await viewModel.fetchCarteleraEventos()
                    await viewModel.fetchMisActividades(matricula: simulatedUserId)
                }
            }
        }
    }
}
