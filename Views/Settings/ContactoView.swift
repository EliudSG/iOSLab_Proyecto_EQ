import SwiftUI

#if canImport(SwiftUI)
struct ContactoView: View {
    var body: some View {
        VStack(spacing: 30) {
            Image("UANL-Logo") // Asume logo en xcassets
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .padding(.top, 40)
            
            Text("Oficina Central de Soporte AFI")
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 15) {
                HStack {
                    Image(systemName: "phone.fill")
                        .foregroundColor(.green)
                    Text("+52 (81) 8329 4000")
                }
                .font(.headline)
                
                HStack {
                    Image(systemName: "envelope.fill")
                        .foregroundColor(.blue)
                    Text("soporte.afi@uanl.mx")
                }
                .font(.headline)
                
                HStack {
                    Image(systemName: "building.2.fill")
                        .foregroundColor(.gray)
                    Text("Rectoría General y Departamentos UANL (Piso 3)")
                        .multilineTextAlignment(.center)
                }
                .font(.subheadline)
                .padding(.horizontal)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(15)
            .shadow(radius: 2)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Contáctenos")
        .navigationBarTitleDisplayMode(.inline)
    }
}
#endif
