import SwiftUI

struct SettingsView: View {
    @AppStorage("appTheme") private var appTheme: String = "system"
    @AppStorage("currencyCode") private var currencyCode: String = "USD"
    @AppStorage("didShowOnboarding") private var didShowOnboarding: Bool = true

    let currencies: [(code: String, flag: String)] = [
        ("USD", "🇺🇸"), ("EUR", "🇪🇺"), ("GBP", "🇬🇧"), ("JPY", "🇯🇵"),
        ("CAD", "🇨🇦"), ("AUD", "🇦🇺"), ("INR", "🇮🇳"), ("CNY", "🇨🇳"),
        ("BRL", "🇧🇷"), ("MXN", "🇲🇽"), ("CHF", "🇨🇭"), ("RUB", "🇷🇺"),
        ("KRW", "🇰🇷"), ("SEK", "🇸🇪"), ("TRY", "🇹🇷"), ("ZAR", "🇿🇦"),
        ("SAR", "🇸🇦"), ("AED", "🇦🇪"), ("PLN", "🇵🇱"), ("NZD", "🇳🇿"),
        ("HKD", "🇭🇰"), ("SGD", "🇸🇬"), ("THB", "🇹🇭"), ("DKK", "🇩🇰"),
        ("MYR", "🇲🇾"), ("IDR", "🇮🇩")
    ]
    let themes = [("system", "System", "gearshape"), ("light", "Light", "sun.max"), ("dark", "Dark", "moon.stars")]

    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Theme")) {
                    Picker("Theme", selection: $appTheme) {
                        ForEach(themes, id: \.0) { theme in
                            Label(theme.1, systemImage: theme.2).tag(theme.0)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section(header: Text("Default Currency")) {
                    Picker("Currency", selection: $currencyCode) {
                        ForEach(currencies, id: \.code) { curr in
                            HStack {
                                Text(curr.flag)
                                Text(curr.code)
                            }
                            .tag(curr.code)
                        }
                    }
                }

                Section {
                    Button(role: .destructive) {
                        didShowOnboarding = false
                        dismiss()
                    } label: {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Reset Onboarding / Tutorial")
                        }
                    }
                }

                Section(header: Text("About")) {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Image(systemName: "banknote")
                                .foregroundColor(.green)
                            Text("Express Tip")
                                .font(.headline)
                        }
                        Text("Note: Your tip history is stored only on this device. If you delete the app, your saved history will be lost.")
                                  .font(.footnote)
                                  .foregroundColor(.secondary)
                        
                        Text("Built with ❤️ using SwiftUI\nVersion 1.0.0\n\n© \(Calendar.current.component(.year, from: Date())) Damian Cedeño")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        Link("GitHub", destination: URL(string: "https://github.com/your-repo-if-you-have-one")!)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
