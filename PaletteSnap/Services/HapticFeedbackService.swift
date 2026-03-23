import UIKit

/// Service for providing haptic feedback throughout the app
final class HapticFeedbackService {
    static let shared = HapticFeedbackService()

    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let selection = UISelectionFeedbackGenerator()
    private let notification = UINotificationFeedbackGenerator()

    private init() {
        // Prepare generators for lower latency
        impactLight.prepare()
        impactMedium.prepare()
        impactHeavy.prepare()
        selection.prepare()
        notification.prepare()
    }

    /// Light impact feedback (e.g., tapping a color)
    func lightImpact() {
        impactLight.impactOccurred()
        impactLight.prepare()
    }

    /// Medium impact feedback (e.g., selecting a tab)
    func mediumImpact() {
        impactMedium.impactOccurred()
        impactMedium.prepare()
    }

    /// Heavy impact feedback (e.g., deleting a palette)
    func heavyImpact() {
        impactHeavy.impactOccurred()
        impactHeavy.prepare()
    }

    /// Selection changed feedback (e.g., scrolling through options)
    func selectionChanged() {
        selection.selectionChanged()
        selection.prepare()
    }

    /// Success notification feedback (e.g., palette saved)
    func success() {
        notification.notificationOccurred(.success)
        notification.prepare()
    }

    /// Warning notification feedback
    func warning() {
        notification.notificationOccurred(.warning)
        notification.prepare()
    }

    /// Error notification feedback
    func error() {
        notification.notificationOccurred(.error)
        notification.prepare()
    }

    /// Prepare all generators for upcoming use
    func prepareAll() {
        impactLight.prepare()
        impactMedium.prepare()
        impactHeavy.prepare()
        selection.prepare()
        notification.prepare()
    }
}
