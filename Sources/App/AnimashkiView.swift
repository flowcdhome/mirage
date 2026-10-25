import SwiftUI

struct AnimashkiView: View {
    @State private var pulse = false
    var body: some View {
        ZStack {
            LinearGradient(colors: [.pink.opacity(0.5), .purple.opacity(0.6), .black],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            Text("Анимашки^^")
                .font(.system(size: 54, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
                .scaleEffect(pulse ? 1.08 : 0.96)
                .shadow(color: .pink.opacity(0.6), radius: pulse ? 22 : 8)
                .animation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true), value: pulse)
                .onAppear { pulse = true }
        }
    }
}
