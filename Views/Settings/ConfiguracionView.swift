import SwiftUI

#if canImport(SwiftUI)
struct ConfiguracionView: View {
    @StateObject private var viewModel = ConfiguracionViewModel()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Preferencias de Pantalla")) {
                    Toggle("Modo Oscuro Requerido", isOn: $viewModel.isDarkTheme)
                    
                    Picker("Idioma de Interfaz", selection: $viewModel.selectedLanguage) {
                        Text("Español").tag("Español")
                        Text("English").tag("English")
                    }
                }
                
                Section(header: Text("Gestión de Alertas")) {
                    Toggle("Activar Notificaciones Push", isOn: $viewModel.notificationsEnabled)
                        .toggleStyle(SwitchToggleStyle(tint: .miCuPrimary))
                }
                
                Section {
                    Button(action: {
                        Task { try? await viewModel.guardarPreferencias(matricula: 1234567) }
                    }) {
                        Text("Sincronizar en la Nube")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(.blue)
                    }
                }
            }
            .navigationTitle("Mi Perfil Universitario")
        }
    }
}
#endif
