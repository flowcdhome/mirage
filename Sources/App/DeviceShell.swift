import SwiftUI

/// The whole fake-OS surface. The stretch transform is applied here, to
/// content that ALSO carries the gestures (unlock swipe, exit-app swipe),
/// so every gesture's hit zone follows the visually stretched edges, not
/// the real physical screen edges.
struct DeviceShell: View {
    @StateObject var store = TweakStore()

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black.ignoresSafeArea()

                ZStack {
                    if store.locked {
                        LockScreenView()
                            .transition(.asymmetric(insertion: .identity, removal: .move(edge: .top)))
                    } else {
                        HomeScreenView()
                            .transition(.opacity.combined(with: .scale(scale: 1.04)))

                        if let app = store.openedApp {
                            AppOverlayView(kind: app.kind, icon: app.icon, label: app.label)
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                    }
                }
                .environmentObject(store)
                .frame(width: geo.size.width, height: geo.size.height)
                .scaleEffect(x: store.stretchX, y: store.stretchY, anchor: .center)
                .clipped()
                .overlay { if store.nightTint { Color.orange.opacity(0.10).allowsHitTesting(false) } }

                if store.respringing {
                    RespringOverlay().transition(.opacity)
                }
            }
        }
        .ignoresSafeArea()
        .sheet(isPresented: $store.settingsOpen) {
            SettingsView().environmentObject(store)
        }
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

/// Fullscreen "app" shown over the home screen. Swipe up starting near the
/// bottom edge of THIS view's own (pre-stretch) frame closes it - since this
/// view lives inside DeviceShell's scaleEffect, that edge visually sits
/// wherever the stretch currently puts it, exactly like a real home-indicator
/// swipe would, but tied to the stretched content instead of the real screen.
struct AppOverlayView: View {
    @EnvironmentObject var store: TweakStore
    let kind: AppKind
    let icon: String
    let label: String
    @State private var dragOffset: CGFloat = 0
    @State private var closing = false

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                Group {
                    if kind == .browser {
                        BrowserView()
                    } else {
                        PlaceholderAppView(icon: icon, label: label)
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height)

                // Invisible edge-zone at the bottom of this view's local frame.
                Color.clear
                    .frame(height: 44)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 4)
                            .onChanged { v in
                                guard v.startLocation.y > geo.size.height - 60 else { return }
                                dragOffset = min(0, -v.translation.height) * -1
                                dragOffset = max(-min(v.translation.height, 0), 0)
                            }
                            .onEnded { v in
                                let startedAtEdge = v.startLocation.y > geo.size.height - 60
                                if startedAtEdge && -v.translation.height > 70 {
                                    store.closeApp()
                                } else {
                                    withAnimation(.spring) { dragOffset = 0 }
                                }
                            }
                    )
            }
            .offset(y: -dragOffset * 0.4)
            .scaleEffect(1 - min(dragOffset / 800, 0.08))
        }
    }
}

struct PlaceholderAppView: View {
    let icon: String
    let label: String
    var body: some View {
        ZStack {
            LinearGradient(colors: [.black, .blue.opacity(0.3)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            VStack(spacing: 14) {
                Image(systemName: icon).font(.system(size: 70)).foregroundStyle(.white)
                Text(label).font(.title2).bold().foregroundStyle(.white)
                Text("swipe up from the bottom edge to go back").font(.caption).foregroundStyle(.white.opacity(0.5))
            }
        }
    }
}
