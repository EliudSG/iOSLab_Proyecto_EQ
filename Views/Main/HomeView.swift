import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = AFIListViewModel()
    @EnvironmentObject var authService: AuthService
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header tipo calendario moderno iOS
                VStack(alignment: .leading, spacing: 10) {
                    Text(currentMonthYear())
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    // Carrusel horizontal fake de selección de días
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(-3...3, id: \.self) { offset in
                                let date = Calendar.current.date(byAdding: .day, value: offset, to: Date())!
                                DayBubble(date: date, isSelected: offset == 0)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 10)
                }
                .padding(.top, 10)
                .background(Color(UIColor.systemGroupedBackground))
                
                Divider()
                
                // Listado de eventos del día
                if viewModel.isLoading {
                    Spacer()
                    ProgressView("Bajando novedades de Supabase...")
                    Spacer()
                } else if viewModel.todosLosEventos.isEmpty {
                    Spacer()
                    VStack {
                        Image(systemName: "magnifyingglass")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                        Text("Día libre. No hay AFIs agendadas hoy.")
                            .foregroundColor(.gray)
                            .padding()
                    }
                    Spacer()
                } else {
                    List {
                        ForEach(viewModel.todosLosEventos) { evento in
                            EventoRowCard(evento: evento)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Mi Calendario")
            .navigationBarItems(
                leading: Image("UANL-Logo").resizable().frame(width: 30, height: 30), // Mini icono superior
                trailing: Menu {
                    Button("Configuración UI y Tema", action: { })
                    Button("Cerrar Sesión", role: .destructive, action: {
                        Task { try? await authService.signOut() }
                    })
                } label: {
                    Image(systemName: "line.3.horizontal") // Menú Hamburguesa pedido en GEMINI
                        .imageScale(.large)
                        .foregroundColor(.miCuPrimary)
                }
            )
            .onAppear {
                Task {
                    // Descargamos para mostrar lo del mes/día
                    await viewModel.fetchCarteleraEventos()
                }
            }
        }
    }
    
    func currentMonthYear() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale(identifier: "es_MX") // Forzamos a Español México
        return formatter.string(from: Date()).capitalized
    }
}

// Subvista: Cajita del Día seleccionable
struct DayBubble: View {
    let date: Date
    let isSelected: Bool
    
    var body: some View {
        VStack {
            Text(shortDayName())
                .font(.caption2)
                .foregroundColor(isSelected ? .white : .gray)
            Text(dayNumber())
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(isSelected ? .white : .primary)
        }
        .frame(width: 48, height: 60)
        .background(isSelected ? Color.miCuPrimary : Color.clear)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.3), lineWidth: isSelected ? 0 : 1)
        )
    }
    
    func shortDayName() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        formatter.locale = Locale(identifier: "es_MX")
        return formatter.string(from: date).capitalized
    }
    
    func dayNumber() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
}
