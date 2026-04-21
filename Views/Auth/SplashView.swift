import SwiftUI

#if canImport(SwiftUI)
struct SplashView: View {
    @State private var activo = false
    
    var body: some View {
        ZStack {
            Color.miCuPrimary.ignoresSafeArea()
            
            VStack {
                Image(systemName: "graduationcap.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.white)
                Text("MI.CU")
                    .font(.largeTitle)
                    .fontWeight(.black)
                    .foregroundColor(.white)
            }
            .scaleEffect(activo ? 1.0 : 0.6)
            .opacity(activo ? 1.0 : 0.0)
            .animation(.easeOut(duration: 1.2), value: activo)
        }
        .onAppear {
            self.activo = true
            // En un flujo real, aquí llamaríamos a un "AppRouter" en ~2s
        }
    }
}
#endif
