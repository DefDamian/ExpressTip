import SwiftUI

struct ContentView: View {
    @State private var billAmount: String = ""
    @State private var tipPercent: Double = 18
    @State private var splitCount: Int = 1
    @State private var showHistory = false
    @State private var showCurrencyPicker = false
    @State private var showSettings = false
    @FocusState private var isBillFocused: Bool

    // NEW for restaurant prompt
    @State private var showRestaurantPrompt = false
    @State private var restaurantNameInput = ""

    @AppStorage("didShowOnboarding") private var didShowOnboarding = false
    @AppStorage("currencyCode") private var currencyCode = Locale.current.currency?.identifier ?? "USD"
    @AppStorage("appTheme") private var appTheme: String = "system"
    @AppStorage("favoriteTips") private var favoriteTipsString: String = "10,15,18,20"

    @Environment(\.colorScheme) var colorScheme
    @StateObject var historyStore = HistoryStore()

    var preferredScheme: ColorScheme? {
        switch appTheme {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }
    var favoriteTips: [Int] {
        favoriteTipsString.split(separator: ",").compactMap { Int($0) }.sorted()
    }

    var tipValue: Double {
        (Double(billAmount) ?? 0) * tipPercent / 100
    }
    var total: Double {
        (Double(billAmount) ?? 0) + tipValue
    }
    var perPerson: Double {
        total / Double(splitCount)
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Spacer()
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("TipTip Calculator")
                            .font(.largeTitle.bold())
                        Spacer()
                        Button(action: { showSettings = true }) {
                            Image(systemName: "gearshape")
                                .font(.title2)
                                .padding(8)
                                .background(Color(.systemGray6))
                                .clipShape(Circle())
                        }
                        .accessibilityLabel("Settings")
                    }

                    // Bill input with tappable currency
                    HStack {
                        TextField("Bill Amount", text: $billAmount)
                            .keyboardType(.decimalPad)
                            .font(.title2)
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(12)
                            .focused($isBillFocused)
                            .toolbar {
                                ToolbarItemGroup(placement: .keyboard) {
                                    Spacer()
                                    Button("Done") { isBillFocused = false }
                                }
                            }

                        Button(action: {
                            let generator = UISelectionFeedbackGenerator()
                            generator.prepare()
                            generator.selectionChanged()
                            showCurrencyPicker = true
                        }) {
                            Text(currencyCode)
                                .foregroundStyle(.secondary)
                                .font(.headline)
                                .padding(.trailing, 4)
                                .padding(.vertical, 2)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color(.systemGray5))
                                )
                        }
                        .buttonStyle(.plain)
                    }

                    // Tip slider with haptic feedback
                    HStack {
                        Text("Tip")
                            .font(.title3)
                        Spacer()
                        Slider(value: $tipPercent, in: 0...30, step: 1)
                            .onChange(of: tipPercent) { _ in
                                let generator = UISelectionFeedbackGenerator()
                                generator.prepare()
                                generator.selectionChanged()
                            }
                        Text("\(Int(tipPercent))%")
                            .frame(width: 50)
                    }
                    .padding(.vertical, 8)

                    // Quick tip buttons
                    HStack(spacing: 16) {
                        ForEach(favoriteTips, id: \.self) { percent in
                            Button(action: {
                                let generator = UISelectionFeedbackGenerator()
                                generator.prepare()
                                generator.selectionChanged()
                                tipPercent = Double(percent)
                            }) {
                                Text("\(percent)%")
                                    .fontWeight(tipPercent == Double(percent) ? .bold : .regular)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                                    .background(
                                        tipPercent == Double(percent)
                                            ? Color.blue.opacity(0.8)
                                            : Color(.systemGray5)
                                    )
                                    .foregroundColor(
                                        tipPercent == Double(percent)
                                            ? .white
                                            : .primary
                                    )
                                    .cornerRadius(10)
                                    .animation(.easeInOut, value: tipPercent)
                            }
                        }
                    }
                    .padding(.bottom, 4)

                    BillSplitterView(splitCount: $splitCount)
                }
                .padding(.horizontal)

                VStack(spacing: 8) {
                    HStack {
                        Text("Tip:")
                        Spacer()
                        Text("\(tipValue, specifier: "%.2f") \(currencyCode)")
                            .bold()
                    }
                    HStack {
                        Text("Total:")
                        Spacer()
                        Text("\(total, specifier: "%.2f") \(currencyCode)")
                            .bold()
                    }
                    HStack {
                        Text("Per Person:")
                        Spacer()
                        Text("\(perPerson, specifier: "%.2f") \(currencyCode)")
                            .bold()
                    }
                }
                .font(.title3)
                .padding()
                .background(.thinMaterial)
                .cornerRadius(16)
                .shadow(radius: 2)

                // Save to history opens restaurant name prompt
                Button(action: {
                    let generator = UINotificationFeedbackGenerator()
                    generator.prepare()
                    generator.notificationOccurred(.success)
                    restaurantNameInput = ""
                    showRestaurantPrompt = true
                }) {
                    Label("Save to History", systemImage: "clock.arrow.circlepath")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(ModernButtonStyle(colorScheme: colorScheme))
                .padding(.top, 8)
                // Restaurant name prompt
                .sheet(isPresented: $showRestaurantPrompt) {
                    NavigationView {
                        VStack(spacing: 24) {
                            Text("Name of Restaurant")
                                .font(.headline)
                                .padding(.top)
                            TextField("Optional", text: $restaurantNameInput)
                                .padding()
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(12)
                                .padding(.horizontal)
                                .submitLabel(.done)
                            Spacer()
                            Button(action: {
                                let generator = UINotificationFeedbackGenerator()
                                generator.prepare()
                                generator.notificationOccurred(.success)

                                let calc = Calculation(
                                    billAmount: Double(billAmount) ?? 0,
                                    tipPercent: tipPercent,
                                    splitCount: splitCount,
                                    date: Date(),
                                    restaurantName: restaurantNameInput.trimmingCharacters(in: .whitespacesAndNewlines)
                                )
                                historyStore.add(calc)
                                showRestaurantPrompt = false
                            }) {
                                Text("Save")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(14)
                                    .font(.title2.bold())
                                    .padding(.horizontal)
                            }
                            .padding(.bottom)
                        }
                        .navigationTitle("Save Tip")
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Cancel") { showRestaurantPrompt = false }
                            }
                        }
                    }
                }

                Spacer()

                Button(action: { showHistory = true }) {
                    Label("View History", systemImage: "list.bullet.rectangle")
                        .font(.title3)
                }
                .sheet(isPresented: $showHistory) {
                    HistoryView(historyStore: historyStore)
                }
            }
            .padding()
            .background(
                LinearGradient(
                    colors: colorScheme == .dark ? [.black, .gray] : [.white, .blue.opacity(0.08)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
            )
            // Tap anywhere outside to dismiss keyboard
            .onTapGesture {
                isBillFocused = false
            }
        }
        .sheet(isPresented: $showCurrencyPicker) {
            CurrencyPickerView(selectedCurrency: $currencyCode)
        }
        .fullScreenCover(isPresented: .constant(!didShowOnboarding)) {
            OnboardingView(
                didShowOnboarding: $didShowOnboarding,
                currencyCode: $currencyCode
            )
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .preferredColorScheme(preferredScheme)
    }
}

#Preview {
    ContentView()
}
