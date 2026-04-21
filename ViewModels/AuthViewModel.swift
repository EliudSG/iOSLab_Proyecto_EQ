import Foundation
import Supabase
#if canImport(Combine)
import Combine
#endif
@MainActor
class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var nombre = "" // Usado solo en pantalla de Registro
    
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    init() {}
    
    /// Valida que el estudiante haya llenado su matrícula/correo y pase
    private var isFormValid: Bool {
        return !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && 
               !password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    /// Conecta con AuthService para hacer un signIn en vivo
    func login() async {
        guard isFormValid else {
            errorMessage = "Llena todos los campos vacíos."
            return
        }
        
        isLoading = true
        errorMessage = nil
        do {
            try await AuthService.shared.signIn(email: email, password: password)
        } catch {
            errorMessage = "Fallo al iniciar sesión. Revisa tus credenciales institucionales."
            print("Login error: \(error.localizedDescription)")
        }
        isLoading = false
    }
    
    /// Registra en Supabase un nuevo User
    func register() async {
        guard isFormValid, !nombre.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Asegúrate de llenar tu nombre completo también."
            return
        }
        
        isLoading = true
        errorMessage = nil
        do {
            // Nota: Aquí registramos el Auth con correo. Si ocupamos añadirlo a la tabla pública `Usuarios`,
            // podríamos requerir usar una Function/Trigger en Supabase (Hook) o invocar un `.insert()`
            let _ = try await supabase.auth.signUp(email: email, password: password)
        } catch {
            errorMessage = "Fallo al crear cuenta: \(error.localizedDescription)"
        }
        isLoading = false
    }
}
