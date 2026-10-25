import SwiftUI

/// A cute animated clock face: two round "eyes" whose hands show the time,
/// blinking every few seconds. Original art, not based on any specific show.
struct AniTimeClockView: View {
    @State private var now = Date()
    @State private var blink = false
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack(spacing: 18) {
            eye(angleSource: .hour)
            eye(angleSource: .minute)
        }
        .onReceive(timer) { now = $0 }
        .task { await blinkLoop() }
    }

    private enum Source { case hour, minute }

    private func eye(angleSource: Source) -> some View {
        let cal = Calendar.current
        let h = CGFloat(cal.component(.hour, from: now) % 12)
        let m = CGFloat(cal.component(.minute, from: now))
        let angle: Angle = angleSource == .hour
            ? .degrees(Double(h / 12 * 360 + m / 60 * 30) - 90)
            : .degrees(Double(m / 60 * 360) - 90)

        return ZStack {
            Circle()
                .fill(.white.opacity(0.9))
                .frame(width: 54, height: blink ? 6 : 54)
            if !blink {
                Rectangle()
                    .fill(.black)
                    .frame(width: 3, height: 18)
                    .offset(y: -9)
                    .rotationEffect(angle + .degrees(90))
                Circle().fill(.black).frame(width: 6, height: 6)
            }
        }
        .animation(.easeInOut(duration: 0.12), value: blink)
    }

    private func blinkLoop() async {
        while !Task.isCancelled {
            try? await Task.sleep(nanoseconds: UInt64.random(in: 2_500_000_000...5_000_000_000))
            blink = true
            try? await Task.sleep(nanoseconds: 140_000_000)
            blink = false
        }
    }
}
