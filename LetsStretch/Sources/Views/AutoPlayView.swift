import SwiftUI

struct AutoPlayView: View {
    @Bindable var player: SessionPlayer
    var onComplete: () -> Void = {}
    var onEnd: () -> Void = {}

    var body: some View {
        VStack(spacing: 0) {
            if player.isCompleted {
                completedView
            } else if player.isResting {
                restView
            } else {
                stretchView
            }
        }
        .frame(width: 320, height: 420)
    }

    // MARK: - Stretch View

    private var stretchView: some View {
        VStack(alignment: .leading, spacing: 12) {
            progressHeader
            Divider()

            if let stretch = player.currentStretch {
                VStack(alignment: .leading, spacing: 8) {
                    Text(stretch.name)
                        .font(.title3)
                        .fontWeight(.semibold)

                    Text(stretch.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Divider()

                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(
                            Array(stretch.instructions.enumerated()),
                            id: \.offset
                        ) { index, instruction in
                            HStack(alignment: .top, spacing: 8) {
                                Text("\(index + 1).")
                                    .font(.body)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.secondary)
                                Text(instruction)
                                    .font(.body)
                            }
                        }
                    }
                }
            }

            Spacer()
            countdownAndControls
        }
        .padding(20)
    }

    // MARK: - Rest View

    private var restView: some View {
        VStack(spacing: 20) {
            progressHeader
                .padding(.horizontal, 20)
                .padding(.top, 20)

            Spacer()

            VStack(spacing: 12) {
                Image(systemName: "wind")
                    .font(.system(size: 40))
                    .foregroundStyle(.secondary)

                Text("Shake it off!")
                    .font(.title2)
                    .fontWeight(.medium)

                if let nextStretch = player.currentStretch {
                    Text("Get ready for \(nextStretch.name)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
            countdownAndControls
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
        }
    }

    // MARK: - Completed View

    private var completedView: some View {
        VStack(spacing: 20) {
            Spacer()

            VStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(.green)

                Text("You're a stretch legend!")
                    .font(.title)
                    .fontWeight(.bold)

                Text("\(player.totalStretches) stretches crushed. Your body thanks you.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button("Done") {
                onComplete()
            }
            .buttonStyle(.borderedProminent)
            .padding(.bottom, 20)
        }
    }

    // MARK: - Shared Components

    private var progressHeader: some View {
        HStack {
            Text("Stretch \(player.currentStretchIndex + 1) of \(player.totalStretches)")
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer()

            ProgressView(value: player.progress)
                .frame(width: 80)
        }
    }

    private var countdownAndControls: some View {
        VStack(spacing: 12) {
            // Countdown
            Text("\(player.secondsRemaining)")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .monospacedDigit()

            // Controls
            HStack(spacing: 16) {
                Button(action: { player.endSession(); onEnd() }) {
                    Image(systemName: "xmark")
                }
                .buttonStyle(.bordered)
                .help("End session")

                Button(action: { player.togglePauseResume() }) {
                    Image(
                        systemName: player.playState == .playing
                            ? "pause.fill" : "play.fill"
                    )
                }
                .buttonStyle(.borderedProminent)
                .help(player.playState == .playing ? "Pause" : "Resume")

                Button(action: { player.skipStretch() }) {
                    Image(systemName: "forward.fill")
                }
                .buttonStyle(.bordered)
                .help("Skip stretch")
            }
        }
    }
}
