import SwiftUI

struct HistoryView: View {
    @ObservedObject var historyStore: HistoryStore
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            List {
                ForEach(historyStore.calculations.reversed()) { calc in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("\(calc.billAmount, specifier: "%.2f")")
                            Text(calc.currency)
                            Text("+ \(Int(calc.tipPercent))% Tip")
                        }
                        .font(.headline)
                        if !calc.restaurantName.isEmpty {
                            Text(calc.restaurantName)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        HStack {
                            Text("Split by \(calc.splitCount)")
                            Spacer()
                            Text(calc.date, style: .date)
                        }
                        .font(.subheadline)
                    }
                    .padding(8)
                }
                .onDelete(perform: historyStore.remove)
            }
            .navigationTitle("Calculation History")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { presentationMode.wrappedValue.dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Clear All") { historyStore.clear() }
                        .foregroundColor(.red)
                }
            }
        }
    }
}
