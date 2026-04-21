import SwiftUI

#if canImport(SwiftUI)
struct CrearEventoView: View {
    @StateObject private var viewModel = EventoViewModel()
    // Matricula temporal (idealmente inyectada del Auth global)
    let organizadorID: Double = 123456
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Información Principal")) {
                    TextField("Nombre del Evento", text: $viewModel.nombreEvento)
                    
                    Picker("Categoría", selection: $viewModel.categoria) {
                        ForEach(CategoriaAFI.allCases, id: \.self) { cat in
                            Text(cat.rawValue).tag(cat)
                        }
                    }
                }
                
                Section(header: Text("Horarios y Ubicación")) {
                    DatePicker("Fecha del evento", selection: $viewModel.fechaEvento, displayedComponents: .date)
                    DatePicker("Hora de Inicio", selection: $viewModel.horaInicio, displayedComponents: .hourAndMinute)
                    DatePicker("Hora de Fin", selection: $viewModel.horaFin, displayedComponents: .hourAndMinute)
                    
                    TextField("Lugar / Sede", text: $viewModel.lugar)
                }
                
                Section(header: Text("Detalles Operativos")) {
                    TextField("Aforo (Capacidad Máxima)", text: $viewModel.aforoTexto)
                        .keyboardType(.numberPad)
                    
                    TextField("Teléfono Responsable", text: $viewModel.telefonoResponsable)
                        .keyboardType(.phonePad)
                        
                    TextField("Departamento Solicitante", text: $viewModel.departamentoSolicitante)
                }
                
                Section(header: Text("Descripción de la Actividad")) {
                    TextEditor(text: $viewModel.descripcion)
                        .frame(minHeight: 100)
                }
                
                // Botón Final
                Section {
                    Button(action: {
                        Task {
                            await viewModel.crearEvento(matriculaOrganizador: organizadorID)
                        }
                    }) {
                        HStack {
                            Spacer()
                            if viewModel.isLoading {
                                ProgressView()
                            } else {
                                Text("Publicar AFI")
                                    .fontWeight(.bold)
                            }
                            Spacer()
                        }
                    }
                    .disabled(viewModel.isLoading)
                    .foregroundColor(viewModel.isLoading ? .gray : .white)
                    .listRowBackground(viewModel.isLoading ? Color.gray.opacity(0.3) : Color.miCuPrimary)
                }
            }
            .navigationTitle("Crear Nuevo Evento")
            .alert(isPresented: Binding<Bool>(
                get: { viewModel.errorMessage != nil || viewModel.isSuccess },
                set: { _ in }
            )) {
                if viewModel.isSuccess {
                    return Alert(
                        title: Text("¡Éxito!"),
                        message: Text("El evento se publicó correctamente para los alumnos."),
                        dismissButton: .default(Text("Cerrar")) {
                            viewModel.isSuccess = false
                        }
                    )
                } else {
                    return Alert(
                        title: Text("Error"),
                        message: Text(viewModel.errorMessage ?? "Error desconocido"),
                        dismissButton: .default(Text("Entendido")) {
                            viewModel.errorMessage = nil
                        }
                    )
                }
            }
        }
    }
}

struct CrearEventoView_Previews: PreviewProvider {
    static var previews: some View {
        CrearEventoView()
    }
}
#endif
