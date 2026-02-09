import SwiftUI
import Combine

struct MoodLoadingScreen: View {

    @State private var appear: Bool = false
    @State private var flip: Double = 0
    @State private var breathe: Bool = false
    @State private var drift: CGFloat = 0
    @State private var shimmer: CGFloat = 0

    var body: some View {
        ZStack {
            background
                .ignoresSafeArea()

            bookDust
                .ignoresSafeArea()
                .allowsHitTesting(false)

            VStack {
                Spacer()

                BookLoaderCore(flip: flip, breathe: breathe, shimmer: shimmer)
                    .frame(width: 240, height: 240)

                Text("Loading")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(Color.white.opacity(0.88))
                    .opacity(appear ? 1 : 0)
                    .animation(.easeOut(duration: 0.35), value: appear)

                Spacer()
            }
            .padding(.bottom, 12)
        }
        .onAppear {
            appear = true

            withAnimation(.linear(duration: 2.1).repeatForever(autoreverses: false)) {
                flip = 360
            }
            withAnimation(.easeInOut(duration: 1.3).repeatForever(autoreverses: true)) {
                breathe = true
            }
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                drift = 1
            }
            withAnimation(.linear(duration: 2.4).repeatForever(autoreverses: false)) {
                shimmer = 1
            }
        }
    }

    private var background: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            ZStack {
                Color.black

                RadialGradient(
                    colors: [
                        Color.white.opacity(0.06),
                        Color.clear
                    ],
                    center: .topLeading,
                    startRadius: 10,
                    endRadius: max(w, h) * 0.70
                )
                .offset(x: -w * 0.08, y: -h * 0.06)

                RadialGradient(
                    colors: [
                        Color.white.opacity(0.05),
                        Color.clear
                    ],
                    center: .bottomTrailing,
                    startRadius: 10,
                    endRadius: max(w, h) * 0.80
                )
                .offset(x: w * 0.06, y: h * 0.08)

                LinearGradient(
                    colors: [
                        Color.white.opacity(0.05),
                        Color.clear,
                        Color.white.opacity(0.035)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .opacity(0.9)
            }
        }
    }

    private var bookDust: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ZStack {
                ForEach(0..<22, id: \.self) { i in
                    let t = Double(i) / 22.0
                    let x = w * (0.12 + CGFloat(t) * 0.76)
                    let y = h * (0.18 + CGFloat((i % 7)) * 0.11)
                    let s = 1.0 + CGFloat(i % 4) * 0.15
                    let o = 0.10 + Double(i % 5) * 0.03

                    DustGlyph(index: i, flip: flip, drift: drift)
                        .position(x: x, y: y)
                        .scaleEffect(s)
                        .opacity(o)
                }
            }
        }
        .blendMode(.screen)
    }
}

private struct BookLoaderCore: View {

    let flip: Double
    let breathe: Bool
    let shimmer: CGFloat

    var body: some View {
        GeometryReader { geo in
            let side = min(geo.size.width, geo.size.height)
            let c = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)

            ZStack {
                // soft halo
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.white.opacity(0.10),
                                Color.white.opacity(0.04),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 8,
                            endRadius: side * 0.56
                        )
                    )
                    .frame(width: side, height: side)
                    .position(c)
                    .scaleEffect(breathe ? 1.05 : 0.96)
                    .blur(radius: 16)
                    .blendMode(.screen)
                    .animation(.easeInOut(duration: 1.35).repeatForever(autoreverses: true), value: breathe)

                // orbiting "letters"
                ForEach(0..<14, id: \.self) { i in
                    OrbitGlyph(index: i, flip: flip)
                        .position(c)
                }

                // the book
                OpenBook(flip: flip, breathe: breathe, shimmer: shimmer)
                    .frame(width: side * 0.62, height: side * 0.46)
                    .position(c)
            }
        }
        .allowsHitTesting(false)
    }
}

private struct OpenBook: View {

    let flip: Double
    let breathe: Bool
    let shimmer: CGFloat

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ZStack {
                // book shadow
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.black.opacity(0.55))
                    .frame(width: w * 0.96, height: h * 0.86)
                    .offset(y: h * 0.06)
                    .blur(radius: 18)

                // spine
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.white.opacity(0.10))
                    .frame(width: w * 0.06, height: h * 0.82)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(Color.white.opacity(0.12), lineWidth: 1)
                    )

                // left page
                page(isLeft: true, w: w, h: h)
                    .offset(x: -w * 0.16)

                // right page
                page(isLeft: false, w: w, h: h)
                    .offset(x: w * 0.16)

                // flipping page (thin sheet)
                flippingPage(w: w, h: h)
                    .offset(x: w * 0.03)
                    .rotation3DEffect(
                        .degrees(pageAngle(from: flip)),
                        axis: (x: 0, y: 1, z: 0),
                        anchor: .leading,
                        perspective: 0.65
                    )
                    .opacity(0.95)

                // bookmark ribbon
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(Color.white.opacity(0.22))
                    .frame(width: w * 0.10, height: h * 0.56)
                    .offset(x: w * 0.26, y: -h * 0.05)
                    .rotationEffect(.degrees(breathe ? 2.5 : -2.5))
                    .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: breathe)

                // shimmer sweep
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.clear,
                                Color.white.opacity(0.12),
                                Color.clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: w * 0.50, height: h * 0.95)
                    .rotationEffect(.degrees(22))
                    .offset(x: (shimmer * 1.8 - 0.9) * w)
                    .blendMode(.screen)
                    .mask(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .frame(width: w, height: h)
                    )
                    .opacity(0.55)
            }
            .scaleEffect(breathe ? 1.02 : 0.98)
            .animation(.easeInOut(duration: 1.35).repeatForever(autoreverses: true), value: breathe)
        }
    }

    private func page(isLeft: Bool, w: CGFloat, h: CGFloat) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.10))
                .frame(width: w * 0.42, height: h * 0.82)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.white.opacity(0.16), lineWidth: 1)
                )

            VStack(spacing: h * 0.06) {
                ForEach(0..<5, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                        .fill(Color.white.opacity(0.14))
                        .frame(width: w * (isLeft ? 0.30 : 0.28), height: 4)
                        .opacity(0.8 - Double(i) * 0.08)
                }
            }
            .offset(y: -h * 0.04)
        }
        .blur(radius: 0.2)
    }

    private func flippingPage(w: CGFloat, h: CGFloat) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.06))
                .frame(width: w * 0.40, height: h * 0.80)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )

            VStack(spacing: h * 0.07) {
                ForEach(0..<4, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                        .fill(Color.white.opacity(0.12))
                        .frame(width: w * 0.26, height: 4)
                        .opacity(0.75 - Double(i) * 0.10)
                }
            }
            .offset(y: -h * 0.03)
        }
        .shadow(color: Color.black.opacity(0.35), radius: 14, x: 0, y: 10)
    }

    private func pageAngle(from spin: Double) -> Double {
        let t = (spin.truncatingRemainder(dividingBy: 360)) / 360.0
        // 0..1 => triangle-ish wave for page flip
        let wave = 1.0 - abs(2.0 * t - 1.0) // 0..1..0
        return -110.0 + wave * 140.0 // -110..30..-110
    }
}

private struct OrbitGlyph: View {

    let index: Int
    let flip: Double

    var body: some View {
        let count = 14.0
        let base = Double(index) / count * 360.0
        let angle = (base + flip) * .pi / 180.0

        let radius = 82.0 + Double(index % 4) * 12.0
        let x = cos(angle) * radius
        let y = sin(angle) * radius

        return RoundedRectangle(cornerRadius: 2.2, style: .continuous)
            .fill(Color.white.opacity(0.22))
            .frame(width: 7, height: 3)
            .offset(x: x, y: y)
            .rotationEffect(.degrees(base + flip))
            .blur(radius: 0.2)
            .opacity(0.85)
    }
}

private struct DustGlyph: View {

    let index: Int
    let flip: Double
    let drift: CGFloat

    var body: some View {
        let phase = (Double(index) * 19.0 + flip).truncatingRemainder(dividingBy: 360)
        let a = phase * .pi / 180.0

        let dx = CGFloat(cos(a)) * 18 * drift
        let dy = CGFloat(sin(a * 0.8)) * 12 * drift

        return RoundedRectangle(cornerRadius: 2.0, style: .continuous)
            .fill(Color.white.opacity(0.16))
            .frame(width: (index % 3 == 0) ? 10 : 7, height: 3)
            .offset(x: dx, y: dy)
            .rotationEffect(.degrees(phase))
            .blur(radius: 0.4)
    }
}
