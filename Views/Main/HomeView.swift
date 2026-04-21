import SwiftUI

#if canImport(SwiftUI)
struct HomeView: View {
    @StateObject private var eventViewModel = AFIListViewModel()
    @StateObject private var calendarioVM = CalendarioViewModel()
    @EnvironmentObject var authService: AuthService
    
    // Columnas base para la Matrix del Grid de SwiftUI
    let columnas = Array(repeating: GridItem(.flexible()), count: 7)
    let weekdays = ["D", "L", "M", "M", "J", "V", "S"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header Calendario Real Integrado
                VStack(spacing: 15) {
                    HStack {
                        Button(action: {
                            calendarioVM.changeMonth(by: -1)
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                        }
                        
                        Spacer()
                        Text(calendarioVM.getMonthYearString())
                            .font(.title2)
                            .fontWeight(.bold)
                        Spacer()
                        
                        Button(action: {
                            calendarioVM.changeMonth(by: 1)
                        }) {
                            Image(systemName: "chevron.right")
                                .font(.title2)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Nombres de los Días de la semana
                    HStack(spacing: 0) {
                        ForEach(weekdays, id: \.self) { day in
                            Text(day)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    
                    // Fechas extraídas del motor del CalendarioViewModel
                    LazyVGrid(columns: columnas, spacing: 15) {
                        ForEach(calendarioVM.extractDates()) { valorFecha in
                            if valorFecha.day != -1 {
                                // Es un Día real
                                let isSelected = Calendar.current.isDate(valorFecha.date, inSameDayAs: calendarioVM.selectedDate)
                                
                                VStack {
                                    Text("\(valorFecha.day)")
                                        .font(.title3)
                                        .fontWeight(isSelected ? .bold : .regular)
                                        .foregroundColor(isSelected ? .white : .primary)
                                }
                                .frame(width: 40, height: 40)
                                .background(isSelected ? Color.miCuPrimary : Color.clear)
                                .clipShape(Circle())
                                .onTapGesture {
                                    calendarioVM.selectDate(valorFecha.date)
                                }
                            } else {
                                // Espacios en Blanco para alinear los días
                                Text("")
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 10)
                .background(Color(UIColor.systemGroupedBackground)) // Fondo del Calendario
                
                Divider()
                
                // Listado de eventos ENLAZADOS Al Día Seleccionado
                let eventosFiltrados = calendarioVM.eventosParaElDia(todosLosEventos: eventViewModel.todosLosEventos, date: calendarioVM.selectedDate)
                
                if eventViewModel.isLoading {
                    Spacer()
                    ProgressView("Buscando agenda de UANL...")
                    Spacer()
                } else if eventosFiltrados.isEmpty {
                    Spacer()
                    VStack {
                        Image(systemName: "calendar.badge.clock")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                        Text("Sin AFIs programadas.")
                            .foregroundColor(.gray)
                            .padding()
                    }
                    Spacer()
                } else {
                    List {
                        ForEach(eventosFiltrados) { evento in
                            // IMPORTANTE: Navegamos a la ficha de la vista Detalle interactiva
                            NavigationLink(destination: EventoDetalleView(evento: evento)) {
                                EventoRowCard(evento: evento)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Mi Calendario")
            .navigationBarItems(
                leading: Image("UANL-Logo").resizable().frame(width: 30, height: 30),
                trailing: Menu {
                    Button("Configuración UI y Tema", action: { })
                    Button("Cerrar Sesión", role: .destructive, action: {
                        Task { try? await authService.signOut() }
                    })
                } label: {
                    Image(systemName: "line.3.horizontal") // Menú Hamburguesa exigido
                        .imageScale(.large)
                        .foregroundColor(.miCuPrimary)
                }
            )
            .onAppear {
                Task {
                    // Descargamos una vez el catálogo principal para que todo co-exista reactivamente
                    await eventViewModel.fetchCarteleraEventos()
                }
            }
        }
    }
}
#endif
