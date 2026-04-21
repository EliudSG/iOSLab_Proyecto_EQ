import Foundation
#if canImport(Combine)
import Combine
#endif

// Helper estructural para manejar grillas de Calendario iterativas sin crashear en SwiftUI
struct DateValue: Identifiable {
    var id = UUID().uuidString
    var day: Int 
    var date: Date
}

@MainActor
class CalendarioViewModel: ObservableObject {
    @Published var currentDate: Date = Date()
    @Published var selectedDate: Date = Date()
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
    
    init() {}
    
    func changeMonth(by value: Int) {
        if let newDate = Calendar.current.date(byAdding: .month, value: value, to: currentDate) {
            currentDate = newDate
        }
    }
    
    func selectDate(_ date: Date) {
        self.selectedDate = date
    }
    
    // Algoritmo puro de comparativa de UUIDs de Apple cruzado con Strings de PostgreSQL ("yyyy-MM-dd")
    func eventosParaElDia(todosLosEventos: [Evento], date: Date) -> [Evento] {
        let selectedDateString = dateFormatter.string(from: date)
        
        return todosLosEventos.filter { evento in
            evento.fechaEvento == selectedDateString
        }
    }
    
    func getMonthYearString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale(identifier: "es_MX")
        return formatter.string(from: currentDate).capitalized
    }
    
    // Motor iterativo que extrae todos los días válidos dependiendo de si el mes es bisiesto, 30 días o 31 días.
    func extractDates() -> [DateValue] {
        let calendar = Calendar.current
        
        let components = calendar.dateComponents([.year, .month], from: currentDate)
        guard let firstDayOfMonth = calendar.date(from: components) else { return [] }
        
        guard let range = calendar.range(of: .day, in: .month, for: firstDayOfMonth) else { return [] }
        
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        var days: [DateValue] = []
        
        // Espacios vacíos (offset visual) para alinear al día de la semana correcto
        for _ in 1..<firstWeekday {
            days.append(DateValue(day: -1, date: Date()))
        }
        
        for day in range {
            if let targetDate = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
                days.append(DateValue(day: day, date: targetDate))
            }
        }
        return days
    }
}
