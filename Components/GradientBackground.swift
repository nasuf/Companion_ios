import SwiftUI

struct GradientBackground: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .background(gradient.ignoresSafeArea())
    }

    private var gradient: LinearGradient {
        if colorScheme == .dark {
            LinearGradient(
                colors: [
                    Color(red: 0.08, green: 0.02, blue: 0.15),
                    Color(red: 0.02, green: 0.05, blue: 0.20),
                    Color(red: 0.05, green: 0.02, blue: 0.12),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            LinearGradient(
                colors: [
                    Color(red: 0.93, green: 0.90, blue: 0.98),
                    Color(red: 0.88, green: 0.92, blue: 0.99),
                    Color(red: 0.95, green: 0.92, blue: 0.98),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

extension View {
    func gradientBackground() -> some View {
        modifier(GradientBackground())
    }
}

struct BrandGradient {
    static let primary = LinearGradient(
        colors: [.purple, .indigo],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let subtle = LinearGradient(
        colors: [.purple.opacity(0.6), .indigo.opacity(0.6)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
