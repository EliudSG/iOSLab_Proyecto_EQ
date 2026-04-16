import SwiftUI

struct AFIListView: View {
    @StateObject private var viewModel = AFIListViewModel()
    
    // Tipos de AFI sacados del ENUM para el scroll horizontal superior
    let categorias: [CategoriaAFI] = [
        .culturales, .deportivas, .academicas, .artistica, 
        .investigacion, .idiomas, .responsabilidadSocial, .innovacionYEmprendimiento
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                // ScrollView de Filtros Interactivos (Chips)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        // Filtro especial "Todas"
                        Button(action: { viewModel.categoriaActiva = nil }) {
                            Text("🌎 Todas")
                                .font(.callout)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 15)
                                .padding(.vertical, 8)
                                .background(viewModel.categoriaActiva == nil ? Color.miCuPrimary : Color(UIColor.systemGray6))
                                .foregroundColor(viewModel.categoriaActiva == nil ? .white : .primary)
                                .cornerRadius(20)
                        }
                        
                        ForEach(categorias, id: \.self) { cat in
                            Button(action: {
                                // Efecto Toggle: si la picas otra vez, se desmarca.
                                if viewModel.categoriaActiva == cat {
                                    viewModel.categoriaActiva = nil
                                } else {
                                    viewModel.categoriaActiva = cat
                                }
                            }) {
                                Text(cat.rawValue)
                                    .font(.callout)
                                    .fontWeight(.semibold)
                                    .padding(.horizontal, 15)
                                    .padding(.vertical, 8)
                                    .background(viewModel.categoriaActiva == cat ? colorForCategoria(cat) : Color(UIColor.systemGray6))
                                    .foregroundColor(viewModel.categoriaActiva == cat ? .white : .primary)
                                    .cornerRadius(20)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                }
                
                Divider()
                
                // Zona Interna: Lista Filtrada Cartelera
                if viewModel.isLoading {
                    Spacer()
                    ProgressView("Buscando en catálogo...")
                    Spacer()
                } else if viewModel.carteleraFiltrada.isEmpty {
                    Spacer()
                    Text("No se publicaron AFIs bajo esta categoría oficial.")
                        .foregroundColor(.gray)
                    Spacer()
                } else {
                    List(viewModel.carteleraFiltrada) { evento in
                        // Envolver en NavigationLink para ir al Detalle general (AFI/DetalleView)
                        NavigationLink(destination: Text("Próximamente: Detalle exacto de \(evento.nombreEvento ?? "")")) {
                            EventoRowCard(evento: evento)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Catálogo Oficial")
            .onAppear {
                Task {
                    await viewModel.fetchCarteleraEventos()
                }
            }
        }
    }
    
    // Función espejo de UI
    func colorForCategoria(_ cat: CategoriaAFI) -> Color {
        switch cat {
        case .culturales: return .afiCulturales
        case .deportivas: return .afiDeportivas
        case .academicas: return .afiAcademicas
        case .responsabilidadSocial: return .afiResponsabilidadSocial
        case .innovacionYEmprendimiento: return .afiInnovacion
        case .investigacion: return .afiInvestigacion
        case .idiomas: return .afiIdiomas
        case .artistica: return .afiArtistica
        case .intercambioAcademico: return .afiIntercambio
        case .institucional: return .afiInstitucional
        }
    }
}
