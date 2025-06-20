import Foundation

struct Calculation: Identifiable, Codable {
    var id: UUID = UUID()
    let billAmount: Double
    let tipPercent: Double
    let splitCount: Int
    let date: Date
    var restaurantName: String = ""
    var currency: String {
        Locale.current.currency?.identifier ?? "USD"
    }
}
