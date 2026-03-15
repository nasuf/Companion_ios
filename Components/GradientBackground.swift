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
                    Color(red: 0.15, green: 0.08, blue: 0.10), // Warm very dark red/brown
                    Color(red: 0.20, green: 0.10, blue: 0.12), // Deep aubergine/warm dark slate
                    Color(red: 0.12, green: 0.05, blue: 0.08), // Dark berry shadow
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            LinearGradient(
                colors: [
                    Color(red: 0.98, green: 0.92, blue: 0.90), // Soft cream/peach
                    Color(red: 1.00, green: 0.96, blue: 0.94), // Warm light off-white
                    Color(red: 0.97, green: 0.90, blue: 0.92), // Very soft pink
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
        colors: [Color(red: 1.0, green: 0.5, blue: 0.4), Color(red: 1.0, green: 0.3, blue: 0.5)], // Sunset Coral/Pink
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let subtle = LinearGradient(
        colors: [Color(red: 1.0, green: 0.5, blue: 0.4).opacity(0.6), Color(red: 1.0, green: 0.3, blue: 0.5).opacity(0.6)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
