import SwiftUI

#if canImport(SwiftUI)
struct OnboardingView: View {
    var body: some View {
        TabView {
            // SLIDE 1
            VStack {
                Spacer()
                Image(systemName: "books.vertical.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .foregroundColor(.miCuPrimary)
                    .padding(.bottom, 20)
                
                Text("Bienvenido a MI.CU")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text("Gestiona tus Actividades Formativas Integrales fácilmente dentro del circuito Universitario.")
                    .multilineTextAlignment(.center)
                    .padding()
                    .foregroundColor(.gray)
                Spacer()
            }
            
            // SLIDE 2
            VStack {
                Spacer()
                Image(systemName: "list.star")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .foregroundColor(.orange)
                    .padding(.bottom, 20)
                
                Text("Control Total de tu Historial")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text("Verifica tus avances, ponte alarmas y asiste a tus eventos para sumar al límite del semestre.")
                    .multilineTextAlignment(.center)
                    .padding()
                    .foregroundColor(.gray)
                Spacer()
                
                Button(action: {
                    // Acción para "Empezar" / Login
                }) {
                    Text("¡Empezar Ahora!")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.miCuPrimary)
                        .cornerRadius(12)
                        .padding(.horizontal, 40)
                        .padding(.bottom, 50)
                }
            }
        }
        .tabViewStyle(PageTabViewStyle())
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
    }
}
#endif
