import SwiftUI

struct Tweak: Identifiable {
    let id = UUID()
    let name: String
    let author: String
    let summary: String
    let icon: String
}

let catalog: [Tweak] = [
    Tweak(name: "RoundSpring", author: "mirage team", summary: "Rounder icons on the home screen.", icon: "app.badge"),
    Tweak(name: "NightTint", author: "mirage team", summary: "Warm color overlay across the UI.", icon: "moon.stars.fill"),
    Tweak(name: "HapticBoost", author: "mirage team", summary: "Extra haptic feedback on every tap.", icon: "waveform.path"),
    Tweak(name: "JailbreakBadge", author: "mirage team", summary: "Cosmetic 'jailbroken' badge in the status bar. Not real.", icon: "checkmark.seal.fill"),
    Tweak(name: "NeonAccent", author: "mirage team", summary: "Neon accent color across the fake OS.", icon: "paintpalette.fill"),
    Tweak(name: "WiggleMode", author: "mirage team", summary: "Long-press the home screen to jiggle icons.", icon: "hand.tap.fill"),
]

final class TweakStore: ObservableObject {
    @Published var enabled: Set<UUID> = []
    @Published var stretchX: CGFloat = 1.0
    @Published var stretchY: CGFloat = 1.0
    @Published var locked = true
    @Published var respringing = false
    @Published var settingsOpen = false
    @Published var editMode = false

    var roundIcons: Bool { isOn("RoundSpring") }
    var nightTint: Bool { isOn("NightTint") }
    var hapticBoost: Bool { isOn("HapticBoost") }
    var badge: Bool { isOn("JailbreakBadge") }
    var neon: Bool { isOn("NeonAccent") }
    var wiggleEnabled: Bool { isOn("WiggleMode") }

    var accent: Color { neon ? Color(red: 0.6, green: 1, blue: 0.3) : .blue }

    private func isOn(_ name: String) -> Bool {
        guard let t = catalog.first(where: { $0.name == name }) else { return false }
        return enabled.contains(t.id)
    }

    func toggle(_ t: Tweak) {
        if enabled.contains(t.id) { enabled.remove(t.id) } else { enabled.insert(t.id) }
        haptic(.medium)
    }

    func haptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        guard hapticBoost || style == .light else { return }
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }

    func snapStretch43() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
            stretchX = 1.0
            stretchY = 4.0 / 3.0
        }
    }

    func resetStretch() {
        withAnimation(.spring) { stretchX = 1.0; stretchY = 1.0 }
    }

    func unlock() {
        haptic(.light)
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) { locked = false }
    }

    func respring() {
        editMode = false
        settingsOpen = false
        withAnimation(.easeInOut(duration: 0.3)) { respringing = true }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            withAnimation(.easeInOut(duration: 0.3)) {
                self.respringing = false
                self.locked = true
            }
        }
    }
}
