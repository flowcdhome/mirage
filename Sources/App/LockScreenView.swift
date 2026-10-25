import SwiftUI

struct LockScreenView: View {
    @EnvironmentObject var store: TweakStore
    @State private var now = Date()
    @State private var dragY: CGFloat = 0
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            LinearGradient(colors: store.neon
                            ? [.black, Color(red: 0.05, green: 0.2, blue: 0.1)]
                            : [Color(red: 0.05, green: 0.05, blue: 0.15), .black],
                            startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack {
                Spacer()
                Text(now, format: .dateTime.hour().minute())
                    .font(.system(size: 76, weight: .thin))
                    .foregroundStyle(.white)
                Text(now, format: .dateTime.weekday(.wide).day().month(.wide))
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.7))
                if store.badge {
                    Label("jailbroken™ (not really)", systemImage: "checkmark.seal.fill")
                        .font(.caption2).foregroundStyle(.green).padding(.top, 6)
                }
                Spacer()
                VStack(spacing: 6) {
                    Image(systemName: "chevron.up")
                        .font(.title2).foregroundStyle(.white.opacity(0.6))
                        .offset(y: -dragY * 0.2)
                    Text("swipe up to unlock")
                        .font(.caption).foregroundStyle(.white.opacity(0.5))
                }
                .padding(.bottom, 40)
            }
        }
        .contentShape(Rectangle())
        .gesture(
            DragGesture()
                .onChanged { v in dragY = max(0, -v.translation.height) }
                .onEnded { v in
                    if -v.translation.height > 80 { store.unlock() }
                    withAnimation(.spring) { dragY = 0 }
                }
        )
        .onTapGesture(count: 2) { store.unlock() }
        .onReceive(timer) { now = $0 }
    }
}
