import SwiftUI

struct ModernButtonStyle: ButtonStyle {
    var colorScheme: ColorScheme
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(
                colorScheme == .dark
                    ? Color.blue.opacity(configuration.isPressed ? 0.6 : 0.85)
                    : Color.blue.opacity(configuration.isPressed ? 0.85 : 1)
            )
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: .black.opacity(0.2), radius: configuration.isPressed ? 1 : 4, x: 0, y: 1)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
    }
}
