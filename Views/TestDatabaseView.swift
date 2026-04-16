import SwiftUI

struct TestDatabaseView: View {
    @StateObject private var viewModel = TestDatabaseViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                
                // Indicador de UI de acuerdo al estado de red
                if viewModel.isLoading {
                    ProgressView("Descargando eventos de Supabase...")
                        .padding()
                } else if let errorMessage = viewModel.errorMessage {
                    VStack {
                        Image(systemName: "xmark.octagon.fill")
                            .foregroundColor(.red)
                            .font(.largeTitle)
                        Text("Hubo un error de conexión:")
                            .font(.headline)
                            .padding(.top, 5)
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding()
                            .multilineTextAlignment(.center)
                    }
                } else if viewModel.eventos.isEmpty {
                    VStack {
                        Image(systemName: "server.rack")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                        Text("Conexión exitosa pero no hay eventos creados en tu Supabase todavía.")
                            .multilineTextAlignment(.center)
                            .padding()
                            .foregroundColor(.gray)
                    }
                } else {
                    List(viewModel.eventos) { evento in
                        VStack(alignment: .leading) {
                            Text(evento.nombreEvento ?? "Evento Sin Nombre")
                                .font(.headline)
                            Text(evento.categoria?.rawValue ?? "Sin Categoría AFI")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                Spacer()
                
                Button(action: {
                    Task {
                        await viewModel.fetchEventos()
                    }
                }) {
                    Text("Ejecutar Test de Conexión")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("Test de DB 🚀")
        }
    }
}

// Vista previa para Xcode
struct TestDatabaseView_Previews: PreviewProvider {
    static var previews: some View {
        TestDatabaseView()
    }
}
