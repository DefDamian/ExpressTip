import Foundation
import Combine
import SwiftUI // Add this line

class HistoryStore: ObservableObject {
    @Published var calculations: [Calculation] = []
    let key = "TipTipHistory"
    
    init() {
        load()
    }
    
    func add(_ calculation: Calculation) {
        calculations.append(calculation)
        save()
    }
    
    func remove(at offsets: IndexSet) {
        calculations.remove(atOffsets: offsets) // Will now work!
        save()
    }
    
    func clear() {
        calculations.removeAll()
        save()
    }
    
    private func save() {
        if let encoded = try? JSONEncoder().encode(calculations) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    private func load() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([Calculation].self, from: data) {
            self.calculations = decoded
        }
    }
}
