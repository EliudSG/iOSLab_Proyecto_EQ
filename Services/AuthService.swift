import Foundation
import Supabase
#if canImport(Combine)
import Combine
#endif
@MainActor
final class AuthService: ObservableObject {
    /// Singleton para poder accederlo de forma global o inyectarlo en el Environment de SwiftUI
    static let shared = AuthService()
    
    @Published var currentUser: User?
    @Published var isAuthenticated: Bool = false
    @Published var isLoading: Bool = true
    
    private init() {
        Task {
            await observeAuthState()
        }
    }
    
    /// Escucha y actualiza en tiempo real los cambios de sesión (Login, Logout, Token Expirado)
    private func observeAuthState() async {
        for await state in await supabase.auth.authStateChanges {
            self.currentUser = state.session?.user
            self.isAuthenticated = state.session != nil
            self.isLoading = false
        }
    }
    
    /// Inicia sesión usando correo y contraseña.
    func signIn(email: String, password: String) async throws {
        try await supabase.auth.signIn(email: email, password: password)
    }
    
    /// Cierra la sesión activa borrando el JWT.
    func signOut() async throws {
        try await supabase.auth.signOut()
    }
}
