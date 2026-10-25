import SwiftUI

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
                    }
                }
                .environmentObject(store)
                .frame(width: geo.size.width, height: geo.size.height)
                .scaleEffect(x: store.stretchX, y: store.stretchY, anchor: .center)
                .clipped()
                .overlay { if store.nightTint { Color.orange.opacity(0.10).allowsHitTesting(false) } }

                if store.respringing {
                    RespringOverlay().environmentObject(store)
                        .transition(.opacity)
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
    @EnvironmentObject var store: TweakStore
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
