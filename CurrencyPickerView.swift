import SwiftUI

struct CurrencyPickerView: View {
    @Binding var selectedCurrency: String

    let currencies: [(code: String, flag: String)] = [
        ("USD", "🇺🇸"), ("EUR", "🇪🇺"), ("GBP", "🇬🇧"), ("JPY", "🇯🇵"),
        ("CAD", "🇨🇦"), ("AUD", "🇦🇺"), ("INR", "🇮🇳"), ("CNY", "🇨🇳"),
        ("BRL", "🇧🇷"), ("MXN", "🇲🇽"), ("CHF", "🇨🇭"), ("RUB", "🇷🇺"),
        ("KRW", "🇰🇷"), ("SEK", "🇸🇪"), ("TRY", "🇹🇷"), ("ZAR", "🇿🇦"),
        ("SAR", "🇸🇦"), ("AED", "🇦🇪"), ("PLN", "🇵🇱"), ("NZD", "🇳🇿"),
        ("HKD", "🇭🇰"), ("SGD", "🇸🇬"), ("THB", "🇹🇭"), ("DKK", "🇩🇰"),
        ("MYR", "🇲🇾"), ("IDR", "🇮🇩")
    ]

    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            List {
                ForEach(currencies, id: \.code) { currency in
                    Button(action: {
                        let generator = UISelectionFeedbackGenerator()
                        generator.prepare()
                        generator.selectionChanged()
                        selectedCurrency = currency.code
                        dismiss()
                    }) {
                        HStack {
                            Text(currency.flag)
                            Text(currency.code)
                            if selectedCurrency == currency.code {
                                Spacer()
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationTitle("Choose Currency")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}
