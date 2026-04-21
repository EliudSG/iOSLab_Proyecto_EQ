import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authService: AuthService
    
    var body: some View {
        TabView {
            // Tab 1: Home / Calendario Principal
            HomeView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Agenda")
                }
            
            // Tab 2: Catálogo de las AFIs Institucionales
            AFIListView()
                .tabItem {
                    Image(systemName: "list.bullet.rectangle.portrait")
                    Text("AFI")
                }
            
            // Tab 3: Mis Eventos (Donde se listan los que te inscribiste)
            MisEventosView()
                .tabItem {
                    Image(systemName: "bookmark.fill")
                    Text("Mis Eventos")
                }
            
            // Tab 4: Herramientas del estudiante (Exigido en GEMINI.md)
            HerramientasView()
                .tabItem {
                    Image(systemName: "hammer.fill")
                    Text("Herramientas")
                }
                
            // Tab 5: (SOLO ORGANIZADORES) Crear Evento
            // TODO: Envolver en un `if authService.perfilLocal?.role == .organizer` cuando la vinculación UI/BD esté finalizada
            CrearEventoView()
                .tabItem {
                    Image(systemName: "plus.app.fill")
                    Text("Crear AFI")
                }
        }
        // Este comando tiñe el Tab seleccionado con el color de la UANL
        .accentColor(.miCuPrimary) 
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(AuthService.shared)
    }
}
