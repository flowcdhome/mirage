import SwiftUI

/// Original chibi-style vector characters, each holding one digit of the
/// time. Built entirely from SwiftUI shapes (no imported art, no copied
/// character designs) - a from-scratch take on "characters as clock digits".
struct AniTimeClockView: View {
    @State private var now = Date()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private let palettes: [(hair: Color, outfit: Color)] = [
        (.pink, .purple), (.orange, .red), (.mint, .teal), (.cyan, .blue)
    ]

    var body: some View {
        let comps = Calendar.current.dateComponents([.hour, .minute], from: now)
        let h = comps.hour ?? 0
        let m = comps.minute ?? 0
        let digits = Array(String(format: "%02d%02d", h, m))

        HStack(spacing: 8) {
            ForEach(Array(digits.enumerated()), id: \.offset) { idx, d in
                ChibiCharacter(palette: palettes[idx % palettes.count], digit: d, phase: Double(idx) * 0.25)
                if idx == 1 { colonDots }
            }
        }
        .onReceive(timer) { now = $0 }
    }

    private var colonDots: some View {
        VStack(spacing: 6) {
            Circle().fill(.white.opacity(0.8)).frame(width: 5, height: 5)
            Circle().fill(.white.opacity(0.8)).frame(width: 5, height: 5)
        }
    }
}

private struct ChibiCharacter: View {
    let palette: (hair: Color, outfit: Color)
    let digit: Character
    let phase: Double
    @State private var blink = false
    @State private var bob = false

    var body: some View {
        VStack(spacing: -4) {
            ZStack {
                HStack(spacing: -12) {
                    HairSpike().fill(palette.hair).frame(width: 16, height: 24).rotationEffect(.degrees(-16))
                    HairSpike().fill(palette.hair).frame(width: 16, height: 24).rotationEffect(.degrees(16)).scaleEffect(x: -1, y: 1)
                }
                .offset(y: -22)

                Circle()
                    .fill(Color(white: 0.96))
                    .frame(width: 34, height: 34)

                HStack(spacing: 8) {
                    eyeView
                    eyeView
                }
                .offset(y: 1)

                HStack(spacing: 22) {
                    Circle().fill(palette.hair.opacity(0.35)).frame(width: 5, height: 5)
                    Circle().fill(palette.hair.opacity(0.35)).frame(width: 5, height: 5)
                }
                .offset(y: 8)
            }

            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(palette.outfit)
                    .frame(width: 30, height: 18)
                    .offset(y: 12)
                RoundedRectangle(cornerRadius: 4)
                    .fill(.white)
                    .frame(width: 24, height: 24)
                    .overlay(
                        Text(String(digit))
                            .font(.system(size: 15, weight: .black, design: .rounded))
                            .foregroundStyle(.black)
                    )
                    .shadow(radius: 1)
                    .offset(y: 4)
            }
        }
        .offset(y: bob ? -3 : 3)
        .task { await bobLoop() }
        .task { await blinkLoop() }
    }

    private var eyeView: some View {
        Capsule()
            .fill(.black)
            .frame(width: 4, height: blink ? 1 : 7)
            .animation(.easeInOut(duration: 0.1), value: blink)
    }

    private func bobLoop() async {
        try? await Task.sleep(nanoseconds: UInt64(phase * 1_000_000_000))
        while !Task.isCancelled {
            withAnimation(.easeInOut(duration: 1.1)) { bob.toggle() }
            try? await Task.sleep(nanoseconds: 1_100_000_000)
        }
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

private struct HairSpike: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.midX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        p.closeSubpath()
        return p
    }
}
