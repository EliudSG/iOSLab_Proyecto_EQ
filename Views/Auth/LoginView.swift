import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = AuthViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                // Fondo clásico nativo
                Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 25) {
                    Spacer()
                    
                    // Logo de UANL
                    Image("UANL-Logo") // La imagen descargada debe arrastrarse al Assets.xcassets de Xcode
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                        .padding(.bottom, 10)
                    
                    Text("MI.CU")
                        .font(.largeTitle)
                        .fontWeight(.black)
                        .foregroundColor(.miCuPrimary)
                    
                    Text("Mi Calendario Universitario")
                        .font(.body)
                        .foregroundColor(.gray)
                    
                    // Formulario de Ingreso
                    VStack(spacing: 15) {
                        TextField("Correo Universitario", text: $viewModel.email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .padding()
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .cornerRadius(10)
                            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                        
                        SecureField("Contraseña", text: $viewModel.password)
                            .padding()
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .cornerRadius(10)
                            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                    }
                    .padding(.horizontal, 30)
                    .padding(.top, 10)
                    
                    // Renderizado de Alerta Inferior
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    // Botón Maestro de Autenticación
                    Button(action: {
                        Task { await viewModel.login() }
                    }) {
                        HStack {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .padding(.trailing, 5)
                            }
                            Text("Servicios en Línea (Login)")
                                .fontWeight(.bold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.miCuPrimary)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(color: Color.miCuPrimary.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .disabled(viewModel.isLoading)
                    .padding(.horizontal, 30)
                    .padding(.top, 10)
                    
                    Spacer()
                    
                    // Redirección a Register
                    NavigationLink(destination: RegistroView()) {
                        HStack {
                            Text("¿No tienes cuenta?")
                                .foregroundColor(.gray)
                            Text("Regístrate aquí")
                                .fontWeight(.bold)
                                .foregroundColor(.miCuPrimary)
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
