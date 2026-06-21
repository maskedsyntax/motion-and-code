import SwiftUI

@main
struct AppleMusicAlbumExpansionApp: App {
    var body: some Scene {
        WindowGroup {
            AppleMusicExpansionDemo()
                .frame(minWidth: 430, minHeight: 760)
        }
    }
}

struct AppleMusicExpansionDemo: View {
    @Namespace private var albumTransition
    @State private var isExpanded = false
    @State private var playbackProgress = 0.0
    @State private var pulse = false

    var body: some View {
        ZStack {
            AnimatedMusicBackdrop(isExpanded: isExpanded, progress: playbackProgress)
                .ignoresSafeArea()

            NoiseOverlay()
                .ignoresSafeArea()
                .opacity(0.2)

            VStack {
                if isExpanded {
                    ExpandedPlayer(
                        namespace: albumTransition,
                        playbackProgress: playbackProgress,
                        pulse: pulse
                    )
                    .transition(.opacity.combined(with: .scale(scale: 0.96)))
                } else {
                    Spacer()

                    CompactAlbumCard(
                        namespace: albumTransition,
                        playbackProgress: playbackProgress,
                        pulse: pulse
                    )
                    .padding(.horizontal, 26)

                    Spacer()
                }
            }
            .padding(.vertical, 34)
        }
        .preferredColorScheme(.dark)
        .task {
            await runRecordingLoop()
        }
    }

    private func runRecordingLoop() async {
        guard !Task.isCancelled else { return }

        while !Task.isCancelled {
            withAnimation(.smooth(duration: 0.8)) {
                pulse.toggle()
            }

            try? await Task.sleep(for: .milliseconds(850))

            withAnimation(.spring(response: 0.78, dampingFraction: 0.86)) {
                isExpanded = true
            }

            await animateProgress(from: 0.08, to: 0.72, duration: 4.2)
            try? await Task.sleep(for: .milliseconds(900))

            withAnimation(.spring(response: 0.74, dampingFraction: 0.9)) {
                isExpanded = false
            }

            await animateProgress(from: 0.72, to: 0.95, duration: 1.7)
            try? await Task.sleep(for: .milliseconds(900))

            withAnimation(.smooth(duration: 0.4)) {
                playbackProgress = 0.04
            }
            try? await Task.sleep(for: .milliseconds(500))
        }
    }

    private func animateProgress(from start: Double, to end: Double, duration: Double) async {
        let steps = 90

        for step in 0...steps {
            guard !Task.isCancelled else { return }

            let fraction = Double(step) / Double(steps)
            let eased = fraction * fraction * (3 - 2 * fraction)

            await MainActor.run {
                playbackProgress = start + (end - start) * eased
            }

            let nanoseconds = UInt64(duration / Double(steps) * 1_000_000_000)
            try? await Task.sleep(nanoseconds: nanoseconds)
        }
    }
}

struct CompactAlbumCard: View {
    let namespace: Namespace.ID
    let playbackProgress: Double
    let pulse: Bool

    var body: some View {
        VStack(spacing: 18) {
            HStack(spacing: 16) {
                AlbumArtwork(namespace: namespace, size: 92, isExpanded: false)

                VStack(alignment: .leading, spacing: 8) {
                    Text("After Midnight")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .matchedGeometryEffect(id: "title", in: namespace)

                    Text("Nova Lane")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.62))
                        .matchedGeometryEffect(id: "artist", in: namespace)

                    EqualizerBars(progress: playbackProgress, isExpanded: false)
                        .frame(width: 92, height: 24)
                }

                Spacer()

                Image(systemName: "play.fill")
                    .font(.system(size: 19, weight: .bold))
                    .foregroundStyle(.black)
                    .frame(width: 48, height: 48)
                    .background(.white, in: Circle())
                    .scaleEffect(pulse ? 1.08 : 1)
            }

            ProgressTrack(progress: playbackProgress, height: 5)
        }
        .foregroundStyle(.white)
        .padding(18)
        .background {
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .fill(.ultraThinMaterial)
                .matchedGeometryEffect(id: "surface", in: namespace)
                .overlay(
                    RoundedRectangle(cornerRadius: 34, style: .continuous)
                        .stroke(.white.opacity(0.18), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.35), radius: 32, x: 0, y: 24)
        }
    }
}

struct ExpandedPlayer: View {
    let namespace: Namespace.ID
    let playbackProgress: Double
    let pulse: Bool

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "chevron.down")
                    .font(.system(size: 20, weight: .semibold))
                    .frame(width: 44, height: 44)
                    .background(.white.opacity(0.1), in: Circle())

                Spacer()

                Text("Now Playing")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.68))
                    .textCase(.uppercase)
                    .tracking(1.8)

                Spacer()

                Image(systemName: "ellipsis")
                    .font(.system(size: 20, weight: .semibold))
                    .frame(width: 44, height: 44)
                    .background(.white.opacity(0.1), in: Circle())
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)

            Spacer(minLength: 28)

            AlbumArtwork(namespace: namespace, size: 310, isExpanded: true)
                .padding(.horizontal, 34)

            VStack(spacing: 7) {
                Text("After Midnight")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .matchedGeometryEffect(id: "title", in: namespace)

                Text("Nova Lane")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.58))
                    .matchedGeometryEffect(id: "artist", in: namespace)
            }
            .padding(.top, 34)

            EqualizerBars(progress: playbackProgress, isExpanded: true)
                .frame(width: 172, height: 36)
                .padding(.top, 24)

            VStack(spacing: 9) {
                ProgressTrack(progress: playbackProgress, height: 7)

                HStack {
                    Text(timestamp(for: playbackProgress * 196))
                    Spacer()
                    Text("-\(timestamp(for: (1 - playbackProgress) * 196))")
                }
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.48))
                .monospacedDigit()
            }
            .padding(.horizontal, 40)
            .padding(.top, 34)

            HStack(spacing: 42) {
                PlayerButton(systemName: "backward.fill", size: 28)

                PlayerButton(systemName: "pause.fill", size: 34)
                    .frame(width: 74, height: 74)
                    .background(.white, in: Circle())
                    .foregroundStyle(.black)
                    .scaleEffect(pulse ? 1.05 : 1)

                PlayerButton(systemName: "forward.fill", size: 28)
            }
            .padding(.top, 30)

            Spacer(minLength: 34)
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 46, style: .continuous)
                .fill(.ultraThinMaterial)
                .matchedGeometryEffect(id: "surface", in: namespace)
                .overlay(
                    RoundedRectangle(cornerRadius: 46, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [.white.opacity(0.2), .white.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 46, style: .continuous)
                        .stroke(.white.opacity(0.16), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.36), radius: 42, x: 0, y: 28)
        }
        .padding(.horizontal, 18)
    }

    private func timestamp(for seconds: Double) -> String {
        let totalSeconds = max(0, Int(seconds.rounded()))
        return "\(totalSeconds / 60):\(String(format: "%02d", totalSeconds % 60))"
    }
}

struct AlbumArtwork: View {
    let namespace: Namespace.ID
    let size: CGFloat
    let isExpanded: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: isExpanded ? 42 : 24, style: .continuous)
                .fill(
                    AngularGradient(
                        colors: [
                            Color(red: 0.99, green: 0.31, blue: 0.42),
                            Color(red: 0.95, green: 0.69, blue: 0.22),
                            Color(red: 0.36, green: 0.22, blue: 0.85),
                            Color(red: 0.12, green: 0.72, blue: 0.89),
                            Color(red: 0.99, green: 0.31, blue: 0.42),
                        ],
                        center: .center
                    )
                )

            ForEach(0..<7, id: \.self) { index in
                RoundedRectangle(cornerRadius: 999, style: .continuous)
                    .fill(.white.opacity(index.isMultiple(of: 2) ? 0.28 : 0.16))
                    .frame(width: size * 0.95, height: size * 0.16)
                    .rotationEffect(.degrees(Double(index) * 26 - 54))
                    .offset(x: CGFloat(index - 3) * size * 0.035)
                    .blendMode(.overlay)
            }

            Circle()
                .fill(.black.opacity(0.22))
                .frame(width: size * 0.37, height: size * 0.37)
                .blur(radius: 16)

            Image(systemName: "waveform")
                .font(.system(size: size * 0.2, weight: .bold))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.white.opacity(0.86))
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: isExpanded ? 42 : 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: isExpanded ? 42 : 24, style: .continuous)
                .stroke(.white.opacity(0.18), lineWidth: 1)
        )
        .shadow(color: Color(red: 0.98, green: 0.27, blue: 0.47).opacity(isExpanded ? 0.42 : 0.22), radius: isExpanded ? 42 : 18, x: 0, y: isExpanded ? 26 : 12)
        .matchedGeometryEffect(id: "artwork", in: namespace)
    }
}

struct PlayerButton: View {
    let systemName: String
    let size: CGFloat

    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: size, weight: .bold))
            .frame(width: 54, height: 54)
            .foregroundStyle(.white)
    }
}

struct EqualizerBars: View {
    let progress: Double
    let isExpanded: Bool

    private let multipliers = [0.36, 0.72, 0.48, 0.9, 0.58, 0.78, 0.42]

    var body: some View {
        HStack(alignment: .center, spacing: isExpanded ? 7 : 4) {
            ForEach(Array(multipliers.enumerated()), id: \.offset) { index, multiplier in
                let wave = sin(progress * 18 + Double(index) * 0.85)
                let normalized = 0.45 + (wave + 1) * 0.5 * multiplier

                Capsule()
                    .fill(.white.opacity(isExpanded ? 0.76 : 0.56))
                    .frame(width: isExpanded ? 7 : 4, height: max(6, normalized * (isExpanded ? 34 : 22)))
            }
        }
        .animation(.smooth(duration: 0.18), value: progress)
    }
}

struct ProgressTrack: View {
    let progress: Double
    let height: CGFloat

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(.white.opacity(0.16))

                Capsule()
                    .fill(.white.opacity(0.9))
                    .frame(width: proxy.size.width * min(max(progress, 0), 1))
            }
        }
        .frame(height: height)
    }
}

struct AnimatedMusicBackdrop: View {
    let isExpanded: Bool
    let progress: Double

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.14, green: 0.04, blue: 0.13),
                    Color(red: 0.11, green: 0.07, blue: 0.22),
                    Color(red: 0.03, green: 0.03, blue: 0.07),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(Color(red: 1.0, green: 0.2, blue: 0.39).opacity(isExpanded ? 0.46 : 0.28))
                .frame(width: 360, height: 360)
                .blur(radius: 74)
                .offset(x: -120 + progress * 70, y: -250 + progress * 90)

            Circle()
                .fill(Color(red: 0.25, green: 0.64, blue: 1.0).opacity(isExpanded ? 0.36 : 0.22))
                .frame(width: 320, height: 320)
                .blur(radius: 78)
                .offset(x: 150 - progress * 110, y: 160)

            Circle()
                .fill(Color(red: 1.0, green: 0.74, blue: 0.2).opacity(isExpanded ? 0.28 : 0.16))
                .frame(width: 230, height: 230)
                .blur(radius: 58)
                .offset(x: -20, y: 330 - progress * 80)
        }
    }
}

struct NoiseOverlay: View {
    var body: some View {
        Canvas { context, size in
            for index in 0..<130 {
                let x = Double((index * 47) % 100) / 100 * size.width
                let y = Double((index * 89) % 100) / 100 * size.height
                let rect = CGRect(x: x, y: y, width: 1, height: 1)
                context.fill(Path(ellipseIn: rect), with: .color(.white.opacity(0.18)))
            }
        }
    }
}
