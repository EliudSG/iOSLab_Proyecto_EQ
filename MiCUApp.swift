import SwiftUI

@main
struct MiCUApp: App {
    // Inyectamos nuestro Singleton de Auth de forma global
    @StateObject private var authService = AuthService.shared
    
    var body: some Scene {
        WindowGroup {
            if authService.isLoading {
                // Splash screen o vista de carga mientras se verifica la sesión
                VStack {
                    Image("UANL-Logo") // Nuestra imagen 
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                    ProgressView("Verificando autenticación...")
                        .padding()
                }
            } else if authService.isAuthenticated {
                // Si el alumno está logueado correctametne en BD, va a la app (Dashboard principal)
                MainTabView()
                    .environmentObject(authService) // Permanece en memoria
            } else {
                // Si no hay sesión válida o cerró sesión
                LoginView()
                    .environmentObject(authService)
            }
        }
    }
}

// ✅ PLACEHOLDER: Solo para que puedas ver que funcionó si el Login es correcto.
// Más adelante dividiremos esto en el verdadero MainView / CalendarioView.
struct MainTabViewPlaceholder: View {
    @EnvironmentObject var authService: AuthService
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "calendar.day.timeline.left")
                .font(.system(size: 80))
                .foregroundColor(.miCuPrimary)
            
            Text("¡Bienvenido al Calendario MI.CU!")
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text("Tu sesión fue iniciada exitosamente. Tu JWT ahora te protege.")
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            Button(action: {
                Task {
                    try? await authService.signOut()
                }
            }){
                Text("Cerrar Sesión")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .foregroundColor(.red)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 30)
            .padding(.top, 20)
            
            // Botoncito para invocar el Test a la BD que ya teníamos
            NavigationLink(destination: TestDatabaseView()) {
                Text("Ir a Diagnóstico de BD")
                    .foregroundColor(.blue)
            }
            .padding(.top)
        }
        .padding()
    }
}
