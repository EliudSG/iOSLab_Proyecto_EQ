import Foundation
import Supabase

struct SupabaseConfig {
    static let url = URL(string: "https://iqjvrsblrpkuumnfdhst.supabase.co")!
    static let anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlxanZyc2JscnBrdXVtbmZkaHN0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQwMjUxMjIsImV4cCI6MjA4OTYwMTEyMn0.RGcvnzdbYfJAyyqK_a9Lfs7FnPNxKraEAB4Ofm0rL0c"
}

/// Instancia global del cliente de Supabase
/// Úsala en todo el proyecto como `try await supabase.from("Tabla")...`
let supabase = SupabaseClient(
    supabaseURL: SupabaseConfig.url,
    supabaseKey: SupabaseConfig.anonKey
)
