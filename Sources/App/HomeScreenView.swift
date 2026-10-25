import SwiftUI

struct HomeScreenView: View {
    @EnvironmentObject var store: TweakStore
    let appIcons = ["message.fill", "camera.fill", "music.note", "gamecontroller.fill",
                    "map.fill", "cart.fill", "calendar", "photo.stack.fill",
                    "safari.fill", "envelope.fill", "clock.fill", "cloud.sun.fill"]
    let dockIcons = ["phone.fill", "wrench.and.screwdriver.fill", "gearshape.fill"]
    let cols = Array(repeating: GridItem(.flexible(), spacing: 22), count: 4)

    var body: some View {
        ZStack {
            LinearGradient(colors: store.neon ? [.black, .green.opacity(0.25)] : [.black, .blue.opacity(0.25)],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Text(Date(), format: .dateTime.hour().minute()).font(.caption).bold()
                    Spacer()
                    if store.badge {
                        Image(systemName: "checkmark.seal.fill").font(.caption).foregroundStyle(.green)
                    }
                    Image(systemName: "wifi"); Image(systemName: "battery.75")
                }
                .foregroundStyle(.white)
                .padding(.horizontal).padding(.top, 14).padding(.bottom, 6)

                ScrollView {
                    LazyVGrid(columns: cols, spacing: 26) {
                        ForEach(appIcons, id: \.self) { icon(for: $0) }
                        icon(for: "wrench.and.screwdriver.fill", isSettingsLike: true, label: "Tweaks")
                        icon(for: "gearshape.fill", isSettings: true, label: "Settings")
                    }
                    .padding()
                }

                HStack(spacing: 22) {
                    ForEach(dockIcons, id: \.self) { icon(for: $0, inDock: true) }
                }
                .padding(.vertical, 14)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28))
                .padding(.horizontal, 24)
                .padding(.bottom, 18)
            }
        }
        .onLongPressGesture(minimumDuration: 0.5) {
            guard store.wiggleEnabled else { return }
            store.haptic(.medium)
            withAnimation { store.editMode.toggle() }
        }
    }

    @ViewBuilder
    private func icon(for name: String, isSettings: Bool = false, isSettingsLike: Bool = false,
                       inDock: Bool = false, label: String? = nil) -> some View {
        Button {
            store.haptic(.light)
            if isSettings || isSettingsLike { store.settingsOpen = true }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: name)
                    .font(.title2)
                    .frame(width: inDock ? 50 : 54, height: inDock ? 50 : 54)
                    .foregroundStyle(.white)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: store.roundIcons ? 16 : 6))
                    .rotationEffect(.degrees(store.editMode && !inDock ? wiggleAngle() : 0))
                    .animation(store.editMode ? .easeInOut(duration: 0.14).repeatForever(autoreverses: true) : .default,
                               value: store.editMode)
                if let label, !inDock {
                    Text(label).font(.caption2).foregroundStyle(.white.opacity(0.8))
                }
            }
        }
    }

    private func wiggleAngle() -> Double { Bool.random() ? 2.2 : -2.2 }
}
