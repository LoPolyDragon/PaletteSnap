import SwiftUI

extension View {
    /// Add a card style with shadow and background
    func cardStyle(backgroundColor: Color = Color(.systemBackground)) -> some View {
        self
            .background(backgroundColor)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
    }

    /// Add haptic feedback on tap
    func hapticFeedback(_ style: HapticFeedbackStyle = .light, onTap action: @escaping () -> Void) -> some View {
        self.onTapGesture {
            switch style {
            case .light:
                HapticFeedbackService.shared.lightImpact()
            case .medium:
                HapticFeedbackService.shared.mediumImpact()
            case .heavy:
                HapticFeedbackService.shared.heavyImpact()
            case .selection:
                HapticFeedbackService.shared.selectionChanged()
            case .success:
                HapticFeedbackService.shared.success()
            }
            action()
        }
    }

    /// Conditional modifier
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    /// Hide keyboard
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    /// Add a loading overlay
    func loadingOverlay(_ isLoading: Bool) -> some View {
        self.overlay {
            if isLoading {
                ZStack {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()

                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                }
            }
        }
    }

    /// Add a shimmer effect for loading states
    func shimmer() -> some View {
        self.modifier(ShimmerModifier())
    }
}

// MARK: - Supporting Types

enum HapticFeedbackStyle {
    case light
    case medium
    case heavy
    case selection
    case success
}

// MARK: - Shimmer Modifier

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [
                        .clear,
                        .white.opacity(0.3),
                        .clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: -200 + phase)
                .mask(content)
            )
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 400
                }
            }
    }
}
