import SwiftUI

struct OnboardingView: View {
    @Binding var didShowOnboarding: Bool
    @Binding var currencyCode: String

    @AppStorage("appTheme") private var appTheme: String = "system"
    @AppStorage("favoriteTips") private var favoriteTipsString: String = "10,15,18,20"
    var favoriteTips: [Int] {
        get { favoriteTipsString.split(separator: ",").compactMap { Int($0) } }
        set { favoriteTipsString = newValue.map { String($0) }.joined(separator: ",") }
    }

    @State private var step: Int = 0
    @State private var selectedCurrency: String = ""
    @State private var selectedTheme: String = "system"
    @State private var selectedTips: Set<Int> = [10, 15, 18, 20]
    @State private var showConfetti = false

    @Environment(\.colorScheme) var colorScheme

    let currencies: [(code: String, flag: String)] = [
        ("USD", "🇺🇸"), ("EUR", "🇪🇺"), ("GBP", "🇬🇧"), ("JPY", "🇯🇵"),
        ("CAD", "🇨🇦"), ("AUD", "🇦🇺"), ("INR", "🇮🇳"), ("CNY", "🇨🇳"),
        ("BRL", "🇧🇷"), ("MXN", "🇲🇽"), ("CHF", "🇨🇭"), ("RUB", "🇷🇺"),
        ("KRW", "🇰🇷"), ("SEK", "🇸🇪"), ("TRY", "🇹🇷"), ("ZAR", "🇿🇦"),
        ("SAR", "🇸🇦"), ("AED", "🇦🇪"), ("PLN", "🇵🇱"), ("NZD", "🇳🇿"),
        ("HKD", "🇭🇰"), ("SGD", "🇸🇬"), ("THB", "🇹🇭"), ("DKK", "🇩🇰"),
        ("MYR", "🇲🇾"), ("IDR", "🇮🇩")
    ]
    let allTips: [Int] = [5, 10, 12, 15, 18, 20, 22, 25, 30]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: colorScheme == .dark
                    ? [Color.black, Color.gray.opacity(0.4)]
                    : [Color.blue.opacity(0.13), Color.gray.opacity(0.07)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            ).ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()
                // 1. Theme selection
                if step == 0 {
                    VStack(spacing: 24) {
                        Text("Welcome!")
                            .font(.largeTitle.bold())
                            .foregroundColor(colorScheme == .dark ? .white : .primary)
                        Text("Select your app theme:")
                            .font(.title3)
                            .foregroundColor(colorScheme == .dark ? .white : .primary)
                        Picker("Theme", selection: $selectedTheme) {
                            Label("System", systemImage: "gearshape").tag("system")
                            Label("Light", systemImage: "sun.max").tag("light")
                            Label("Dark", systemImage: "moon.stars").tag("dark")
                        }
                        .pickerStyle(.segmented)
                        .padding()
                        Button("Next") {
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.prepare()
                            generator.impactOccurred()
                            appTheme = selectedTheme
                            step += 1
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                // 2. Preferred tips selection
                else if step == 1 {
                    VStack(spacing: 18) {
                        Text("Choose your favorite tip %s")
                            .font(.title3)
                            .multilineTextAlignment(.center)
                        Text("(Pick 2 to 4, these appear as quick buttons)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        WrapHStack(items: allTips, id: \.self, spacing: 12) { tip in
                            Button(action: {
                                let generator = UISelectionFeedbackGenerator()
                                generator.prepare()
                                generator.selectionChanged()
                                if selectedTips.contains(tip) {
                                    selectedTips.remove(tip)
                                } else if selectedTips.count < 4 {
                                    selectedTips.insert(tip)
                                }
                            }) {
                                Text("\(tip)%")
                                    .fontWeight(selectedTips.contains(tip) ? .bold : .regular)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                                    .background(selectedTips.contains(tip) ? Color.blue : Color(.systemGray5))
                                    .foregroundColor(selectedTips.contains(tip) ? .white : .primary)
                                    .cornerRadius(12)
                                    .shadow(radius: selectedTips.contains(tip) ? 2 : 0)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.vertical, 8)
                        Button("Next") {
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.prepare()
                            generator.impactOccurred()
                            favoriteTipsString = Array(selectedTips).sorted().map { String($0) }.joined(separator: ",")
                            step += 1
                        }
                        .disabled(selectedTips.count < 2 || selectedTips.count > 4)
                        .buttonStyle(.borderedProminent)
                    }
                }
                // 3. Currency selection
                else if step == 2 {
                    VStack(spacing: 24) {
                        Text("Select your currency")
                            .font(.title)
                            .foregroundColor(colorScheme == .dark ? .white : .primary)
                        Picker("Currency", selection: $selectedCurrency) {
                            ForEach(currencies, id: \.code) { curr in
                                HStack {
                                    Text(curr.flag)
                                    Text(curr.code)
                                }
                                .tag(curr.code)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(height: 150)
                        .clipped()
                        Button("Next") {
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.prepare()
                            generator.impactOccurred()
                            currencyCode = selectedCurrency.isEmpty ? "USD" : selectedCurrency
                            step += 1
                        }
                        .disabled(selectedCurrency.isEmpty)
                        .buttonStyle(.borderedProminent)
                        .padding(.top)
                    }
                }
                // 4. Summary
                else if step == 3 {
                    VStack(spacing: 20) {
                        Text("Review your setup:")
                            .font(.title2)
                        HStack {
                            Text("Theme:")
                            Spacer()
                            if appTheme == "system" { Text("System") }
                            if appTheme == "light" { Text("Light") }
                            if appTheme == "dark" { Text("Dark") }
                        }
                        HStack {
                            Text("Quick Tip Buttons:")
                            Spacer()
                            ForEach(favoriteTips, id: \.self) { tip in
                                Text("\(tip)%")
                            }
                        }
                        HStack {
                            Text("Currency:")
                            Spacer()
                            if let curr = currencies.first(where: { $0.code == currencyCode }) {
                                Text("\(curr.flag) \(curr.code)")
                            }
                        }
                        Text("You can change your currency anytime by tapping the currency icon next to your bill amount.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.top, 8)
                        Button("Finish") {
                            let generator = UINotificationFeedbackGenerator()
                            generator.prepare()
                            generator.notificationOccurred(.success)
                            withAnimation {
                                showConfetti = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                                didShowOnboarding = true
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.top)
                    }
                }
                Spacer()
            }
            .padding()

            if showConfetti {
                ConfettiView()
                    .transition(.opacity)
            }
        }
        .onAppear {
            selectedCurrency = currencyCode
            selectedTheme = appTheme
            selectedTips = Set(favoriteTips)
        }
    }
}

// MARK: - Confetti Animation View
struct ConfettiView: View {
    @State private var animate = false
    let confettiColors: [Color] = [.red, .yellow, .blue, .green, .purple, .orange]
    var body: some View {
        ZStack {
            ForEach(0..<25, id: \.self) { i in
                Circle()
                    .fill(confettiColors[i % confettiColors.count])
                    .frame(width: 12, height: 12)
                    .offset(
                        x: animate ? CGFloat.random(in: -160...160) : 0,
                        y: animate ? CGFloat.random(in: -420...420) : 0
                    )
                    .opacity(animate ? 0 : 1)
                    .animation(
                        .easeOut(duration: Double.random(in: 1.0...1.5)),
                        value: animate
                    )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            animate = true
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Helper for tip buttons in a wrap layout
struct WrapHStack<Data: RandomAccessCollection, ID: Hashable, Content: View>: View {
    let items: Data
    let id: KeyPath<Data.Element, ID>
    let spacing: CGFloat
    let content: (Data.Element) -> Content

    init(items: Data, id: KeyPath<Data.Element, ID>, spacing: CGFloat = 8, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.items = items
        self.id = id
        self.spacing = spacing
        self.content = content
    }

    var body: some View {
        let rows = Array(repeating: GridItem(.flexible(), spacing: spacing), count: 2)
        LazyVGrid(columns: rows, spacing: spacing) {
            ForEach(items, id: id) { item in
                content(item)
            }
        }
    }
}
