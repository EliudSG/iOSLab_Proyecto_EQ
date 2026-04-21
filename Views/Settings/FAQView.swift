import SwiftUI

#if canImport(SwiftUI)
struct FAQView: View {
    @State private var esElegible = false
    @State private var comoInscrebirse = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Preguntas Frecuentes")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 10)
                
                DisclosureGroup("¿Qué cuenta como una AFI válida?", isExpanded: $esElegible) {
                    Text("De acuerdo al Artículo Académico de la UANL, un AFI son actividades culturales, formativas y deportivas aprobadas por una entidad oficial de la Facultad respectiva.")
                        .font(.body)
                        .foregroundColor(.gray)
                        .padding(.vertical, 8)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                DisclosureGroup("¿Por qué no me cuenta mi evento completado?", isExpanded: $comoInscrebirse) {
                    Text("Tu perfil se sincroniza con Supabase al abrir la App. Recuerda que solo se te contabilizan un límite máximo de dos AFIs por semestre para tus puntos oficiales (14 requerimientos totales).")
                        .font(.body)
                        .foregroundColor(.gray)
                        .padding(.vertical, 8)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Asistencia")
        .navigationBarTitleDisplayMode(.inline)
    }
}
#endif
