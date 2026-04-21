import SwiftUI

#if canImport(SwiftUI)
struct HerramientasView: View {
    @StateObject private var viewModel = HerramientasViewModel()
    @State private var seleccion = 0 // 0 = Notas, 1 = Alarmas
    @State private var mostrarModalNota = false
    @State private var mostrarModalAlarma = false
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("Módulos", selection: $seleccion) {
                    Text("Bloc Rápido").tag(0)
                    Text("Mis Alarmas").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                if seleccion == 0 {
                    // TAB: Lista de Notas
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                            ForEach(viewModel.notas) { nota in
                                NotaCard(nota: nota)
                            }
                        }
                        .padding()
                    }
                } else {
                    // TAB: Listado de Alarmas
                    List {
                        ForEach(viewModel.alarmas) { alarma in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(alarma.titulo ?? "Alarma Genérica")
                                        .font(.headline)
                                    Text(alarma.hora)
                                        .font(.system(size: 32, weight: .light))
                                }
                                Spacer()
                                Toggle("", isOn: .constant(alarma.activa ?? false))
                            }
                            .padding(.vertical, 8)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
                
                Spacer()
            }
            .navigationTitle("Zona Personal")
            .navigationBarItems(trailing: Button(action: {
                if seleccion == 0 { 
                    mostrarModalNota = true 
                } else {
                    mostrarModalAlarma = true
                }
            }) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundColor(.miCuPrimary)
            })
            // Modales inyectados
            .sheet(isPresented: $mostrarModalNota) {
                NuevaNotaModal(viewModel: viewModel)
            }
            .sheet(isPresented: $mostrarModalAlarma) {
                NuevaAlarmaModal(viewModel: viewModel)
            }
            .onAppear {
                viewModel.matriculaAlumno = 1234567 // Mock User ID
                Task { await viewModel.fetchHerramientas() }
            }
        }
    }
}

// Subcomponente Gráfico
struct NotaCard: View {
    let nota: RecordatorioPersonal
    
    var colorPrioridad: Color {
        switch nota.prioridad {
        case .urgente: return .red
        case .importante: return .orange
        default: return .blue
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Circle()
                    .fill(colorPrioridad)
                    .frame(width: 8, height: 8)
                Text(nota.prioridad?.rawValue ?? "Básico")
                    .font(.caption2)
                    .foregroundColor(colorPrioridad)
                    .fontWeight(.bold)
            }
            Text(nota.titulo)
                .font(.subheadline)
                .fontWeight(.semibold)
            
            if let desc = nota.nota {
                Text(desc)
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .lineLimit(4)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(colorPrioridad.opacity(0.1))
        .cornerRadius(12)
    }
}

// Componente: Modal Crear Nota
struct NuevaNotaModal: View {
    @ObservedObject var viewModel: HerramientasViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var nTitulo = ""
    @State private var nNota = ""
    @State private var nPrioridad: PriorityLevel = .basico
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Información del Apunte")) {
                    TextField("Un título rápido...", text: $nTitulo)
                    TextEditor(text: $nNota)
                        .frame(height: 100)
                }
                
                Section(header: Text("Clasificación de Colores")) {
                    Picker("Nivel", selection: $nPrioridad) {
                        Text("🟢 Básica (Sin Prisa)").tag(PriorityLevel.basico)
                        Text("🟠 Importante (Evaluar)").tag(PriorityLevel.importante)
                        Text("🔴 Urgente (Para Hoy)").tag(PriorityLevel.urgente)
                    }
                }
            }
            .navigationTitle("Crear Apunte")
            .navigationBarItems(
                leading: Button("Cancelar") { 
                    presentationMode.wrappedValue.dismiss() 
                }.foregroundColor(.red),
                trailing: Button("Terminar") {
                    Task {
                        await viewModel.crearNotaRapida(titulo: nTitulo, descripcion: nNota, prioridad: nPrioridad)
                        presentationMode.wrappedValue.dismiss()
                    }
                }.disabled(nTitulo.isEmpty)
            )
        }
    }
}

// Componente: Modal Crear Alarma (Nuevo)
struct NuevaAlarmaModal: View {
    @ObservedObject var viewModel: HerramientasViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var aTitulo = ""
    @State private var aHora = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Configurar Alerta")) {
                    TextField("Título (Ej. Despertar para el AFI)", text: $aTitulo)
                    
                    DatePicker("Hora deseada", selection: $aHora, displayedComponents: .hourAndMinute)
                        .datePickerStyle(WheelDatePickerStyle()) // Rotador de Apple clásico
                        .labelsHidden()
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .navigationTitle("Nueva Alarma")
            .navigationBarItems(
                leading: Button("Cancelar") { 
                    presentationMode.wrappedValue.dismiss() 
                }.foregroundColor(.red),
                trailing: Button("Terminar") {
                    Task {
                        await viewModel.crearAlarma(titulo: aTitulo, hora: aHora)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            )
        }
    }
}
#endif
