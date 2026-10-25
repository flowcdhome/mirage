import SwiftUI

struct HomeApp: Identifiable {
    let id = UUID()
    let icon: String
    let label: String
    let kind: AppKind
}

struct HomeScreenView: View {
    @EnvironmentObject var store: TweakStore

    let apps: [HomeApp] = [
        HomeApp(icon: "safari.fill", label: "Browser", kind: .browser),
        HomeApp(icon: "sparkles", label: "Анимашки", kind: .animashki),
        HomeApp(icon: "message.fill", label: "Messages", kind: .placeholder),
        HomeApp(icon: "camera.fill", label: "Camera", kind: .placeholder),
        HomeApp(icon: "music.note", label: "Music", kind: .placeholder),
        HomeApp(icon: "gamecontroller.fill", label: "Games", kind: .placeholder),
        HomeApp(icon: "map.fill", label: "Maps", kind: .placeholder),
        HomeApp(icon: "cart.fill", label: "Store", kind: .placeholder),
        HomeApp(icon: "calendar", label: "Calendar", kind: .placeholder),
        HomeApp(icon: "photo.stack.fill", label: "Photos", kind: .placeholder),
        HomeApp(icon: "envelope.fill", label: "Mail", kind: .placeholder),
        HomeApp(icon: "cloud.sun.fill", label: "Weather", kind: .placeholder),
        HomeApp(icon: "gearshape.fill", label: "Settings", kind: .settings),
    ]
    let dockIcons = ["phone.fill", "wrench.and.screwdriver.fill", "gearshape.fill"]
    let cols = Array(repeating: GridItem(.flexible(), spacing: 22), count: 4)

    var body: some View {
        ZStack {
            LinearGradient(colors: store.neon ? [.black, .green.opacity(0.25)] : [.black, .blue.opacity(0.25)],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                statusBar
                ScrollView {
                    LazyVGrid(columns: cols, spacing: 26) {
                        ForEach(apps) { a in appIcon(a) }
                    }
                    .padding()
                }
                HStack(spacing: 22) {
                    ForEach(dockIcons, id: \.self) { name in
                        Image(systemName: name)
                            .font(.title2)
                            .frame(width: 50, height: 50)
                            .foregroundStyle(.white)
                            .background(store.iconFill, in: RoundedRectangle(cornerRadius: store.roundIcons ? 16 : 6))
                    }
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

    // Approximation of a modern, Dynamic-Island-style status bar. I don't
    // have verified details of iOS 27's exact visual redesign, so treat
    // this as a stylistic guess, not a precise match.
    private var statusBar: some View {
        ZStack {
            HStack {
                Text(Date(), format: .dateTime.hour().minute()).font(.caption).bold()
                Spacer()
                if store.badge {
                    Image(systemName: "checkmark.seal.fill").font(.caption2).foregroundStyle(.green)
                }
                Image(systemName: "wifi"); Image(systemName: "battery.75")
            }
            Capsule().fill(.black).frame(width: 110, height: 28)
        }
        .foregroundStyle(.white)
        .padding(.horizontal).padding(.top, 14).padding(.bottom, 10)
    }

    private func appIcon(_ a: HomeApp) -> some View {
        Button {
            store.openApp(kind: a.kind, icon: a.icon, label: a.label)
        } label: {
            VStack(spacing: 4) {
                Image(systemName: a.icon)
                    .font(.title2)
                    .frame(width: 54, height: 54)
                    .foregroundStyle(.white)
                    .background(store.iconFill, in: RoundedRectangle(cornerRadius: store.roundIcons ? 16 : 6))
                    .rotationEffect(.degrees(store.editMode ? wiggleAngle() : 0))
                    .animation(store.editMode ? .easeInOut(duration: 0.14).repeatForever(autoreverses: true) : .default,
                               value: store.editMode)
                Text(a.label).font(.caption2).foregroundStyle(.white.opacity(0.8))
            }
        }
    }

    private func wiggleAngle() -> Double { Bool.random() ? 2.2 : -2.2 }
}
