import SwiftUI

@main
struct DynamicWeatherAnimationApp: App {
    var body: some Scene {
        WindowGroup {
            DynamicWeatherDemo()
                .frame(minWidth: 430, minHeight: 760)
        }
    }
}

struct DynamicWeatherDemo: View {
    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 60.0)) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            let phase = WeatherPhase(time: time)

            ZStack {
                StormGradient(phase: phase)
                    .ignoresSafeArea()

                AmbientGlow(phase: phase)
                    .ignoresSafeArea()

                FloatingCloudField(phase: phase)
                    .ignoresSafeArea()

                RainField(phase: phase)
                    .ignoresSafeArea()

                LightningLayer(phase: phase)
                    .ignoresSafeArea()

                VStack(spacing: 28) {
                    Spacer(minLength: 42)

                    WeatherCard(phase: phase)
                        .padding(.horizontal, 28)

                    MiniForecastStrip(phase: phase)
                        .padding(.horizontal, 34)

                    Spacer(minLength: 52)
                }
            }
            .preferredColorScheme(.dark)
        }
    }
}

struct WeatherPhase {
    let time: TimeInterval

    private var cyclePosition: Double {
        time.truncatingRemainder(dividingBy: 18) / 18
    }

    var storm: Double {
        let wave = (sin((cyclePosition * .pi * 2) - 0.8) + 1) / 2
        return smoothstep(wave)
    }

    var wind: Double {
        0.5 + sin(time * 0.55) * 0.5
    }

    var temperature: Int {
        Int((24 - storm * 8 + sin(time * 0.8) * 1.6).rounded())
    }

    var condition: String {
        storm > 0.78 ? "Thunderstorm" : storm > 0.42 ? "Heavy rain" : "Passing showers"
    }

    var lightning: Double {
        let strike = time.truncatingRemainder(dividingBy: 5.8)
        let first = flash(strike, center: 0.22, width: 0.035)
        let second = flash(strike, center: 0.38, width: 0.028) * 0.75
        return max(first, second) * smoothstep(max(0, (storm - 0.52) / 0.48))
    }

    var rainOpacity: Double {
        0.42 + storm * 0.48
    }

    var cloudLift: Double {
        sin(time * 0.7) * 8
    }

    private func flash(_ value: Double, center: Double, width: Double) -> Double {
        let distance = abs(value - center)
        guard distance < width else { return 0 }
        return pow(1 - distance / width, 2)
    }
}

func smoothstep(_ value: Double) -> Double {
    let x = min(max(value, 0), 1)
    return x * x * (3 - 2 * x)
}

struct StormGradient: View {
    let phase: WeatherPhase

    var body: some View {
        LinearGradient(
            colors: [
                Color.mix(Color(red: 0.13, green: 0.20, blue: 0.39), Color(red: 0.05, green: 0.07, blue: 0.13), phase.storm),
                Color.mix(Color(red: 0.17, green: 0.33, blue: 0.52), Color(red: 0.07, green: 0.10, blue: 0.18), phase.storm),
                Color.mix(Color(red: 0.54, green: 0.65, blue: 0.72), Color(red: 0.18, green: 0.19, blue: 0.24), phase.storm),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(
            LinearGradient(
                colors: [
                    Color.white.opacity(phase.lightning * 0.62),
                    Color.clear,
                    Color(red: 0.42, green: 0.48, blue: 0.78).opacity(phase.lightning * 0.32),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

struct AmbientGlow: View {
    let phase: WeatherPhase

    var body: some View {
        ZStack {
            Circle()
                .fill(Color(red: 0.25, green: 0.66, blue: 0.92).opacity(0.22 - phase.storm * 0.08))
                .frame(width: 360, height: 360)
                .blur(radius: 68)
                .offset(x: -120 + phase.wind * 28, y: -260 + phase.cloudLift)

            Circle()
                .fill(Color(red: 0.65, green: 0.46, blue: 1.0).opacity(0.18 + phase.lightning * 0.22))
                .frame(width: 290, height: 290)
                .blur(radius: 58)
                .offset(x: 150 - phase.wind * 42, y: 120)
        }
    }
}

struct WeatherCard: View {
    let phase: WeatherPhase

    var body: some View {
        VStack(alignment: .leading, spacing: 28) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 7) {
                    Text("Cupertino")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.9))

                    Text(phase.condition)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.62))
                        .contentTransition(.opacity)
                }

                Spacer()

                Image(systemName: phase.storm > 0.72 ? "cloud.bolt.rain.fill" : "cloud.rain.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, Color(red: 0.78, green: 0.86, blue: 1.0), Color(red: 0.63, green: 0.74, blue: 1.0))
                    .font(.system(size: 40, weight: .semibold))
                    .scaleEffect(1 + phase.lightning * 0.1)
                    .shadow(color: .white.opacity(phase.lightning * 0.8), radius: 18)
            }

            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text("\(phase.temperature)")
                    .font(.system(size: 104, weight: .thin, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.white)
                    .contentTransition(.numericText(value: Double(phase.temperature)))

                Text("°")
                    .font(.system(size: 70, weight: .thin, design: .rounded))
                    .foregroundStyle(.white.opacity(0.82))
                    .offset(y: -10)
            }

            HStack(spacing: 14) {
                MetricPill(icon: "wind", label: "Wind", value: "\(Int(18 + phase.wind * 14)) km/h")
                MetricPill(icon: "humidity.fill", label: "Rain", value: "\(Int(68 + phase.storm * 28))%")
            }
        }
        .padding(28)
        .background {
            RoundedRectangle(cornerRadius: 38, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 38, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    .white.opacity(0.23 + phase.lightning * 0.28),
                                    .white.opacity(0.06),
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 38, style: .continuous)
                        .stroke(.white.opacity(0.18 + phase.lightning * 0.36), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.28), radius: 34, x: 0, y: 24)
        }
        .scaleEffect(1 + sin(phase.time * 0.7) * 0.012)
    }
}

struct MetricPill: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .frame(width: 19)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.56))
                Text(value)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .monospacedDigit()
            }
        }
        .foregroundStyle(.white.opacity(0.9))
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(.white.opacity(0.12), in: Capsule())
    }
}

struct MiniForecastStrip: View {
    let phase: WeatherPhase

    private let hours = ["Now", "8PM", "9PM", "10PM"]

    var body: some View {
        HStack(spacing: 12) {
            ForEach(Array(hours.enumerated()), id: \.offset) { index, hour in
                ForecastCell(
                    hour: hour,
                    icon: index == 2 && phase.storm > 0.55 ? "cloud.bolt.rain.fill" : "cloud.rain.fill",
                    temp: phase.temperature - index,
                    isActive: index == Int(phase.time / 4).quotientAndRemainder(dividingBy: 4).remainder
                )
            }
        }
    }
}

struct ForecastCell: View {
    let hour: String
    let icon: String
    let temp: Int
    let isActive: Bool

    var body: some View {
        VStack(spacing: 9) {
            Text(hour)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
            Image(systemName: icon)
                .font(.system(size: 21, weight: .semibold))
            Text("\(temp)°")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .monospacedDigit()
        }
        .foregroundStyle(.white.opacity(isActive ? 1 : 0.62))
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(.white.opacity(isActive ? 0.18 : 0.08), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .scaleEffect(isActive ? 1.04 : 1)
    }
}

struct FloatingCloudField: View {
    let phase: WeatherPhase

    private let clouds = [
        CloudSpec(width: 230, y: 102, speed: 28, delay: 0.0, opacity: 0.36),
        CloudSpec(width: 160, y: 210, speed: -20, delay: 0.36, opacity: 0.24),
        CloudSpec(width: 280, y: 555, speed: 18, delay: 0.64, opacity: 0.18),
    ]

    var body: some View {
        GeometryReader { proxy in
            ForEach(Array(clouds.enumerated()), id: \.offset) { index, cloud in
                let width = proxy.size.width + cloud.width * 2
                let progress = (phase.time * abs(cloud.speed) / width + cloud.delay).truncatingRemainder(dividingBy: 1)
                let direction = cloud.speed >= 0 ? progress : 1 - progress
                let x = -cloud.width + direction * width

                CloudShape()
                    .fill(.white.opacity(cloud.opacity + phase.lightning * 0.2))
                    .frame(width: cloud.width, height: cloud.width * 0.42)
                    .blur(radius: index == 2 ? 5 : 2)
                    .offset(x: x, y: cloud.y + phase.cloudLift * (index.isMultiple(of: 2) ? 1 : -0.8))
            }
        }
    }
}

struct CloudSpec {
    let width: CGFloat
    let y: CGFloat
    let speed: Double
    let delay: Double
    let opacity: Double
}

struct CloudShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let baseY = rect.maxY * 0.72

        path.move(to: CGPoint(x: rect.minX + rect.width * 0.08, y: baseY))
        path.addCurve(
            to: CGPoint(x: rect.minX + rect.width * 0.35, y: rect.minY + rect.height * 0.38),
            control1: CGPoint(x: rect.minX + rect.width * 0.08, y: rect.minY + rect.height * 0.42),
            control2: CGPoint(x: rect.minX + rect.width * 0.2, y: rect.minY + rect.height * 0.22)
        )
        path.addCurve(
            to: CGPoint(x: rect.minX + rect.width * 0.62, y: rect.minY + rect.height * 0.28),
            control1: CGPoint(x: rect.minX + rect.width * 0.42, y: rect.minY + rect.height * 0.03),
            control2: CGPoint(x: rect.minX + rect.width * 0.56, y: rect.minY + rect.height * 0.03)
        )
        path.addCurve(
            to: CGPoint(x: rect.minX + rect.width * 0.93, y: baseY),
            control1: CGPoint(x: rect.minX + rect.width * 0.82, y: rect.minY + rect.height * 0.18),
            control2: CGPoint(x: rect.minX + rect.width * 0.94, y: rect.minY + rect.height * 0.38)
        )
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.08, y: baseY))
        path.closeSubpath()
        return path
    }
}

struct RainField: View {
    let phase: WeatherPhase

    private let drops: [RainDrop] = RainDrop.makeDrops(count: 76)

    var body: some View {
        GeometryReader { proxy in
            Canvas { context, size in
                for drop in drops {
                    let fall = (phase.time * drop.speed + drop.delay).truncatingRemainder(dividingBy: 1)
                    let x = size.width * drop.x + sin(phase.time + drop.delay * 8) * 9
                    let y = size.height * fall
                    var path = Path()
                    path.move(to: CGPoint(x: x, y: y))
                    path.addLine(to: CGPoint(x: x - 10, y: y + drop.length))

                    context.stroke(
                        path,
                        with: .color(.white.opacity(phase.rainOpacity * 0.58)),
                        style: StrokeStyle(lineWidth: 1.25, lineCap: .round)
                    )
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .blendMode(.screen)
        }
    }
}

struct RainDrop {
    let x: Double
    let delay: Double
    let length: Double
    let speed: Double

    static func makeDrops(count: Int) -> [RainDrop] {
        (0..<count).map { index in
            let x = Double((index * 37) % 100) / 100
            let delay = Double((index * 19) % 100) / 100
            let length = Double(18 + (index * 7) % 18)
            let speed = 0.7 + Double((index * 11) % 20) / 30

            return RainDrop(x: x, delay: delay, length: length, speed: speed)
        }
    }
}

struct LightningLayer: View {
    let phase: WeatherPhase

    var body: some View {
        GeometryReader { proxy in
            Canvas { context, size in
                guard phase.lightning > 0.02 else { return }

                var bolt = Path()
                bolt.move(to: CGPoint(x: size.width * 0.68, y: size.height * 0.08))
                bolt.addLine(to: CGPoint(x: size.width * 0.57, y: size.height * 0.23))
                bolt.addLine(to: CGPoint(x: size.width * 0.64, y: size.height * 0.23))
                bolt.addLine(to: CGPoint(x: size.width * 0.49, y: size.height * 0.45))

                context.stroke(
                    bolt,
                    with: .color(.white.opacity(phase.lightning)),
                    style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round)
                )
                context.addFilter(.blur(radius: 10))
                context.stroke(
                    bolt,
                    with: .color(Color(red: 0.69, green: 0.78, blue: 1.0).opacity(phase.lightning * 0.85)),
                    style: StrokeStyle(lineWidth: 16, lineCap: .round, lineJoin: .round)
                )
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
    }
}

extension Color {
    static func mix(_ first: Color, _ second: Color, _ amount: Double) -> Color {
        let clamped = min(max(amount, 0), 1)

        #if canImport(UIKit)
        typealias NativeColor = UIColor
        #else
        typealias NativeColor = NSColor
        #endif

        let firstComponents = NativeColor(first).rgba
        let secondComponents = NativeColor(second).rgba

        return Color(
            red: firstComponents.red + (secondComponents.red - firstComponents.red) * clamped,
            green: firstComponents.green + (secondComponents.green - firstComponents.green) * clamped,
            blue: firstComponents.blue + (secondComponents.blue - firstComponents.blue) * clamped,
            opacity: firstComponents.alpha + (secondComponents.alpha - firstComponents.alpha) * clamped
        )
    }
}

#if canImport(UIKit)
extension UIColor {
    var rgba: (red: Double, green: Double, blue: Double, alpha: Double) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return (Double(red), Double(green), Double(blue), Double(alpha))
    }
}
#else
extension NSColor {
    var rgba: (red: Double, green: Double, blue: Double, alpha: Double) {
        let color = usingColorSpace(.deviceRGB) ?? self
        return (
            Double(color.redComponent),
            Double(color.greenComponent),
            Double(color.blueComponent),
            Double(color.alphaComponent)
        )
    }
}
#endif
