import SwiftUI

struct AppSwitcherView: View {
    @EnvironmentObject var store: TweakStore
    @State private var dismissOffset: CGFloat = 0

    var body: some View {
        ZStack {
            Color.black.opacity(0.92).ignoresSafeArea()
            VStack(spacing: 16) {
                Spacer()
                if let app = store.openedApp {
                    card(for: app)
                } else {
                    Text("No open apps").foregroundStyle(.white.opacity(0.5))
                }
                Spacer()
                Text("tap a card to open it, swipe it up to close it")
                    .font(.caption).foregroundStyle(.white.opacity(0.4))
                    .padding(.bottom, 24)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { store.closeSwitcher() }
    }

    private func card(for app: OpenApp) -> some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: app.icon)
                Text(app.label)
            }
            .foregroundStyle(.white.opacity(0.8))
            .font(.caption)

            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.ultraThinMaterial)
                .frame(width: 220, height: 400)
                .overlay(Image(systemName: app.icon).font(.system(size: 50)).foregroundStyle(.white.opacity(0.4)))
                .offset(y: dismissOffset)
                .opacity(1 - Double(min(1, abs(dismissOffset) / 260)))
                .gesture(
                    DragGesture()
                        .onChanged { v in if v.translation.height < 0 { dismissOffset = v.translation.height } }
                        .onEnded { v in
                            if v.translation.height < -120 {
                                store.closeApp()
                            } else {
                                withAnimation(.spring) { dismissOffset = 0 }
                            }
                        }
                )
                .onTapGesture { store.closeSwitcher() }
        }
    }
}
