import SwiftUI

struct DeviceShell: View {
    @StateObject var store = TweakStore()

    var body: some View {
        GeometryReader { geo in
            let barHeight: CGFloat = store.classicHomeButton ? 86 : 0
            let contentHeight = geo.size.height - barHeight

            VStack(spacing: 0) {
                ZStack {
                    Color.black

                    ZStack {
                        if store.locked {
                            LockScreenView()
                                .transition(.asymmetric(insertion: .identity, removal: .move(edge: .top)))
                        } else {
                            HomeScreenView()
                                .scaleEffect(1 - (store.dragKind == .openSwitcher ? 0.07 * store.dragProgress : 0))

                            if let app = store.openedApp {
                                AppOverlayView(app: app).transition(.appLaunch)
                            }

                            if store.switcherOpen {
                                AppSwitcherView().transition(.opacity.combined(with: .scale(scale: 1.06)))
                            }
                        }
                    }
                    .environmentObject(store)
                    .frame(width: geo.size.width, height: contentHeight)
                    .scaleEffect(x: store.stretchX, y: store.stretchY, anchor: .center)
                    .clipped()
                    .overlay { if store.nightTint { Color.orange.opacity(0.10).allowsHitTesting(false) } }

                    EdgeSwipeLayer()
                        .environmentObject(store)
                        .frame(width: geo.size.width, height: contentHeight)
                        .scaleEffect(x: store.stretchX, y: store.stretchY, anchor: .center)

                    if store.dragKind == .lockFromTop {
                        Color.black.opacity(0.35 * store.dragProgress).allowsHitTesting(false)
                    }

                    if store.respringing {
                        RespringOverlay().transition(.opacity)
                    }
                }
                .frame(height: contentHeight)
                .clipped()

                if store.classicHomeButton {
                    ClassicHomeButtonBar().environmentObject(store).frame(height: barHeight)
                }
            }
        }
        .ignoresSafeArea()
    }
}

extension AnyTransition {
    static var appLaunch: AnyTransition {
        .modifier(active: AppLaunchModifier(progress: 0), identity: AppLaunchModifier(progress: 1))
    }
}

struct AppLaunchModifier: ViewModifier {
    let progress: Double
    func body(content: Content) -> some View {
        content
            .scaleEffect(0.84 + 0.16 * progress)
            .opacity(progress)
            .clipShape(RoundedRectangle(cornerRadius: (1 - progress) * 46, style: .continuous))
    }
}

/// Lives inside the same scaleEffect transform as everything else, so edge
/// positions follow the stretch. Only the TOP and BOTTOM strips are
/// hit-testable, so normal taps in the middle of the screen pass through.
struct EdgeSwipeLayer: View {
    @EnvironmentObject var store: TweakStore
    private let edgeZone: CGFloat = 46
    private let commitDistance: CGFloat = 90

    var body: some View {
        VStack {
            strip(isTop: true)
            Spacer()
            strip(isTop: false)
        }
        .allowsHitTesting(!store.locked && !store.switcherOpen)
    }

    private func strip(isTop: Bool) -> some View {
        Color.clear
            .frame(maxWidth: .infinity)
            .frame(height: edgeZone)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 8)
                    .onChanged { v in handle(v, isTop: isTop, ended: false) }
                    .onEnded { v in handle(v, isTop: isTop, ended: true) }
            )
    }

    private func handle(_ v: DragGesture.Value, isTop: Bool, ended: Bool) {
        if store.dragKind == nil {
            if isTop && v.translation.height > 6 {
                store.dragKind = .lockFromTop
            } else if !isTop && v.translation.height < -6 {
                store.dragKind = store.openedApp != nil ? .closeApp : .openSwitcher
            } else {
                return
            }
        }
        guard let kind = store.dragKind else { return }
        let raw = kind == .lockFromTop ? v.translation.height : -v.translation.height
        store.dragProgress = min(1, max(0, raw / commitDistance))

        if ended {
            if store.dragProgress > 0.42 {
                switch kind {
                case .closeApp: store.closeApp()
                case .openSwitcher: store.openSwitcher()
                case .lockFromTop: store.lockNow()
                }
            } else {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) { store.resetDrag() }
            }
        }
    }
}

struct AppOverlayView: View {
    @EnvironmentObject var store: TweakStore
    let app: OpenApp

    var body: some View {
        let closing = store.dragKind == .closeApp
        let progress: Double = closing ? Double(store.dragProgress) : 0

        Group {
            switch app.kind {
            case .browser: BrowserView()
            case .settings: SettingsView()
            case .animashki: AnimashkiView()
            case .placeholder: PlaceholderAppView(icon: app.icon, label: app.label)
            }
        }
        .scaleEffect(1 - 0.12 * progress)
        .clipShape(RoundedRectangle(cornerRadius: progress * 40, style: .continuous))
        .offset(y: 50 * progress)
        .opacity(1 - 0.25 * progress)
    }
}

struct PlaceholderAppView: View {
    let icon: String
    let label: String
    var body: some View {
        ZStack {
            LinearGradient(colors: [.black, .blue.opacity(0.3)], startPoint: .top, endPoint: .bottom).ignoresSafeArea()
            VStack(spacing: 14) {
                Image(systemName: icon).font(.system(size: 70)).foregroundStyle(.white)
                Text(label).font(.title2).bold().foregroundStyle(.white)
                Text("swipe up from the bottom edge to go back").font(.caption).foregroundStyle(.white.opacity(0.5))
            }
        }
    }
}

struct ClassicHomeButtonBar: View {
    @EnvironmentObject var store: TweakStore
    @State private var pressed = false

    var body: some View {
        ZStack {
            Color.black
            Circle()
                .strokeBorder(.white.opacity(0.6), lineWidth: 2)
                .background(Circle().fill(pressed ? Color.white.opacity(0.15) : Color.clear))
                .frame(width: 54, height: 54)
                .scaleEffect(pressed ? 0.9 : 1)
                .onTapGesture { store.homeButtonTap() }
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in pressed = true }
                        .onEnded { _ in pressed = false }
                )
        }
        .animation(.easeOut(duration: 0.12), value: pressed)
    }
}

struct RespringOverlay: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 16) {
                ProgressView().tint(.white).scaleEffect(1.8)
                Text("Respringing…").foregroundStyle(.white.opacity(0.7)).font(.footnote)
            }
        }
    }
}
